//
//  BTBitlyHelper.m
//  Blast
//
//  Created by Brandon Tate on 9/19/11.
//  Copyright 2011 Brandon Tate. All rights reserved.
//

#import "BTBitlyHelper.h"
#import "JSON.h"


// Private Methods
@interface BTBitlyHelper() 

/** The request for the data fetcher. */
@property (nonatomic, retain)   ASIHTTPRequest *request;

/** The Queue. */
@property (nonatomic, retain)   NSMutableArray      *queue;

/** The current url string processing. */
@property (nonatomic, retain)   NSString            *currentUrl;


// OADataFetcher Callbacks
- (void) shortUrlRequestDidFinishWithData: (NSData *) data;
- (void) shortUrlRequestDidFailWithError:(NSError *)error;

// Queue Management
- (void) shortenURL: (NSString *) url;
- (void) shortenNextURL;
- (BOOL) checkFinishedQueue;

@end


@implementation BTBitlyHelper

@synthesize request=_request, delegate=_delegate, queue=_queue, currentUrl=_currentUrl;

static NSString *kBitlyLoginName = @"bobbyren";
static NSString *kBitlyAPIKey = @"R_d4485a81e3f646628087008fa6c7827e";
static NSString *BITLYAPIURL = @"http://api.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json";

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _isRunning = NO;
    }
    
    return self;
}

- (void) dealloc{
    
    [_request release]; _request = nil;
    [_queue release]; _queue = nil;
    [_currentUrl release]; _currentUrl = nil;
    _delegate = nil;
    
    [super dealloc];
}


#pragma mark - Bitly Methods


/**
 *  Returns a shortened version of the url.
 *
 *  @param  url The url to shorten.
 *
 *  @return NSString    The short url.
 */
- (void) shortenURL: (NSString *) url{
    
    _isRunning = YES;
    
    self.currentUrl = url;
    
    // Add http if not there.
    if ([[url lowercaseString] rangeOfString:@"http://"].location == NSNotFound && 
        [[url lowercaseString] rangeOfString:@"https://"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    
    // Build the url
    NSString *bitlyUrl = [NSString stringWithFormat:BITLYAPIURL, 
                          kBitlyLoginName, 
                          kBitlyAPIKey,
                          [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: bitlyUrl]];
    self.request.delegate = self;
    [self.request startAsynchronous];
    
    
    
}


/**
 *  Runs the text through a regular expression and adds any urls it finds to the queue.
 *
 *  @param  text    The text to evaluate.
 *
 *  @return BOOL    Yes if URLs were found to shorten.  No otherwise.
 */
- (BOOL) shortenURLSInText:(NSString *) text{
    
    NSError *error = nil;
    
    
    // John Gruber's ultimate url regex.
    NSString *regexString = @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))";
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString 
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // Grab an array of matches.
    NSArray *matches = [regex matchesInString:text 
                                      options:NSMatchingCompleted 
                                        range:NSMakeRange(0, text.length)];
    
    BOOL returnFlag = NO;
    
    // Loop through them.
    for (NSTextCheckingResult *match in matches) {
        
        // Need to prepare for bitly
        
        NSString *url = [text substringWithRange:match.range];
        
        // Add to bitly queue
        [self addToQueue:url];
        
        returnFlag = YES;
        
    }
    
    return returnFlag;
    
    
}


#pragma mark - OADataFetcher Callbacks

/**
 *  Accepts the short url request data and sends the new and old url to the delegate.
 *
 *  @param  data    The data from the request.
 */
- (void) shortUrlRequestDidFinishWithData: (NSData *) data{
    
    NSString *responseString = [NSString stringWithUTF8String:[data bytes]];
    
    // Clean up json data.
    responseString = [responseString substringToIndex:[responseString rangeOfString:@"}" options:NSBackwardsSearch].location + 1];
    
    NSDictionary *jsonDict = [responseString JSONValue];
    
    // Make sure the data is legit
    if (jsonDict == nil) {
        [self shortenNextURL];
        return;
    }
    if ([jsonDict objectForKey:@"data"] == nil) {
        [self shortenNextURL];
        return;
    }
    if (![[jsonDict objectForKey:@"data"] respondsToSelector:@selector(objectForKey:)]) {
        [self shortenNextURL];
        return;
    }
    
    NSString *shortUrl = [[jsonDict objectForKey:@"data"] objectForKey:@"url"];
    NSString *longUrl = self.currentUrl;
    
    if (shortUrl != nil && longUrl != nil) {
        if (longUrl.length > shortUrl.length) {
            
            if ([self.delegate respondsToSelector:@selector(BTBitlyShortUrl:receivedForOriginalUrl:)]) {
                [self.delegate performSelector:@selector(BTBitlyShortUrl:receivedForOriginalUrl:) withObject:shortUrl withObject:longUrl];
            }
        }
    }
    
    
    [self shortenNextURL];
    
    
}


/**
 *  Handles short url request error.
 *
 *  @param  error   The request error.
 */
- (void) shortUrlRequestDidFailWithError:(NSError *)error{
    
    NSLog(@"bitly failed with error %@", [error localizedDescription]);
    
    [self shortenNextURL];
    
    
    
}

#pragma mark - ASIHTTPRequest Delegate Methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self shortUrlRequestDidFinishWithData:request.responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self shortUrlRequestDidFailWithError:request.error];
}


#pragma mark - Queue Management Methods

/**
 *  Adds the given url to the queue.
 *
 *  @param  url The url to add to the queue.
 */
- (void) addToQueue: (NSString *) url{
    
    // Don't reshorten bitly urls
    if ([self isBitlyURL:url]) {
        [self checkFinishedQueue];
        return;
    }
    
    // Don't add the url twice
    if ([self isInQueue:url]) {
        return;
    }
    
    [self.queue addObject: url];
    
    if (!_isRunning) {
        
        if ([self.delegate respondsToSelector:@selector(BTBitlyQueueStartedProcessing)]) {
            [self.delegate performSelector:@selector(BTBitlyQueueStartedProcessing)];
        }
        
        [self shortenURL:[self.queue objectAtIndex:0]];
    }
    
}

/**
 *  Checks to see if the queue is empty and tells the delegate.
 *
 *  @return BOOL    YES if the queue is finished, no otherwise.
 */
- (BOOL) checkFinishedQueue{
    
    if (self.queue.count <= 0) {
        _isRunning = NO;
        if ([self.delegate respondsToSelector:@selector(BTBitlyQueueFinishedProcessing)]) {
            [self.delegate performSelector:@selector(BTBitlyQueueFinishedProcessing)];
        }
        return YES;
    }
    return NO;
}


/**
 *  Runs the next url in the queue.
 */
- (void) shortenNextURL{
    
    [self.queue removeObjectAtIndex:0];
    
    if (![self checkFinishedQueue]){ 
        
        NSString *nextUrl = [self.queue objectAtIndex:0];
        
        // If it's already a bit.ly url move on.
        if ([self isBitlyURL:nextUrl])
            [self shortenNextURL];
        else
            [self shortenURL:[self.queue objectAtIndex:0]];
        
    }
    
    
    
}


#pragma mark - Helpers

/**
 *  Checks to see if the given url is a bit.ly url.
 *
 *  @param  url     The url to check.
 *  
 *  @return BOOL    Yes if bit.ly url. No otherwise.
 */
- (BOOL) isBitlyURL: (NSString *) url{
    
    return [url rangeOfString:@"bit.ly"].location != NSNotFound;
    
    
}

/**
 *  Checks to see if the given url is already in the queue.
 *
 *  @param  url     The url to check.
 *  
 *  @return BOOL    Yes if the url is already in the queue. No otherwise.
 */
- (BOOL) isInQueue:(NSString *)url{
    
    return [self.queue indexOfObject:url] != NSNotFound;
}


/**
 *  Returns the number of items left in the queue.
 *
 *  @return NSInteger   The count.
 */
- (NSInteger) queueCount{
    return self.queue.count;
}



#pragma mark - Custom Getters

- (NSMutableArray *) queue{
    
    // Make sure we have this.
    if (_queue == nil) {
        _queue = [[NSMutableArray alloc] init];
    }
    
    return _queue;
    
}

@end
