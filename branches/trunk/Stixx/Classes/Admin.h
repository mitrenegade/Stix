//
//  Admin.h
//  Stixx
//
//  Created by Bobby Ren on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"
#import "BadgeView.h"
#import "KumulosData.h"
#import "GlobalHeaders.h"
#import "KumulosHelper.h"

@interface Admin : NSObject <KumulosDelegate>

+(void)adminUpdateAllUserFacebookStrings:(NSArray*)theResults;

@end
