//
//  OutlineLabel.h
//  Stixx
//
//  Created by Bobby Ren on 11/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HOT_SCHEME 0
#define COLD_SCHEME 1

@interface OutlineLabel : UILabel {
    UIColor * outlineColor;
}
@property (nonatomic, retain) UIColor * outlineColor;

-(void)setTextAttributesForBadgeType:(int)type;

@end
