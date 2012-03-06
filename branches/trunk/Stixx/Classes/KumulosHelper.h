//
//  KumulosHelper.h
//  Stixx
//
//  Created by Bobby Ren on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// for clean callbacks of kumulos objects

#import <Foundation/Foundation.h>
#import "Kumulos.h"

@interface KumulosHelper : NSObject <KumulosDelegate>
{
    Kumulos * k;
    NSString * function;
}

@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, assign) NSString * function;

-(void)execute;

@end
