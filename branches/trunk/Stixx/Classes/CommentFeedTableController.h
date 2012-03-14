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
-(int)getCount;
@end

@interface CommentFeedTableController : UITableViewController
{
    NSObject<CommentFeedTableDelegate> * delegate;
    //NSMutableDictionary * cellDictionary;
}

@property (nonatomic, assign) NSObject<CommentFeedTableDelegate> * delegate;
-(NSString*)commentStringFor:(NSString *)name andComment:(NSString *)comment andStixType:(NSString*)stixStringID;
@end
