//
//  Admin.m
//  Stixx
//
//  Created by Bobby Ren on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Admin.h"

@implementation Admin

// debug
-(void)adminUpdateAllStixCountsToZero {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];
    NSMutableDictionary * stix = [BadgeView InitializeFirstTimeUserStix];   
    NSMutableData * data = [KumulosData dictionaryToData:stix];
    [k adminAddStixToAllUsersWithStix:data];
    //[data autorelease]; // arc conversion
    //[stix autorelease]; // arc conversion
}

-(void)adminUpdateAllStixCountsToOne {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];

    NSMutableDictionary * stix = [BadgeView generateOneOfEachStix]; 
    int ct = [[stix objectForKey:@"HEART"] intValue];
    NSLog(@"Heart: %d", ct);
    NSMutableData * data = [KumulosData dictionaryToData:stix];
    [k adminAddStixToAllUsersWithStix:data];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation adminAddStixToAllUsersDidCompleteWithResult:(NSNumber *)affectedRows {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //[self Parse_sendBadgedNotification:@"Ninja admin stix update" OfType:NB_UPDATECAROUSEL toChannel:@"" withTag:nil];
}

-(void)adminResetAllStixOrders {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"adminUpdateAllStixOrders" withParams:nil withCallback:nil withDelegate:self];
    //[[KumulosHelper sharedKumulosHelper] execute:@"adminUpdateAllStixOrders"];
}

/*
-(void)didPressAdminEasterEgg:(NSString *)view {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([view isEqualToString:@"ProfileView"]) {
        [self showAlertWithTitle:@"Authorized Access Only" andMessage:@"" andButton:@"Cancel" andOtherButton:@"Stix it to the Man" andAlertType:ALERTVIEW_PROMPT];
    }
    else if ([view isEqualToString:@"FeedView"]) {
    }
}

-(void)adminEasterEggShowMenu:(NSString *)password {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([[self getUsername] isEqualToString:@"bobo"] || [password isEqualToString:@"admin"]) {
        //        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Ye ol' Admin Menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset All Users' Stix", @"Get me one of each", "Set all Users' bux", nil];
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Test" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset All Users Stix (disabled)", @"Get me one of each (disabled)", @"Set my stix to unlimited (disabled)", @"Increment all Users' Bux by 5", @"Reset all stix orders (disabled)", nil];
        [actionSheet setTag:ACTIONSHEET_TAG_ADMIN];
        [actionSheet showFromTabBar:tabBarController.tabBar ];
    }
    else
        [self showAlertWithTitle:@"Wrong Password!" andMessage:@"You cannot access the super secret club." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
}
*/
-(void) adminSetAllUsersBuxCounts {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k adminSetAllUserBuxWithBux:25];
}

-(void) adminIncrementAllUsersBuxCounts {
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];
    int buxIncrement = 5;
    [k adminIncrementAllUserBuxWithBux:buxIncrement];
    
    //[self Parse_sendBadgedNotification:[NSString stringWithFormat:@"Your Bux have been incremented by %d", buxIncrement] OfType:NB_INCREMENTBUX toChannel:@"" withTag:nil];
}

+(void)adminUpdateAllUserFacebookStrings:(NSArray*)theResults {
    // if users have facebookID (int), change it to facebookString (NSString) and save to kumulos
    int ct = 0;
    for (NSMutableDictionary * d in theResults) {
        NSString * name = [d valueForKey:@"username"];
        NSString * email = [d valueForKey:@"email"];
        NSString * facebookString = [d valueForKey:@"facebookString"];
        NSNumber * facebookID = [d valueForKey:@"facebookID"];
        
        NSLog(@"Username %@ facebookID %@ facebookString %@", name, facebookID, facebookString);
        
        if (facebookString == nil || [facebookString length] == 0) {
            NSMutableDictionary * d = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"username", email, @"email", facebookID, @"facebookID", nil];
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            NSMutableArray * params = [[NSMutableArray alloc] init];
            [params addObject:d];
            [kh execute:@"setFacebookString" withParams:params withCallback:nil withDelegate:nil];
            ct++;
            //break;
        }
    }    
    NSLog(@"Updating facebookString for %d users", ct);
}


@end
