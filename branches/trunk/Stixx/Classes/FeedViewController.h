//
//  FeedViewController.h
//  ARKitDemo
//
//  Created by Administrator on 8/17/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagViewController.h"
#import "FeedItemViewController.h"
#import "PagedScrollView.h"
#import "BadgeView.h"
#import "ZoomViewController.h"
#import "LoadingAnimationView.h"

@protocol FeedViewDelegate

-(NSMutableArray *)getTags;
- (NSString*)getUsername;
-(void)checkForUpdateTags;
-(void)checkForUpdatePhotos;
-(NSMutableDictionary *)getUserPhotos;
-(void)getNewerTagsThanID:(int)tagID;
-(void)getOlderTagsThanID:(int)tagID;

- (bool) isLoggedIn;
-(int)getStixCount:(int)stix_type; // forward from BadgeViewDelegate
-(int)incrementStixCount:(int)type forUser:(NSString *)name;
-(int)decrementStixCount:(int)type forUser:(NSString *)name;
-(void)didAddStixToTag:(Tag *)tag withType:(int)type;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
@end

@interface FeedViewController : UIViewController<PagedScrollViewDelegate, BadgeViewDelegate, ZoomViewDelegate> // <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, >
{
	FeedItemViewController * feedItemViewController;
    BadgeView * badgeView;
    ZoomViewController * zoomViewController;
    
    //IBOutlet UIActivityIndicatorView * activityIndicatorCenter;
    LoadingAnimationView * activityIndicatorCenter;
    IBOutlet UIActivityIndicatorView * activityIndicatorLeft;
    IBOutlet UIActivityIndicatorView * activityIndicatorRight;
    
    IBOutlet UILabel * nameLabel;
    
    NSObject<FeedViewDelegate> * delegate;
    
    NSMutableDictionary *userPhotos;
    
    NSMutableArray * allTags;
    PagedScrollView *scrollView;	
    int lastPageViewed;
    int lastContentOffset;
}
@property (nonatomic, retain) FeedItemViewController * feedItemViewController;
@property (nonatomic, retain) BadgeView *badgeView;
@property (nonatomic, retain) NSMutableArray *allTags;
@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, assign) NSObject<FeedViewDelegate> * delegate;
@property (nonatomic, retain) NSMutableDictionary * userPhotos;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicatorCenter;
@property (nonatomic, retain) LoadingAnimationView * activityIndicatorCenter;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicatorLeft;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicatorRight;
@property (nonatomic, assign) int lastPageViewed;
@property (nonatomic, retain) ZoomViewController * zoomViewController;

-(void)setIndicatorWithID:(int)which animated:(BOOL)animate;

@end



