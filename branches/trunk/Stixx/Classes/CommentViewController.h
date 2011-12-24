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

@protocol CommentViewDelegate <NSObject>

-(void)didCloseComments;
-(void)didAddNewComment:(NSString*)newComment;

@end

@interface CommentViewController : UIViewController <KumulosDelegate, CommentFeedTableDelegate, UITextFieldDelegate>
{
    CommentFeedTableController * commentsTable;

    int tagID;
    NSString * nameString;
    
    NSMutableArray * names;
    NSMutableArray * comments;
    NSMutableArray * stixTypes;
    
    Kumulos * k;
    
    IBOutlet UILabel * nameLabel;
    IBOutlet UIButton * backButton;
    IBOutlet UIButton * addButton;
    IBOutlet UITextField * commentField;
    
    NSObject<CommentViewDelegate> * delegate;
}

@property (nonatomic, assign) int tagID;
@property (nonatomic, retain) NSString * nameString;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * backButton;
@property (nonatomic, retain) IBOutlet UIButton * addButton;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, assign) NSObject<CommentViewDelegate> * delegate;

-(IBAction) backButtonPressed:(id)sender;
-(IBAction) addButtonPressed:(id)sender;
@end
