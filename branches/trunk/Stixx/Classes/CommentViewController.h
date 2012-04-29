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
#import "StixAnimation.h"

@protocol CommentViewDelegate <NSObject>

-(void)didCloseComments;
-(void)didAddNewComment:(NSString*)newComment withTagID:(int)tagID;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
-(void)shouldDisplayUserPage:(NSString*)username;
-(void)shouldCloseUserPage;
@end

@interface CommentViewController : UIViewController <KumulosDelegate, CommentFeedTableDelegate, UITextFieldDelegate, StixAnimationDelegate>
{
    CommentFeedTableController * commentsTable;

    int tagID;
    NSString * nameString;
    
    NSMutableArray * names;
    NSMutableArray * comments;
    NSMutableArray * stixStringIDs;
    NSMutableArray * timestamps;
    NSMutableArray * rowHeights;
    
    Kumulos * k;
    
    IBOutlet UILabel * nameLabel;
    IBOutlet UIButton * backButton;
    IBOutlet UIImageView * logo;
    
    IBOutlet UIButton * addButton;
    IBOutlet UITextField * commentField;
    IBOutlet UIToolbar * toolBar;
    
    NSObject<CommentViewDelegate> * __unsafe_unretained delegate;
    
    LoadingAnimationView * activityIndicator;
}

@property (nonatomic, assign) int tagID;
@property (nonatomic) NSString * nameString;
@property (nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic) IBOutlet UIButton * backButton;
@property (nonatomic) IBOutlet UIButton * addButton;
@property (nonatomic) IBOutlet UITextField * commentField;
@property (nonatomic) IBOutlet UIToolbar * toolBar;
@property (nonatomic, unsafe_unretained) NSObject<CommentViewDelegate> * delegate;
@property (nonatomic) LoadingAnimationView * activityIndicator;

-(IBAction) didClickBackButton:(id)sender;
-(IBAction)didClickAddButton:(id)sender;
-(void)initCommentViewWithTagID:(int)tagID andNameString:(NSString*)nameString;
@end
