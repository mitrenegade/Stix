//
//  StixView.h
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// specifies a UIImageView that is overlaid with multiple stix, which can be manipulated

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "OutlineLabel.h"

@interface StixView : UIImageView
{
    UIImageView * stix;
    OutlineLabel * stixCount;
    bool canManipulate;
    NSMutableArray * auxStix;
    NSMutableArray * auxCanManipulate;
    int drag;
    float offset_x, offset_y;
}

@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) OutlineLabel * stixCount;

-(void)initializeWithImage:(UIImage*)imageData andStix:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y;

@end
