//
//  TwitterHelper.h
//  Stixx
//
//  Created by Bobby Ren on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@protocol TwitterHelperDelegate <NSObject>

-(void)twitterDialogDidFinish;

@end

@interface TwitterHelper : NSObject <UIAlertViewDelegate>{
    TWTweetComposeViewController *twitter;
    NSObject<TwitterHelperDelegate> * delegate;
}

@property (nonatomic) NSObject<TwitterHelperDelegate> * delegate;

-(void)initTwitter;
+(TwitterHelper*)sharedTwitterHelper;
-(UIViewController*)getTwitterDialog;
-(void)requestTwitterPostPermission;

@end
