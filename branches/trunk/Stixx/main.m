//
//  main.m
//  Stixx
//
//  Created by Bobby Ren on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
int main(int argc, char *argv[])
{
    [Parse setApplicationId:@"BZpZEXeYgWUeu2Pg3nJSbcGIkoYkR5qxaAsK1ClT" 
                  clientKey:@"GuFFolAFIpDNoe8If7Jm6ATYNPaJc2bdAvPLfBZx"];
    

    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        return retVal;
    }
}
