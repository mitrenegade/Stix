//
//  TwitterHelper.h
//  Stixx
//
//  Created by Bobby Ren on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "SHKTwitter.h"
#import "KumulosHelper.h"

@protocol TwitterHelperDelegate <NSObject>

//-(void)twitterHelperDidConnect;
-(void)twitterHelperDidReturnWithCallback:(SEL)callback andParams:(id)params andRequestType:(NSString*)requestType;
-(int)getUserID;
@optional
-(void)twitterHelperStartedInitialConnect; 
-(void)didInitialLoginForTwitter;
-(void)twitterHelperDidFailWithRequestType:(NSString*)requestType;
@end

@interface TwitterHelper : SHKTwitter <SHKSharerDelegate, KumulosHelperDelegate>
{
    NSObject<TwitterHelperDelegate> * __unsafe_unretained helperDelegate;
    
    SEL CALLBACK_FUNC;
    id callbackParams;
    
    NSString * requestType;
}
@property (nonatomic, unsafe_unretained) NSObject<TwitterHelperDelegate> * helperDelegate;
@property (retain) UIViewController *currentTopViewController;

// ios5 twitter library calls - not used
-(void)requestTwitterUnauthenticated;
+(void)requestTwitterAuthentication;
-(void)requestPost;

+(UIViewController*)showTwitterComposerWithHandler:(TWTweetComposeViewControllerCompletionHandler)handler;
+(BOOL)hasiOS5TwitterCredentials; 

// extend ShareKit's twitter functionality to make different requests
- (void)followMe:(NSString*)name;
-(void)doInitialConnect;
-(void)doInitialConnectWithCallback:(SEL) callback withParams:(id)params;
- (void)getFriendsForUser:(NSString*)name;
-(void)getMyCredentials;
-(void)getNamesForIDs:(NSArray*)twitterStrings;
-(void)sendInviteMessage:(NSString*)screen_name;
-(void)sendMassInviteMessage:(NSMutableArray*)screen_names;
@end
