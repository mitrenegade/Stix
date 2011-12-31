//
//  CommentFeedTableController.h
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentTableCell.h"

@protocol CommentFeedTableDelegate 
-(NSString *)getNameForIndex:(int)index;
-(NSString *)getCommentForIndex:(int)index;
//-(UIImageView *)getStixForIndex:(int)index;
//-(int)getStixTypeForIndex:(int)index;
-(NSString *)getStixStringIDForIndex:(int)index;
-(int)getCount;
@end

@interface CommentFeedTableController : UITableViewController
{
    NSObject<CommentFeedTableDelegate> * delegate;
}

@property (nonatomic, assign) NSObject<CommentFeedTableDelegate> * delegate;
@end
