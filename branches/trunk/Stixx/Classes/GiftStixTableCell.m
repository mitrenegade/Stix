//
//  GiftStixTableCell.m
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GiftStixTableCell.h"

@implementation GiftStixTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        for (int i=0; i<3; i++)
        {
            icon[i] = nil;
            bg[i] = nil;
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)addCellItem:(UIImageView *)item atPosition:(int)pos{
    if (pos < 0 || pos > 2)
        return;
    if (!bg[pos]) {
        bg[pos] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_bkg.png"]];
        [bg[pos] setFrame:CGRectMake(pos*105+5,2,100,100)];
        [self addSubview:bg[pos]];
    }
    if (!icon[pos]) {
        icon[pos] = [item retain];
        [icon[pos] setBackgroundColor:[UIColor clearColor]];
        [icon[pos] setFrame:CGRectMake(pos*105+5,2,100,100)];
        [self addSubview:icon[pos]];
    }
}

-(void)removeCellItemAtPosition:(int)pos {
    if (bg[pos]) {
        [bg[pos] removeFromSuperview];
        [bg[pos] release];
        bg[pos] = nil;
    }
    if (icon[pos]) {
        [icon[pos] removeFromSuperview];
        [icon[pos] release];
        icon[pos] = nil;
    }
}

@end
