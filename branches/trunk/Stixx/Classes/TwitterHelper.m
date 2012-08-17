//
//  TwitterHelper.m
//  Stixx
//
//  Created by Bobby Ren on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Notes on hacking ShareKit's twitter class to also do regular requests like friends:
//  We use this in order to take advantage of the built in OAuth library. TwitterHelper is a subclass so that we can access consumer key, etc.
//  Authentication functions (authorize and logout) are based on class name (SHKTwitter, SHKFacebook, or TwitterHelper in our case). So whenever logout or authorize are called, they must be done on the same class, ie TwitterHelper.
//  For some reason, if we are using SHKTwitter calls inside TwitterHelper, after authorize happens, the screen/prompt doesn't appear. 

#import "TwitterHelper.h"

@implementation TwitterHelper

@synthesize helperDelegate;
@synthesize currentTopViewController;

-(void)doInitialConnect {
    requestType = @"initialConnect";
    SHKItem *newitem = [[SHKItem alloc] init];
    [newitem setShareType:SHKShareTypeUserInfo];
#if 0
    // use original SHKTwitter class
    SHKTwitter * twitter = [[SHKTwitter alloc] init];
    [twitter setShareDelegate:self];
    [twitter setItem:newitem];
    [twitter setShareDelegate:self]; // for initial connect, be the sharerDelegate 
    [twitter share];
#else
    [self setItem:newitem];
    [self setShareDelegate:self]; // for initial connect, be the sharerDelegate 
    [self share];
#endif
}

-(void)doInitialConnectWithCallback:(SEL) callback withParams:(id)params {
    CALLBACK_FUNC = callback;
    callbackParams = params;
    [self doInitialConnect];
}

-(void)sharerStartedSending:(SHKSharer *)sharer {
    if ([[sharer item] shareType] == SHKShareTypeUserInfo) {
        if ([helperDelegate respondsToSelector:@selector(twitterHelperStartedInitialConnect)])
            [helperDelegate twitterHelperStartedInitialConnect];
    }
}

// comes here after a successful SHKShareTypeUserInfo
- (void)sharerFinishedSending:(SHKSharer *)sharer {
    // doesn't come here
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
    if ([[sharer item] shareType] == SHKShareTypeUserInfo) {
        NSLog(@"Finished sending: userinfo");
        /*
        if (CALLBACK_FUNC) {
            [helperDelegate twitterHelperDidReturnWithCallback:CALLBACK_FUNC andParams:callbackParams];
        }
        else
            [helperDelegate didInitialLoginForTwitter];
         */
    }
}

-(void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin {
    NSLog(@"Sharer failed with error: %@ shouldRelogin: %d", [error description], shouldRelogin);
}

- (void)followMe:(NSString*)name
{
	// remove it so in case of other failures this doesn't get hit again
	[item setCustomValue:nil forKey:@"followMe"];
	
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/friendships/create/%@.json", name]]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];
	
	[oRequest setHTTPMethod:@"POST"];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(didFinish)
                                                                                   didFailSelector:@selector(didFail)];	
	
	[fetcher start];
}

- (void)getFriendsForUser:(NSString*)name
{
    requestType = @"getFriendsForUser";
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/friends/ids.json?screen_name=%@", name]]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];	
    [oRequest setHTTPMethod:@"GET"];
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(getRequest:didFinishWithData:)
                                                                                   didFailSelector:@selector(getRequest:didFailWithError:)];		
    [fetcher start];
    //[oRequest release];
}

-(void)getMyCredentials {

    requestType = @"getMyCredentials";
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/account/verify_credentials.json"]]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];	
    [oRequest setHTTPMethod:@"GET"];
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(getRequest:didFinishWithData:)
                                                                                   didFailSelector:@selector(getRequest:didFailWithError:)];		
    [fetcher start];
    //[oRequest release];
}

-(void)getNamesForIDs:(NSArray*)twitterStrings {
     
    requestType = @"getNamesForIDs";
    NSString * urlString = @"https://api.twitter.com/1/users/lookup.json?user_id=";
    for (int i=0; i<[twitterStrings count]; i++) {
        NSString * userID = [twitterStrings objectAtIndex:i];
        if (i == [twitterStrings count]-1) { 
            // last object
            urlString = [NSString stringWithFormat:@"%@%@", urlString, userID];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@,", urlString, userID];
        }
    }
    NSLog(@"URL String: %@", urlString);
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];	
    [oRequest setHTTPMethod:@"GET"];
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(getRequest:didFinishWithData:)
                                                                                   didFailSelector:@selector(getRequest:didFailWithError:)];		
    [fetcher start];
    //[oRequest release];
}

-(void)didFinish {
    NSLog(@"Here!");
}
-(void)didFail {
    NSLog(@"Here!");
}
-(void)getRequest:(OAServiceTicket *)ticket didFailWithError:(NSError*) error {
    NSLog(@"Failure error! error: %@", error);
    NSLog(@"ticket failed: %@", [ticket debugDescription]);
    NSLog(@"Request type: %@", requestType);
    if ([helperDelegate respondsToSelector:@selector(twitterHelperDidFailWithRequestType:)])
        [helperDelegate twitterHelperDidFailWithRequestType:requestType];
}
-(void)getRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{	
    if (ticket.didSucceed) {
        NSError *jsonError;
        id results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];            
        
        if (results) {                          
            // at this point, we have an object that we can parse
            //NSLog(@"%@", results);
            
            if ([requestType isEqualToString:@"getMyCredentials"]) {
                // return dictionary of user info
                NSDictionary * returnDict = results;
                if ([helperDelegate respondsToSelector:@selector(didGetTwitterCredentials:)])
                    [helperDelegate twitterHelperDidReturnWithCallback:@selector(didGetTwitterCredentials:) andParams:returnDict andRequestType:requestType];
                
                // add credentials to kumulos
                if ([helperDelegate respondsToSelector:@selector(getUserID)]) {
                    NSString * twitterString = [results objectForKey:@"id_str"];
                    int userID = [helperDelegate getUserID];
                    KumulosHelper * kh = [[KumulosHelper alloc] init];
                    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:userID], twitterString, nil];
                    [kh execute:@"setTwitterString" withParams:params withCallback:@selector(khCallback_didGetFacebookUser:) withDelegate:self];
                }
            }
            else if ([requestType isEqualToString:@"getFriendsForUser"]) {
                NSArray * friendsIDs = [self parseResponse:data forKey:@"ids"];
                if ([helperDelegate respondsToSelector:@selector(didGetTwitterFriendsIDs:)])
                    [helperDelegate twitterHelperDidReturnWithCallback:@selector(didGetTwitterFriendsIDs:) andParams:friendsIDs andRequestType:requestType];
            }
            else if ([requestType isEqualToString:@"getNamesForIDs"]) {
                NSArray * friendArray = results; // array of dictionaries
                if ([helperDelegate respondsToSelector:@selector(didGetTwitterFriendsFromIDs:)])
                    [helperDelegate twitterHelperDidReturnWithCallback:@selector(didGetTwitterFriendsFromIDs:) andParams:friendArray andRequestType:requestType];
            }
            else if ([requestType isEqualToString:@"directMessage"]) {
                NSLog(@"Direct message done!");
            }
        } 
        else { 
            // inspect the contents of jsonError
            NSLog(@"%@", jsonError);
        }
    }
    else {
        NSLog(@"ticket failed: %@", [ticket debugDescription]);
		NSLog(@"Twitter Send Status Error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        // if this happens twitter has authenticated but the request returned an error.
        // if the user does the same request, or it is redone automatically, things should work.
        // todo: display message to try again later?
    }
}

#pragma mark twitter response parser
-(id)parseResponse:(NSData*)response forKey:(NSString*)key {
    NSError *jsonError;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&jsonError];  
    NSEnumerator * e = [results keyEnumerator];
    for (NSString * k in e)
        NSLog(@"Key: %@ value: %@", k, [results objectForKey:k]);
    return [results objectForKey:key];
}

+(BOOL)hasiOS5TwitterCredentials {
    //  First, we need to obtain the account instance for the user's Twitter account
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request permission from the user to access the available Twitter accounts
    NSArray *twitterAccounts = 
    [store accountsWithAccountType:twitterAccountType];
    
    if ([twitterAccounts count] > 0) {
        return YES;
    }
    return NO;
}     

// these are calls done by the superclasses, and because token access settings are key/value pairs with the class type, they must be called with SHKTwitter as the class
+(void)logout {
#if 0
    [SHKTwitter logout];
#else
    [super logout];
#endif
}

-(BOOL)isAuthorized {
#if 0
    SHKTwitter * twitterHelperHelper = [[SHKTwitter alloc] init];
    return [twitterHelperHelper isAuthorized];
#else
    return [super isAuthorized];
#endif
}

-(void)sendInviteMessage:(NSString*)screen_name {
    requestType = @"directMessage";
    // hack: all messages sent to hackstarbobo for now
    NSString * shareText = [NSString stringWithFormat:@"d stixapp %@, Tired of Instagram filters?  Try out Stix photo app for the iPhone.  It's free! http://bit.ly/JECBPU", screen_name];
    SHKItem *_item = [SHKItem text:shareText];
    [self setItem:_item];
    [self share];
}
-(void)sendMassInviteMessage:(NSMutableArray*)screen_names {
    requestType = @"directMessage";
    // hack: all messages sent to hackstarbobo for now
    for (NSString * screen_name in screen_names) {
        NSString * shareText = [NSString stringWithFormat:@"d stixapp %@, Tired of Instagram filters?  Try out Stix photo app for the iPhone.  It's free! http://bit.ly/JECBPU", screen_name];
        SHKItem *_item = [SHKItem text:shareText];
        [self setItem:_item];
        [self share];
    }
}

-(void)sendDidStart {
    NSLog(@"Twitter post did start. Request Type: %@", requestType);
}
-(void)sendDidFinish {
    NSLog(@"Twitter post did finish. Request Type: %@", requestType);
    if ([requestType isEqualToString:@"initialConnect"]) {
        // for some reason, twitter connect through findFriends comes here
        if ([helperDelegate respondsToSelector:@selector(didInitialLoginForTwitter)])
            [helperDelegate didInitialLoginForTwitter];

    }
    else if ([requestType isEqualToString:@"directMessage"]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Twitter invite sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)sendDidCancel {
    NSLog(@"Twitter post did cancel");
}

@end
