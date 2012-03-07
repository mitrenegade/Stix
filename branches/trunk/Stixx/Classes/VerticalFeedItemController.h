//
//  VerticalFeedItemController.h
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//
//  FeedViewController.h
//  ARKitDemo
//
//  Created by Administrator on 8/17/11.
//  Copyright 2011 Neroh. All rights reserved.
//
//
//  VerticalFeedItemController.h
//  ARKitDemo
//
//  Created by Administrator on 9/13/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "BadgeView.h"
#import "OutlineLabel.h"
#import "StixView.h"

@class VerticalFeedItemController;

@protocol VerticalFeedItemDelegate 

-(void)displayCommentsOfTag:(int)tagID andName:(NSString*)nameString;
-(void)sharePix:(int)tagID;

// forward from StixView
-(NSString*)getUsername;
-(void)didPerformPeelableAction:(int)action forAuxStix:(int)index;
-(void)didClickAtLocation:(CGPoint)location withFeedItem:(VerticalFeedItemController *)feedItem;
@end

@interface VerticalFeedItemController : UIViewController <StixViewDelegate>{
    
	IBOutlet UILabel * labelName;
    //    IBOutlet UILabel * labelDescriptorBG; // needed for opacity trick
    IBOutlet UIImageView * labelDescriptorBG;
	IBOutlet UILabel * labelDescriptor;
    IBOutlet UILabel * labelComment;
	IBOutlet UILabel * labelTime;
    IBOutlet UILabel * labelLocationString;
	IBOutlet UIImageView * imageView;
    StixView * stixView;
    IBOutlet UIImageView * userPhotoView;
    IBOutlet UIButton * addCommentButton;
    IBOutlet UIButton * shareButton;
    
    NSObject<VerticalFeedItemDelegate> * delegate;    
    
    NSString * nameString;
    NSString * descriptorString;
    NSString * commentString;
    NSString * locationString;
    UIImage * imageData;
    UIImageView * locationIcon;
    int commentCount;
    int tagID;
    
}
@property (retain, nonatomic) IBOutlet UILabel * labelName;
@property (retain, nonatomic) IBOutlet UILabel * labelComment;
@property (retain, nonatomic) IBOutlet UILabel * labelDescriptor;
@property (retain, nonatomic) IBOutlet UIImageView * labelDescriptorBG;
@property (retain, nonatomic) IBOutlet UILabel * labelTime;
@property (retain, nonatomic) IBOutlet UILabel * labelLocationString;
@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UIImageView * userPhotoView;
@property (nonatomic, retain) IBOutlet UIImageView * locationIcon;
@property (nonatomic, retain) NSString * nameString;
@property (nonatomic, retain) NSString * commentString;
@property (nonatomic, retain) UIImage * imageData;
@property (nonatomic, retain) IBOutlet UIButton * addCommentButton;
@property (nonatomic, retain) IBOutlet UIButton * shareButton;
@property (nonatomic, assign) int tagID;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) NSObject<VerticalFeedItemDelegate> * delegate;   
@property (nonatomic, retain) StixView * stixView;

-(void)populateWithName:(NSString *)name andWithDescriptor:(NSString*)descriptor andWithComment:(NSString*)comment andWithLocationString:(NSString*)location;
-(void)populateWithUserPhoto:(UIImage*)photo;
-(void)populateWithTimestamp:(NSDate *)timestamp;
-(void)populateWithCommentCount:(int)count;

-(void)initStixView:(Tag*)tag;
+(NSString*) getTimeLabelFromTimestamp:(NSDate*) timestamp;

-(IBAction)didPressAddCommentButton:(id)sender;
-(IBAction)didPressShareButton:(id)sender;
@end


