//
//  GiftStixTableController.h
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "GiftStixTableCell.h"
#import "OutlineLabel.h"

@protocol GiftStixTableControllerDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;

@end

@interface GiftStixTableController : UITableViewController
{
    NSObject<GiftStixTableControllerDelegate> *delegate;
    
    NSMutableArray * allGiftStixCounts;
    NSMutableArray * allStixStringIDs;
}

@property (nonatomic, assign) NSObject<GiftStixTableControllerDelegate> *delegate;

-(void)reloadStixCounts;
@end
