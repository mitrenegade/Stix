#import "SMWebRequest.h"

//
// Utility class for dealing with NSURLConnection's retaining of its delegate.
//

@interface SMCallbackProxy : NSProxy { id target; }
- (id)initWithTarget:(id)target;
- (void)releaseAndClearTarget;
@end
@implementation SMCallbackProxy
- (id)initWithTarget:(id)theTarget { target = theTarget; return self; }
- (void)releaseAndClearTarget { target = nil;  }
- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel { return [target methodSignatureForSelector:sel]; }
- (void) forwardInvocation:(NSInvocation *)invocation { [invocation setTarget:target]; [invocation invoke]; }
- (BOOL) respondsToSelector:(SEL)sel { return [target respondsToSelector:sel]; }
@end

//
// Utility class for tracking our target/action pairs.
//

@interface SMTargetAction : NSObject {
    @package
    id target;
    SEL action;
    SMWebRequestEvents events;
}
@end
@implementation SMTargetAction
@end

//
// WebRequest.
//

NSString *const kSMWebRequestComplete = @"SMWebRequestComplete", *const kSMWebRequestError = @"SMWebRequestError";
NSString *const SMErrorResponseKey = @"response";

// This is a global variable that is only accessed from the main thread, that handles the special case where
// we want to have been dealloced while our background thread was alive.
static BOOL was_dealloced = NO;

@interface SMWebRequest ()
@property (nonatomic, unsafe_unretained) id<SMWebRequestDelegate> delegate;
@property (nonatomic) id context;
@property (nonatomic) NSMutableArray *targetActions;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSURLRequest *request;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic) NSURLConnection *connection;
@end

@implementation SMWebRequest
@synthesize context, targetActions, delegate, data, request, response, connection;

- (id)initWithURLRequest:(NSURLRequest *)theRequest delegate:(id<SMWebRequestDelegate>)theDelegate context:(id)theContext {
    self = [super init];
    if (self) {
        self.request = theRequest;
        self.delegate = theDelegate;
        self.context = theContext;
        self.targetActions = [NSMutableArray array]; 
        proxy = [[SMCallbackProxy alloc] initWithTarget:self];
    }
    return self;
}

- (void)dealloc {
    was_dealloced = YES; // in case backgroundProcessingComplete cares.
    //NSLog(@"Dealloc %@", self);
    [proxy releaseAndClearTarget]; // don't allow any more calls to be passed through
    proxy = nil;
    [self cancel];
    self.delegate = nil;
}

+ (SMWebRequest *)requestWithURL:(NSURL *)theURL {
    return [SMWebRequest requestWithURL:theURL delegate:nil context:nil];
}

+ (SMWebRequest *)requestWithURL:(NSURL *)theURL forMethod:(NSString*)method {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theURL];
    [request setHTTPMethod:method];
    
    return [SMWebRequest requestWithURLRequest:request delegate:nil context:nil];
}

+ (SMWebRequest *)requestWithURL:(NSURL *)theURL delegate:(id<SMWebRequestDelegate>)theDelegate context:(id)theContext {
    return [SMWebRequest requestWithURLRequest:[NSURLRequest requestWithURL:theURL] delegate:theDelegate context:theContext];
}

+ (SMWebRequest *)requestWithURLRequest:(NSURLRequest *)theRequest delegate:(id<SMWebRequestDelegate>)theDelegate context:(id)theContext {
    return [[SMWebRequest alloc] initWithURLRequest:theRequest delegate:theDelegate context:theContext];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@>", self.request.URL];
}

- (void)start {
    if (requestFlags.started) return; // subsequent calls to this method won't do anything
    
    requestFlags.started = YES;
    
    //NSLog(@"Requesting %@", self);
    requestFlags.wasTemporarilyRedirected = NO;
    self.data = [NSMutableData data];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:proxy];
}

- (BOOL)started { return requestFlags.started; }

- (void)cancel {
    if (requestFlags.cancelled) return; // subsequent calls to this method won't do anything
    
    // the only thing that can actually be "cancelled" is the NSURLConnection. Background thread processing can't be
    // cancelled since the background thread must run to completion or else you end up with god knows what on the heap.
    if (connection) {
        //NSLog(@"Cancelling %@", self);
        [connection cancel];
        self.connection = nil;
    }
    requestFlags.cancelled = YES;
    self.context = nil; // you'll never hear from us again.
}

#pragma mark Target/Action management

- (SMTargetAction *)targetActionForTarget:(id)target action:(SEL)action {
    for(SMTargetAction *ta in targetActions)
        if (ta->target == target && (ta->action == action || !action))
            return ta;
    
    return nil;
}

- (void)addTarget:(id)target action:(SEL)action forRequestEvents:(SMWebRequestEvents)events {
    
    SMTargetAction *ta = [self targetActionForTarget:target action:action];
    
    if (!ta) {
        ta = [[SMTargetAction alloc] init];
        ta->target = target;
        ta->action = action;
        [targetActions addObject:ta];
    }
    
    ta->events |= events;
}

- (void)removeTarget:(id)target action:(SEL)action forRequestEvents:(SMWebRequestEvents)events {
    
    while (true) { // if you passed NULL for the action, we may have to search multiple times
        
        SMTargetAction *ta = [self targetActionForTarget:target action:action];
        
        if (!ta) break;
        
        SMWebRequestEvents toRemove = ta->events & events;
        ta->events -= toRemove;
        
        if (!ta->events)
            [targetActions removeObject:ta];        
    }
    
    if (![targetActions count])
        [self cancel];
}

- (void)removeTarget:(id)target {
    [self removeTarget:target action:NULL forRequestEvents:SMWebRequestEventAllEvents];
}

- (NSMutableArray *)targetActionsForEvents:(SMWebRequestEvents)events {
    NSMutableArray *resultTargetActions = [NSMutableArray array];
    
    for(SMTargetAction *ta in targetActions)
        if ((ta->events & events) != 0) [resultTargetActions addObject:ta];
    
    return resultTargetActions;
}

// only call on main thread
- (void)dispatchEvents:(SMWebRequestEvents)events withArgument:(id)arg {
    
    for (SMTargetAction *ta in [self targetActionsForEvents:events])
        [ta->target performSelector:ta->action withObject:arg withObject:context];
    
    // events dispatched (if any) and delegate called (if any); so we're done.
    self.context = nil;
}

- (void)dispatchComplete:(id)resultObject {
    
    // notify the delegate first
    if ([delegate respondsToSelector:@selector(webRequest:didCompleteWithResult:context:)])
        [delegate webRequest:self didCompleteWithResult:resultObject context:context];      
    
    // notify event listeners
    [self dispatchEvents:SMWebRequestEventComplete withArgument:resultObject];
    
    // notify the world last
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMWebRequestComplete object:self];
}

- (void)dispatchError:(NSError *)error {
    
    // notify the delegate first
    if ([delegate respondsToSelector:@selector(webRequest:didFailWithError:context:)])
        [delegate webRequest:self didFailWithError:error context:context];
    
    // notify event listeners
    [self dispatchEvents:SMWebRequestEventError withArgument:error];
    
    // notify the world last
    NSDictionary *info = [NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMWebRequestError object:self userInfo:info];
}

// in a background thread! don't touch our instance members!
- (void)processDataInBackground:(NSData *)theData {
    @autoreleasepool {
    
        id resultObject = theData;
        
        if ([delegate respondsToSelector:@selector(webRequest:resultObjectForData:context:)])
            resultObject = [delegate webRequest:self resultObjectForData:theData context:context];
        
        [self performSelectorOnMainThread:@selector(backgroundProcessingComplete:) withObject:resultObject waitUntilDone:NO];
    }
}

// back on the main thread
- (void)backgroundProcessingComplete:(id)resultObject {

    // OK, so we want to basically quit without dispatching events if we WOULD have been dealloced if our background
    // thread wasn't running. So, we'll tentatively release ourself here first, and if we get dealloced then
    // we'll know to do nothing and exit without calling dispatch on our listeners (which probably are dealloced themselves).
    was_dealloced = NO;

    if (was_dealloced) return; // OK, we were dealloced, quick, exit before touching our instance vars (pointers to garbage now)!
    
    // don't dispatch events if -cancel was called while we were in the background thread.
    if (!requestFlags.cancelled)
        [self dispatchComplete:resultObject];
}

#pragma mark NSURLConnection delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)newRequest redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse && [(NSHTTPURLResponse *)redirectResponse statusCode] != 301)
        requestFlags.wasTemporarilyRedirected = YES;
    
    // see if our delegate cares about this
    if ([delegate respondsToSelector:@selector(webRequest:willSendRequest:redirectResponse:)])
        return [delegate webRequest:self willSendRequest:newRequest redirectResponse:redirectResponse];
    else
        return newRequest; // let it happen
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)aResponse {
    self.response = aResponse;
    [data setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)moreData {
    [data appendData:moreData];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    NSLog(@"SMWebRequest's NSURLConnection failed! Error - %@ %@", error, conn);
    
    self.connection = nil;
    self.data = nil;
     // we must retain ourself before we call handlers, in case they release us!
    
    [self dispatchError:error];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    
    //NSLog(@"Finished loading %@", self);
    
     // we must retain ourself before we call handlers, in case they release us!
    
    NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)response statusCode] : 200;
    
    if (conn && response && (status < 200 || (status >= 300 && status != 304))) {
        NSLog(@"Failed with HTTP status code %i while loading %@", (int)status, self);
        
        SMErrorResponse *error = [[SMErrorResponse alloc] init];
        error.response = (NSHTTPURLResponse *)response;
        error.data = data;
        
        NSMutableDictionary* details = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"Received an HTTP status code indicating failure.", NSLocalizedDescriptionKey,
                                        error, SMErrorResponseKey,
                                        nil];
        [self dispatchError:[NSError errorWithDomain:@"SMWebRequest" code:status userInfo:details]];
    }
    else {
        if ([delegate respondsToSelector:@selector(webRequest:resultObjectForData:context:)]) {
            
            // neither us nor our delegate can get dealloced whilst processing on the background
            // thread or else the background thread could try to do stuff with pointers to garbage.
            // thus we need have a mechanism for keeping ourselves alive during the background
            // processing.
            
            [self performSelectorInBackground:@selector(processDataInBackground:) withObject:data];
        }
        else
            [self dispatchComplete:data];
    }
    
    self.connection = nil;
    self.data = nil; // don't keep this!
}

@end

@implementation SMErrorResponse
@synthesize response, data;
@end