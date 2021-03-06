//
//  CommentFeedTableController.h
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "GlobalHeaders.h"

@protocol CommentFeedTableDelegate 
-(NSString *)getNameForIndex:(int)index;
-(NSString *)getCommentForIndex:(int)index;
-(NSString *)getStixStringIDForIndex:(int)index;
-(NSString *)getTimestampStringForIndex:(int)index;
-(UIImage *)getPhotoForIndex:(int)index;
-(int)getCount;
-(float)getRowHeightForRow:(int)index;

// for userGalleryDelegate calls
-(void)shouldDisplayUserPage:(NSString *)username;
@end

#define SHOW_COMMENTS_ONLY 0

@interface CommentFeedTableController : UITableViewController
{
    NSObject<CommentFeedTableDelegate> * __unsafe_unretained delegate;
    //NSMutableDictionary * cellDictionary;
    
    // configurable
    int rowHeight;
    BOOL showDivider;
    int fontSize;
    UIColor * fontNameColor;
    UIColor * fontTextColor;
}

@property (nonatomic, unsafe_unretained) NSObject<CommentFeedTableDelegate> * delegate;
@property (nonatomic, assign) int rowHeight;
@property (nonatomic) UIColor * fontNameColor;
@property (nonatomic) UIColor * fontTextColor;
//-(NSString*)commentStringFor:(NSString *)name andComment:(NSString *)comment andStixType:(NSString*)stixStringID;
-(NSString*)simpleCommentString:(NSString *)comment andStixType:(NSString*)stixStringID;
-(void)configureRowsWithHeight:(int)height dividerVisible:(BOOL)visible fontSize:(int)size fontNameColor:(UIColor*)nameColor fontTextColor:(UIColor*)textColor;
-(float)getHeightForComment:(NSString*)comment forStixStringID:(NSString*)stixStringID;
@end
