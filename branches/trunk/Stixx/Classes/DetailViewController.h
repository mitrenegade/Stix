//
//  DetailViewController.h
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "Tag.h"
#import "OutlineLabel.h"
#import "StixView.h"
#import "StixAnimation.h"
#import "CommentFeedTableController.h"
#import "Kumulos.h"
#import "LoadingAnimationView.h"

@protocol DetailViewDelegate

-(void)didDismissZoom;

@end

@interface DetailViewController : UIViewController <StixViewDelegate, StixAnimationDelegate, CommentFeedTableDelegate, KumulosDelegate>

{
    //    IBOutlet UILabel * labelComment;
    //    IBOutlet UILabel * labelLocationString;
    CommentFeedTableController * commentsTable;
	NSObject<DetailViewDelegate> *delegate;
    StixView * stixView;
    IBOutlet UIImageView * logo;
    
    UIScrollView * scrollView;
    
    NSMutableArray * names;
    NSMutableArray * comments;
    NSMutableArray * stixStringIDs;
    int tagID;
    Kumulos * k;
    
    int animationID[2];
}
//@property (nonatomic, retain) IBOutlet UILabel * labelComment;
//@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, assign) NSObject<DetailViewDelegate> *delegate;
@property (nonatomic, retain) StixView * stixView;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView * logo;

-(IBAction)didPressBackButton:(id)sender;
-(void)initDetailViewWithTag:(Tag *)tag;

@end
