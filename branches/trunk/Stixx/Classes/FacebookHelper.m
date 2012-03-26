//
//  FacebookHelper.m
//  MyFacebookApp2
//
//  Created by Bobby Ren on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookHelper.h"

@implementation FacebookHelper

@synthesize facebook;
@synthesize delegate;

/* in the Application delegate, you must have this:
 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.fbLogin handleOpenURL:url]; 
 }
 
*/

/**
 * To initialize, just make sure you have the correct APP_ID set in FacebookHelper.h
 * and make sure it is set under your info.plist file: see https://developers.facebook.com/docs/mobile/ios/build/#register
 * If you have multiple apps that need the same FB login, you can also set urlSchemeSuffix to
 * a string for your scheme. see https://developers.facebook.com/docs/mobile/ios/build/#multipleapps
 */
-(void)initFacebook {
    //facebook = [[Facebook alloc] initWithAppId:APP_ID andDelegate:self];
    facebook = [[Facebook alloc] initWithAppId:APP_ID urlSchemeSuffix:APP_SUFFIX andDelegate:self];
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
                                //@"publish_stream",
                                @"email",
                                nil];
        if ([permissions count] == 0)
            [facebook authorize:nil];
        else {
            [facebook authorize:permissions];
            [permissions release];
        }
        return 1; // logged in anew
    }
    else {
        return 0; // already loggedin
    }
}
-(void)getFacebookInfo {
    [facebook requestWithGraphPath:@"me" andDelegate:self];  
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

// response for requestWithGraphPath
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSDictionary * dictionary = result;
    //NSLog(@"Result: %@", result);
    [self.delegate didGetFacebookInfo:dictionary];
}

-(NSString*)getAccessToken {
    return [facebook accessToken];
}

-(void)postToFacebookWithLink:(NSString*)link andPictureLink:(NSString*)pictureLink andTitle:(NSString*)title andCaption:(NSString*)caption andDescription:(NSString*)description {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   APP_ID, @"app_id",
                                   link, @"link",
                                   pictureLink, @"picture",
                                   title, @"name",
                                   caption, @"caption",
                                   description, @"description",
                                   nil];
    [facebook dialog:@"feed" andParams:params andDelegate:self];
}

#pragma FBDialogDelegate functions
- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"Facebook dialog completed!");
}
- (void)dialogDidNotComplete:(FBDialog *)dialog {
    NSLog(@"Facebook dialog did not complete!");
}
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"Facebook dialog failed: %@", [error description]);
}



@end
