//
//  GiftStixTableCell.h
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "OutlineLabel.h"

#define CELL_WIDTH 320
#define CELL_HEIGHT 115
#define CELL_ITEM_WIDTH 100
#define CELL_ITEM_HEIGHT 100
@interface GiftStixTableCell : UITableViewCell
{
    UIImageView * bg[3];
    UIImageView * icon[3];
    //NSMutableArray * labels;
    OutlineLabel * labels[3];
}

-(void)addCellItem:(UIImageView*) item atPosition:(int)pos;
-(void)addCellLabel:(NSString*) item atPosition:(int)pos;
-(void)removeCellItemAtPosition:(int)pos;
@end
