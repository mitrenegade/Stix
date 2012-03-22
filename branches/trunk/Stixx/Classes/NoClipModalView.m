//
//  NoClipModalView.m
//  Stixx
//
//  Created by Bobby Ren on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoClipModalView.h"

@implementation NoClipModalView

- (void)didMoveToSuperview

{ 
    
    self.superview.clipsToBounds = NO; 
    
} 

@end 