//
//  FacebookHelper.h
//  MyFacebookApp2
//
//  Created by Bobby Ren on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "JSON.h"
#import "FBConnect.h"
#import "SMWebRequest.h"
//#import "SMXMLDocument.h"

// NOW defined in Stixx-info.plist
// for Stix
//#define APP_ID @"191699640937330" // DEFINE YOUR FACEBOOK APP ID HERE - this is for Stix
// for Stix Lite
//#define APP_ID @"244406082334236"
#define APP_SUFFIX nil //@"foo"

@protocol FacebookHelperDelegate <NSObject>

-(void)didGetFacebookInfo:(NSDictionary *)results;
-(void)didLoginToFacebook;
-(void)didLogoutFromFacebook;
-(void)didCancelFacebookLogin;
-(void)receivedFacebookFriends:(NSArray*)friendsArray;
-(NSString*)getUserFacebookString;
-(void)didEarnFacebookReward:(int)bux;
//-(void)facebookLoginIsOffline;
@end

@interface FacebookHelper : NSObject < FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>
{
    Facebook * facebook;
    NSObject<FacebookHelperDelegate> * delegate;

    NSString * currentRequest;
    NSString * postType;
}

@property (nonatomic) Facebook * facebook;
@property (nonatomic) NSObject<FacebookHelperDelegate> * delegate;
@property (nonatomic) SMWebRequest * getRequest;
-(void)initFacebook;
-(int)facebookLogin;
-(void)facebookLogout;
-(void)getFacebookInfo;
-(NSString*)getAccessToken;
-(BOOL)handleOpenURL:(NSURL*)url;
-(int)facebookHasSession;
-(void)postToFacebookWithLink:(NSString*)link andPictureLink:(NSString*)pictureLink andTitle:(NSString*)title andCaption:(NSString*)caption andDescription:(NSString*)description useDialog:(BOOL)useDialog;
-(void)requestFacebookFriends;
-(void)sendInvite:(NSString*)name withFacebookString:(NSString*)facebookString;
+(FacebookHelper*)sharedFacebookHelper;
@end
