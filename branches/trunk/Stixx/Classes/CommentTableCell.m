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

-(void)populateWithName:(NSString *)newName andComment:(NSString *)newComment andStixType:(int)stixType {
    if (self.stix)
        [self.stix removeFromSuperview];
    
    self.name = newName;
    self.comment = newComment;
    if (stixType != -1)
    {
        self.stix = [BadgeView getBadgeOfType:stixType];
        [self.stix setFrame:CGRectMake(250,0,60,60)];
    }
    
    NSString * str;
    if ([comment length] == 0) // add generic descriptor
    {
        NSArray * desc = [BadgeView stixDescriptors];
        str = [NSString stringWithFormat:@"%@ added a %@", [self name], [desc objectAtIndex:stixType]];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@ said, \"%@\"", [self name], [self comment]];
    }
    [[self textLabel] setText:str];
    [[self textLabel] setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    if (stixType != -1)
        [self addSubview:[self stix]];
}
@end
