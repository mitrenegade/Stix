//
//  FriendsViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "PagedScrollView.h"
#import "LoadingAnimationView.h"
#import "UserProfileViewController.h"

@protocol FriendsViewDelegate

- (void)checkForUpdatePhotos;
-(NSMutableDictionary *)getUserPhotos;
- (NSString*)getUsername;
-(void)didDismissFriendView;

-(int)getStixCount:(int)stix_type; // forward from BadgeViewDelegate
-(int)getStixLevel;
-(int)incrementStixCount:(int)type forUser:(NSString *)name;
-(int)decrementStixCount:(int)type forUser:(NSString *)name;
-(void)didCreateBadgeView:(UIView*)newBadgeView;

@end

@interface FriendsViewController : UIViewController <BadgeViewDelegate, PagedScrollViewDelegate, UserProfileViewDelegate>
{
    NSMutableDictionary *userPhotos;
    NSMutableDictionary *userPhotoFrames;
    NSMutableArray * friendPages;
    IBOutlet UIButton * buttonInstructions;
    IBOutlet UIButton * buttonBack;
    BadgeView * badgeView;
    //IBOutlet UIActivityIndicatorView * activityIndicator;

    PagedScrollView *scrollView;	
    LoadingAnimationView * activityIndicator;
    int lastContentOffset;

    NSObject<FriendsViewDelegate> * delegate;
    
    UserProfileViewController * userProfileController;

    NSString * currentProfile; // name of profile currently viewed
}
@property (nonatomic, retain) NSMutableDictionary * userPhotos;
@property (nonatomic, retain) NSMutableDictionary * userPhotoFrames;
@property (nonatomic, retain) NSMutableArray * friendPages;
@property (nonatomic, assign) NSObject<FriendsViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) IBOutlet UIButton * buttonBack;
@property (nonatomic, retain) BadgeView * badgeView;
//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) NSString * currentProfile;
@property (nonatomic, retain) UserProfileViewController * userProfileController;

-(IBAction)closeInstructions:(id)sender;
-(void)setIndicator:(BOOL)animate;
-(IBAction)backButtonClicked:(id)sender;
@end

