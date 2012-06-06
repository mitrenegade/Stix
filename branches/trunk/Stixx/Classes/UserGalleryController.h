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

@protocol UserGalleryDelegate <NSObject>

-(UIImage*)getUserPhotoForUsername:(NSString*)name;
-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID;
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
-(void)shouldDisplayUserPage:(NSString*)name;
-(void)shouldCloseUserPage;
@end

@interface UserGalleryController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, StixViewDelegate, DetailViewDelegate, UIActionSheetDelegate, StixAnimationDelegate, KumulosHelperDelegate>
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
}
@property (nonatomic) NSString * username;
@property (nonatomic, unsafe_unretained) NSObject<UserGalleryDelegate> * delegate;
@property (nonatomic) Kumulos * k;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) ColumnTableController * pixTableController;
@property (nonatomic) UIView * headerView;
@property (nonatomic) DetailViewController * detailController;

-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)forceReloadAll;

@end

