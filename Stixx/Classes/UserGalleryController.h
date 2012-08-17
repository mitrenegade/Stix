//
//  UserGalleryController.h
//  Stixx
//
//  Created by Bobby Ren on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColumnTableController.h"
#import "Kumulos.h"
#import "StixView.h"
#import "LoadingAnimationView.h"
#import "DetailViewController.h"
#import "StixAnimation.h"
#import "KumulosHelper.h"
#import "GlobalHeaders.h"
#import "FlurryAnalytics.h"

@protocol UserGalleryDelegate <NSObject>

-(UIImage*)getUserPhotoForUsername:(NSString*)name;
-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID;
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
-(void)shouldDisplayUserPage:(NSString*)name;
-(void)shouldCloseUserPage;
-(void)didClickRemixFromDetailViewWithTag:(Tag*)tagToRemix;
-(NSString*)getUsername;
-(BOOL)isFollowingUser:(NSString*)name;
@end

@interface UserGalleryController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, StixViewDelegate, DetailViewDelegate, UIActionSheetDelegate, StixAnimationDelegate, KumulosHelperDelegate, UIScrollViewDelegate>
{
    NSMutableArray * allTagIDs; // ordered in descending order
    NSMutableDictionary * allTags; // key: allTagID
    NSMutableDictionary * contentViews; // generated views: key: row/column index of table
    NSMutableDictionary * placeholderViews;
    NSMutableDictionary * isShowingPlaceholderView;
    int numColumns;
    UIView * placeholderViewGlobal;
    
    IBOutlet UIImageView * logo;
    
    int shareActionSheetTagID;
    
    int dismissAnimation;
    
    int pendingContentCount;
    int lastRowRequest;
    
    IBOutlet UIScrollView * scrollView;
    ColumnTableController * pixTableController;
    
    // user info header
    UIImageView * photoButton;
    UIButton * buttonAddFriend;
    UILabel * nameLabel;
    NSString * lastUsername;
    UIButton * buttonFollowers;
    UIButton * buttonFollowing;
    OutlineLabel * myFollowersCount;
    OutlineLabel * myFollowingCount;
    OutlineLabel * myFollowersLabel;
    OutlineLabel * myFollowingLabel;
    
}
@property (nonatomic) NSString * username;
@property (nonatomic, unsafe_unretained) NSObject<UserGalleryDelegate> * delegate;
@property (nonatomic) Kumulos * k;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) ColumnTableController * pixTableController;
@property (nonatomic) UIView * headerView;
@property (nonatomic) DetailViewController * detailController;
@property (nonatomic) UIImageView * photoButton;
@property (nonatomic) UIButton * buttonAddFriend;
@property (nonatomic) UILabel * nameLabel;
@property (nonatomic, copy) NSString * lastUsername;
@property (nonatomic) UIButton * buttonFollowers;
@property (nonatomic) UIButton * buttonFollowing;
@property (nonatomic) OutlineLabel * myFollowersCount;
@property (nonatomic) OutlineLabel * myFollowingCount;
@property (nonatomic) OutlineLabel * myFollowersLabel;
@property (nonatomic) OutlineLabel * myFollowingLabel;

-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)forceReloadAll;

@end

