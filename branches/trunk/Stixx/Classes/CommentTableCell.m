//
//  CommentTableCell.m
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentTableCell.h"

@implementation CommentTableCell

@synthesize name, comment, stix;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider.png"]] autorelease]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)populateWithName:(NSString *)newName andComment:(NSString *)newComment andStixType:(NSString*)stixStringID {
    if (self.stix)
        [self.stix removeFromSuperview];
    
    self.name = newName;
    self.comment = newComment;
    if (![stixStringID isEqualToString:@"COMMENT"] && ![comment isEqualToString:@"PEEL"])
    {
        self.stix = [BadgeView getBadgeWithStixStringID:stixStringID];
        [self.stix setFrame:CGRectMake(250,0,60,60)];
    }
    
    NSString * str;
    if ([comment length] == 0) // add generic descriptor
    {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"%@ added a %@", [self name], desc];
    }
    else if ([comment isEqualToString:@"PEEL"]) {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"%@ peeled off a %@ to add to their collection", [self name], desc];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@ said, \"%@\"", [self name], [self comment]];
    }
    [[self textLabel] setText:str];
    [[self textLabel] setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    if (![stixStringID isEqualToString:@"COMMENT"] && ![stixStringID isEqualToString:@"PEEL"])
        [self addSubview:[self stix]];
}
@end
