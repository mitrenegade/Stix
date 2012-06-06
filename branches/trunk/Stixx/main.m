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
    /*
    [Parse setApplicationId:@"BZpZEXeYgWUeu2Pg3nJSbcGIkoYkR5qxaAsK1ClT" 
                  clientKey:@"GuFFolAFIpDNoe8If7Jm6ATYNPaJc2bdAvPLfBZx"];
    */
    /*
     // for LITE
    [Parse setApplicationId:@"yip3Sp7VzlBYHQMX906g8Ht8AguxEHmibuBsi38N"
                  clientKey:@"P7w6DeECEo9a7wTHHdAox3aAuL76MeTibUSLTsmQ"];
     */
    
    // remember, setting up parse also involves uploading an app certificate (.p12)
    
//    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:@"Neroh"])
//    {
    
#if 1
    // this is the Parse app that works with the apple store version of stix.
    // it must be used with an Ad Hoc/Production version of the build, whether it is sent through test flight or through app store
        NSLog(@"Parse: Bundle identifier: %@ Parse APP ID %@ CLIENT ID %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_APP_ID"], [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_CLIENT_ID"]);
        [Parse setApplicationId: [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_APP_ID"]
                      clientKey:[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_CLIENT_ID"]];
#else
//    }
//    else if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqualToString:@"com.Neroh.Stix.Lite"]){
        NSLog(@"Parse: Bundle identifier: %@ Parse APP ID %@ CLIENT ID %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_APP_ID_DEV"], [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_CLIENT_ID_DEV"]);
        [Parse setApplicationId: [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_APP_ID_DEV"] clientKey:[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSEnvironment"] objectForKey:@"PARSE_CLIENT_ID_DEV"]];
    // Stix Development Parse account
    //[Parse setApplicationId:@"zPxo37QJ9mtc1PfxmN3ToxmPvYhljdKsRf13Dscv" clientKey:@"2ot86krHvyCwvOzJsdXcZ8YYVckbC5V5cBr8MCjZ"];
//    }
#endif
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        return retVal;
    }
}
