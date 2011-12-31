//
//  FriendsViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarouselView.h"
#import "PagedScrollView.h"
#import "LoadingAnimationView.h"
#import "UserProfileViewController.h"

@protocol FriendsViewDelegate

- (void)checkForUpdatePhotos;
-(NSMutableDictionary *)getUserPhotos;
- (NSString*)getUsername;
-(void)didDismissFriendView;

-(int)getStixCount:(NSString*)stixStringID;
-(void)didCreateBadgeView:(UIView*)newBadgeView;

@end

@interface FriendsViewController : UIViewController <BadgeViewDelegate, PagedScrollViewDelegate, UserProfileViewDelegate>
{
    NSMutableDictionary *userPhotos;
    NSMutableDictionary *userPhotoFrames;
    NSMutableArray * friendPages;
    IBOutlet UIButton * buttonInstructions;
    IBOutlet UIButton * buttonBack;
    CarouselView * carouselView;
    
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
@property (nonatomic, retain) CarouselView * carouselView;
@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) NSString * currentProfile;
@property (nonatomic, retain) UserProfileViewController * userProfileController;

-(IBAction)closeInstructions:(id)sender;
-(void)setIndicator:(BOOL)animate;
-(IBAction)backButtonClicked:(id)sender;
@end

