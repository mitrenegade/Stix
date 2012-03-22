//
//  CommentViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentFeedTableController.h"
#import "Kumulos.h"
#import "BadgeView.h"
#import "LoadingAnimationView.h"

@protocol CommentViewDelegate <NSObject>

-(void)didCloseComments;
-(void)didAddNewComment:(NSString*)newComment withTagID:(int)tagID;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
@end

@interface CommentViewController : UIViewController <KumulosDelegate, CommentFeedTableDelegate, UITextFieldDelegate>
{
    CommentFeedTableController * commentsTable;

    int tagID;
    NSString * nameString;
    
    NSMutableArray * names;
    NSMutableArray * comments;
    NSMutableArray * stixStringIDs;
    NSMutableArray * timestamps;
    NSMutableDictionary * photos;
    
    Kumulos * k;
    
    IBOutlet UILabel * nameLabel;
    IBOutlet UIButton * backButton;
    IBOutlet UIButton * addButton;
    IBOutlet UITextField * commentField;
    IBOutlet UIImageView * logo;
    
    NSObject<CommentViewDelegate> * delegate;
    
    LoadingAnimationView * activityIndicator;
}

@property (nonatomic, assign) int tagID;
@property (nonatomic, retain) NSString * nameString;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * backButton;
@property (nonatomic, retain) IBOutlet UIButton * addButton;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, assign) NSObject<CommentViewDelegate> * delegate;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;

-(IBAction) backButtonPressed:(id)sender;
-(IBAction) addButtonPressed:(id)sender;
-(void)initCommentViewWithTagID:(int)tagID andNameString:(NSString*)nameString;
@end
