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

@protocol UserGalleryDelegate <NSObject>

-(UIImage*)getUserPhotoForGallery;
-(void)uploadImage:(NSData*)dataPNG withShareMethod:(int)method;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID;

@end

@interface UserGalleryController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, StixViewDelegate, DetailViewDelegate, UIActionSheetDelegate, StixAnimationDelegate>
{
    NSMutableArray * allTagIDs; // ordered in descending order
    NSMutableDictionary * allTags; // key: allTagID
    NSMutableDictionary * contentViews; // generated views: key: row/column index of table
    int numColumns;
    
    IBOutlet UIImageView * logo;
    
    int shareActionSheetTagID;
    
    int dismissAnimation;
}
@property (nonatomic, retain) NSString * username;
@property (nonatomic, assign) NSObject<UserGalleryDelegate> * delegate;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) ColumnTableController * pixTableController;
@property (nonatomic, retain) UIView * headerView;
@property (nonatomic, retain) DetailViewController * detailController;

-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)forceReloadAll;

@end

