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

@protocol GiftStixTableControllerDelegate
-(int)getStixCount:(int)type;
@end

@interface GiftStixTableController : UITableViewController
{
    NSObject<GiftStixTableControllerDelegate> *delegate;
    
    NSMutableArray * allStix;
    NSMutableArray * stixDescriptors;
    NSMutableArray * stixFilenames;
}

@property (nonatomic, assign) NSObject<GiftStixTableControllerDelegate> *delegate;
@property (nonatomic, retain) NSMutableArray * stixDescriptors;
@property (nonatomic, retain) NSMutableArray * stixFilenames;
@end
