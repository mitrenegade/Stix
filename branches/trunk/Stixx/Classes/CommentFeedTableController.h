//
//  CommentFeedTableController.h
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"

@protocol CommentFeedTableDelegate 
-(NSString *)getNameForIndex:(int)index;
-(NSString *)getCommentForIndex:(int)index;
-(NSString *)getStixStringIDForIndex:(int)index;
-(NSString *)getTimestampStringForIndex:(int)index;
-(UIImage *)getPhotoForIndex:(int)index;
-(int)getCount;
@end

#define SHOW_COMMENTS_ONLY 0

@interface CommentFeedTableController : UITableViewController
{
    NSObject<CommentFeedTableDelegate> * delegate;
    //NSMutableDictionary * cellDictionary;
    
    // configurable
    int rowHeight;
    BOOL showDivider;
    int fontSize;
    UIColor * fontNameColor;
    UIColor * fontTextColor;
}

@property (nonatomic, assign) NSObject<CommentFeedTableDelegate> * delegate;
@property (nonatomic, assign) int rowHeight;
@property (nonatomic, retain) UIColor * fontNameColor;
@property (nonatomic, retain) UIColor * fontTextColor;
-(NSString*)commentStringFor:(NSString *)name andComment:(NSString *)comment andStixType:(NSString*)stixStringID;
-(NSString*)simpleCommentString:(NSString *)comment andStixType:(NSString*)stixStringID;
-(void)configureRowsWithHeight:(int)height dividerVisible:(BOOL)visible fontSize:(int)size fontNameColor:(UIColor*)nameColor fontTextColor:(UIColor*)textColor;
@end
