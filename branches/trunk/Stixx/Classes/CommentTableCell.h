//
//  CommentTableCell.h
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"

#define CELL_WIDTH 320
#define CELL_HEIGHT 115
#define CELL_ITEM_WIDTH 100
#define CELL_ITEM_HEIGHT 100
@interface CommentTableCell : UITableViewCell
{
    NSString * name;
    NSString * comment;
    UIImageView * stix;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) UIImageView * stix;

-(void)populateWithName:(NSString*)name andComment:(NSString*)comment andStixType:(int)stixType;

@end
