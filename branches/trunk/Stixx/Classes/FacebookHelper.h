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
#import "SMXMLDocument.h"

#define APP_ID @"191699640937330" // DEFINE YOUR FACEBOOK APP ID HERE - this is for Stix
#define APP_SUFFIX nil //@"foo"
//#define APP_ID @"220429624645828" // GYMPACT
//#define APP_SUFFIX nil

@protocol FacebookHelperDelegate <NSObject>

-(void)didGetFacebookInfo:(NSDictionary *)results;
-(void)didLoginToFacebook;
-(void)didLogoutFromFacebook;
-(void)didCancelFacebookLogin;
-(void)receivedFacebookFriends:(NSArray*)friendsArray;
@end

@interface FacebookHelper : NSObject < FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>
{
    Facebook * facebook;
    NSObject<FacebookHelperDelegate> * delegate;

    NSString * currentRequest;
}

@property (nonatomic, retain) Facebook * facebook;
@property (nonatomic, retain) NSObject<FacebookHelperDelegate> * delegate;
@property (nonatomic, retain) SMWebRequest * getRequest;
-(void)initFacebook;
-(int)facebookLogin;
-(void)facebookLogout;
-(void)getFacebookInfo;
-(NSString*)getAccessToken;
-(BOOL)handleOpenURL:(NSURL*)url;
-(int)facebookHasSession;
-(void)postToFacebookWithLink:(NSString*)link andPictureLink:(NSString*)pictureLink andTitle:(NSString*)title andCaption:(NSString*)caption andDescription:(NSString*)description;
-(void)requestFacebookFriends;
-(void)sendInvite:(NSString*)name withFacebookID:(NSString*)facebookID;
@end
