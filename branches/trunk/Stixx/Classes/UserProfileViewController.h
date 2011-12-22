//
//  ProfileViewController.h
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserProfileViewDelegate

- (int)getUserTagTotal;
- (void)didDismissUserProfileView;
@end

@interface UserProfileViewController : UIViewController <UIAlertViewDelegate >{

    IBOutlet UIButton * stixCountButton; // custom button but no clicking
    IBOutlet UIButton * friendCountButton; 
    IBOutlet UIButton * navBackButton;
    IBOutlet UIButton * addFriendButton;
    
    IBOutlet UIButton * photoButton;
    IBOutlet UILabel * nameLabel;
    
    NSObject<UserProfileViewDelegate> *delegate;
}

@property (nonatomic, retain) IBOutlet UIButton * stixCountButton;
@property (nonatomic, retain) IBOutlet UIButton * friendCountButton;
@property (nonatomic, assign) NSObject<UserProfileViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * photoButton;
@property (nonatomic, retain) IBOutlet UIButton * navBackButton;
@property (nonatomic, retain) IBOutlet UIButton * addFriendButton;

-(IBAction)addFriendButtonClicked:(id)sender;
-(IBAction)navBackButtonClicked:(id)sender;
-(void)setUsername:(NSString*)username;
-(void)setPhoto:(UIImage*)photo;
@end
