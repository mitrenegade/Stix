    //
//  FacebookHelper.m
//  MyFacebookApp2
//
//  Created by Bobby Ren on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookHelper.h"

static FacebookHelper *sharedFacebookHelper;
static NSString * appID;

@implementation FacebookHelper

@synthesize facebook;
@synthesize delegate;
@synthesize getRequest;

/* in the Application delegate, you must have this:
 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.fbLogin handleOpenURL:url]; 
 }
 
*/
+(FacebookHelper*)sharedFacebookHelper 
{
	if (!sharedFacebookHelper){
		sharedFacebookHelper = [[FacebookHelper alloc] init];
	}
	return sharedFacebookHelper;
}

/**
 * To initialize, just make sure you have the correct APP_ID set in FacebookHelper.h
 * and make sure it is set under your info.plist file: see https://developers.facebook.com/docs/mobile/ios/build/#register
 * If you have multiple apps that need the same FB login, you can also set urlSchemeSuffix to
 * a string for your scheme. see https://developers.facebook.com/docs/mobile/ios/build/#multipleapps
 */
-(void)initFacebook {

    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:@"Neroh"])
    {
        appID = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"FACEBOOK_APP_ID"];
    }
    else if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:@"com.Neroh.Stix.Lite"]){
        appID = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"FACEBOOK_APP_ID_LITE"];
    }
    else if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:@"com.neroh.stixx"]){
        appID = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"FACEBOOK_APP_ID_STIXX"];
    }
    NSLog(@"FacebookHelper: bundle %@ appID %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], appID);

    //facebook = [[Facebook alloc] initWithAppId:APP_ID andDelegate:self];
    facebook = [[Facebook alloc] initWithAppId:appID urlSchemeSuffix:APP_SUFFIX andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    //[self facebookLogin];
}
-(void)facebookLogout {
    if ([facebook isSessionValid]) {
        [facebook logout];
    }
}

/**
 * Requesting permissions: see permissions reference: 
 * https://developers.facebook.com/docs/reference/api/permissions/
 */
-(int)facebookHasSession {
    if ([facebook isSessionValid]) {
        return 1;
    }
    else
        return 0;
}

-(int)facebookLogin {
    if (![facebook isSessionValid]) {
        // authorize the session and request permissions
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_about_me",
                                @"user_photos",
                                //@"user_likes", 
                                //@"read_stream",
                                @"publish_stream", // post to friend's stream
                                @"email",
                                nil];
        if ([permissions count] == 0) {
            [facebook authorize:nil];
        }
        else {
            [facebook authorize:permissions];
        }
        return 1; // logged in anew
    }
    else {
        return 0; // already loggedin
    }
}
-(void)getFacebookInfo {
    NSLog(@"FacebookHelper getFacebookInfo: requesting graph path: ME");
    [facebook requestWithGraphPath:@"me" andDelegate:self];  
    currentRequest = @"requestGraphPathMe";
}

/*** Facebook delegate functions ***/
// Pre 4.2 support
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return [facebook handleOpenURL:url]; 
//}
// For 4.2+ support
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    NSLog(@"Access token: %@", [facebook accessToken]);
    [self.delegate didLoginToFacebook];
}

- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    [self.delegate didLogoutFromFacebook];
}

- (void)fbSessionInvalidated {
    NSLog(@"fbSessionInvalidated");
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    NSLog(@"Access token %@ extended", accessToken);
}
- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Facebook login cancelled by user");
    [self.delegate didCancelFacebookLogin];
}

-(BOOL)handleOpenURL:(NSURL*)url {
    return [facebook handleOpenURL:url];
}

-(NSString*)getAccessToken {
    return [facebook accessToken];
}

-(void)postToFacebookWithLink:(NSString*)link andPictureLink:(NSString*)pictureLink andTitle:(NSString*)title andCaption:(NSString*)caption andDescription:(NSString*)description useDialog:(BOOL)useDialog{
    postType = @"sharePix";
    if (useDialog) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   appID, @"app_id",
                                   link, @"link",
                                   pictureLink, @"picture",
                                   title, @"name",
                                   caption, @"caption",
                                   description, @"description",
                                   nil];
        [facebook dialog:@"feed" andParams:params andDelegate:self];
    }
    else {
        
        // There are many other params you can use, check the API
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       appID, @"app_id",
                                       caption, @"message",
                                       link, @"link",
                                       pictureLink, @"picture",
                                       description, @"description",
                                       title, @"name",
                                       nil];
        //[NSMutableDictionary dictionaryWithObjects:obj forKeys:keys];
        NSLog(@"Requesting graphPath");
        [facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:nil];    
    }
}

#pragma mark friend request

-(void)requestFacebookFriends {
#if 0
    NSString * urlString = [NSString stringWithFormat: @"https://graph.facebook.com/me/friends?access_token=%@", [facebook accessToken]];
    
    NSString * fullURL = [NSString stringWithFormat:@"%@", urlString];
    getRequest = [[SMWebRequest requestWithURL:[NSURL URLWithString:fullURL]] retain];
    [getRequest addTarget:self action:@selector(requestFacebookFriendsFinished:) forRequestEvents:SMWebRequestEventComplete];
    [getRequest start];
    NSLog(@"Get request: %@", fullURL);
#else
    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
    currentRequest = @"requestGraphPathFriends";
#endif
}

// response from SMWebRequest
-(void)requestFacebookFriendsFinished:(NSMutableDictionary*)responseData {   
#if 0
    NSString *responseText = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Returned URL response: %@", responseText);
    
    // parse JSON
    NSString *responseString = [NSString stringWithUTF8String:[responseData bytes]];
    
    // Clean up json data.
    responseString = [responseString substringToIndex:[responseString rangeOfString:@"}" options:NSBackwardsSearch].location + 1];
    
    NSDictionary *jsonDict = [responseString JSONValue];
    // facebook JSON Data has two elements: data and paging
    // data is an array containing key-value pairs of fbID and name
    NSArray *friendsArray = [jsonDict objectForKey:@"data"];
#else
    NSArray * friendsArray = [responseData objectForKey:@"data"];
#endif
    /*
     for (int i=0; i<[friendsArray count]; i++) {
     NSDictionary * d = [friendsArray objectAtIndex:i];
     NSString * fbID = [d objectForKey:@"id"];
     NSString * name = [d objectForKey:@"name"];
     NSLog(@"Friend %d id %@ name %@", i, fbID, name);
     }
     */
    [self.delegate receivedFacebookFriends:friendsArray];
}

-(void)sendInvite:(NSString *)name withFacebookID:(NSString*)facebookID {
    postType = @"inviteFriend";
    NSString * myFacebookID = [NSString stringWithFormat:@"%d", [delegate getUserFacebookID]];
    // the only message that shows up
    NSString * postname = @"Get Sticky with me...";
    NSString * description = @"Let's remix our photos with fun, crazy, digital stickers.";
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"stixmobile.com/", @"link", 
                                   facebookID, @"to",
                                   myFacebookID, @"from",
                                   postname, @"name",
                                   //caption, @"caption", 
                                   description, @"description",
                                   appID, @"app_id",
                                   nil];
#if 0
    // send app request dialog
    [facebook dialog:@"apprequests"
           andParams:params
         andDelegate:self];
#else
    // post to wall
    [facebook dialog:@"feed" andParams:params andDelegate:self];
#endif
}

#pragma mark FBRequestDelegate

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"FacebookHelper FBRequest failed with error: %@ currentRequest: %@", [error description], currentRequest);
    /*
    if ([error code] == -1009) {
        [delegate facebookLoginIsOffline];
    }
     */
    if ([currentRequest isEqualToString:@"requestGraphPathMe"]) {
        NSLog(@"Repeating getFacebookInfo request");
        [self getFacebookInfo];
    }
}

// response for requestWithGraphPath
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSDictionary * dictionary = result;
    //NSLog(@"Result: %@", result);
    if ([currentRequest isEqualToString:@"requestGraphPathMe"])
        [delegate didGetFacebookInfo:dictionary];
    else if ([currentRequest isEqualToString:@"requestGraphPathFriends"])
        [self requestFacebookFriendsFinished:result];
}

#pragma mark FBDialogDelegate functions
//- (void)dialogDidComplete:(FBDialog *)dialog {
- (void) dialogCompleteWithUrl:(NSURL*) url
{
    if ([url.absoluteString rangeOfString:@"post_id="].location != NSNotFound) {
        //alert user of successful post
        NSLog(@"Facebook dialog completed!");
        if ([postType isEqualToString:@"inviteFriend"]) {
            [delegate didEarnFacebookReward:10];
        }
        //else if ([postType isEqualToString:@"sharePix"]) {
        //    [delegate didEarnFacebookReward:1];
        //}
    } else {
        //user pressed "cancel"
        NSLog(@"Facebook dialog did not complete!");
    }
}
- (void)dialogDidNotComplete:(FBDialog *)dialog {
    NSLog(@"Facebook dialog did not complete!");
}
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"Facebook dialog failed: %@", [error description]);
}


@end
