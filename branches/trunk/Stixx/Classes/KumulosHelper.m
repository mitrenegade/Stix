//
//  KumulosHelper.m
//  Stixx
//
//  Created by Bobby Ren on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KumulosHelper.h"
#import "KumulosData.h"
#import "BadgeView.h"

@implementation KumulosHelper
@synthesize k;
@synthesize function;
@synthesize callback;
@synthesize delegate;

static KumulosHelper *sharedKumulosHelper;

-(id)init
{
	[super init];
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
	return self;
}

+(KumulosHelper*)sharedKumulosHelper 
{
	if (!sharedKumulosHelper){
		sharedKumulosHelper = [[KumulosHelper alloc] init];
	}
	return sharedKumulosHelper;
}

-(void)execute:(NSString*)_function withParams:(NSMutableArray*)params withCallback:(SEL)_callback withDelegate:(NSObject<KumulosHelperDelegate>*)helperDelegate{
    [self setFunction:_function];
    [self setCallback:_callback];
    delegate = helperDelegate;
    if ([function isEqualToString:@"adminUpdateAllStixOrders"]) {
        [k getAllUsers];
    }
    else if ([function isEqualToString:@"adminUpdateAllFriendsLists"]) {
        [k getAllUsers];
    }
    else if ([function isEqualToString:@"sharePix"]) {
        assert([params count] == 1);
        [k savePixWithPixPNG:[params objectAtIndex:0]];
    }
    else if ([function isEqualToString:@"adminSaveTagUpdateInfo"]) {
        [k getAllTags];
        //[k getAllTagsWithIDGreaterThanWithAllTagID:490 andNumTags:[NSNumber numberWithInt:5]];
    }
}

-(void)execute:(NSString*)_function {
    [self execute:_function withParams:nil withCallback:nil withDelegate:nil];
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation savePixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, nil];
    if (sharedKumulosHelper.delegate)
        [sharedKumulosHelper.delegate kumulosHelperDidCompleteWithCallback:sharedKumulosHelper.callback andParams:returnParams];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
    if ([sharedKumulosHelper.function isEqualToString:@"adminUpdateAllStixOrders"]) {
        // recreates stixOrder completely. this fixes several problems:
        // if stixOrder is repeated
        // if stixOrder exists for a stix that is at 0 counts
        // if stixOrder does not exist for a user
        // we don't check for validity of stixOrder so we just reset everything
        NSLog(@"Total users: %d", [theResults count]);
        for (NSMutableDictionary * d in theResults) {
            NSString * username = [d objectForKey:@"username"];
            NSMutableDictionary * stix = [[KumulosData dataToDictionary:[d objectForKey:@"stix"]] retain];
            NSLog(@"User %@ has %d stix", username, [stix count]);
            NSMutableDictionary * auxiliaryData = [[NSMutableDictionary alloc] init];
            int ret = [KumulosData extractAuxiliaryDataFromUserData:d intoAuxiliaryData:auxiliaryData];
            NSMutableSet * friendsList;
            if (ret == 0) { // all are present
                friendsList = [auxiliaryData objectForKey:@"friendsList"];
            }
            else if (ret == 1) { // stixOrder is missing
                friendsList = [auxiliaryData objectForKey:@"friendsList"];
            }
            else if (ret == 2) { // friendsList is missing
                friendsList = [[NSMutableSet alloc] init];
            }
            else if (ret == -1) { // all are missing
                friendsList = [[NSMutableSet alloc] init];
            }
            NSMutableDictionary * stixOrder = [[NSMutableDictionary alloc] init];
            NSEnumerator *e = [stix keyEnumerator];
            id key;
            int total = 0;
            [stixOrder setValue:[NSNumber numberWithInt:total++] forKey:@"FIRE"];
            [stixOrder setValue:[NSNumber numberWithInt:total++] forKey:@"ICE"];
            while (key = [e nextObject]) {
                if ([key isEqualToString:@"FIRE"] || [key isEqualToString:@"ICE"])
                    continue;
                //NSLog(@"Key: %@ count: %d", key, [[stix objectForKey:key] intValue]);
                if ([[stix objectForKey:key] intValue] != 0) {
                    [stixOrder setValue:[NSNumber numberWithInt:total++] forKey:key];
                    //NSLog(@"user %@ stix %d %@ stixOrders %d", username, total, key, [stixOrder count]);
                }
            }

            NSMutableDictionary * auxiliaryDict = [[NSMutableDictionary alloc] init];
            [auxiliaryDict setObject:stixOrder forKey:@"stixOrder"];
            [auxiliaryDict setObject:friendsList forKey:@"friendsList"];
            NSMutableData * newAuxData = [[KumulosData dictionaryToData:auxiliaryDict] retain];
            NSLog(@"User %@ now has %d stix and %d stixOrders and %d friends", username, [stix count], [stixOrder count], [friendsList count]);
            [sharedKumulosHelper.k updateAuxiliaryDataWithUsername:username andAuxiliaryData:newAuxData];
        }
    }
    else if ([sharedKumulosHelper.function isEqualToString:@"adminUpdateAllFriendsLists"]) {
        // recreates stixOrder completely. this fixes several problems:
        // if stixOrder is repeated
        // if stixOrder exists for a stix that is at 0 counts
        // if stixOrder does not exist for a user
        // we don't check for validity of stixOrder so we just reset everything
        NSLog(@"Total users: %d", [theResults count]);
        for (NSMutableDictionary * d in theResults) {
            NSString * username = [d objectForKey:@"username"];
            NSMutableDictionary * stix = [[KumulosData dataToDictionary:[d objectForKey:@"stix"]] retain];
            NSLog(@"User %@ has %d stix", username, [stix count]);
            NSMutableDictionary * auxiliaryData = [[NSMutableDictionary alloc] init];
            int ret = [KumulosData extractAuxiliaryDataFromUserData:d intoAuxiliaryData:auxiliaryData];
            NSMutableDictionary * stixOrder;
            if (ret == 0) { // all are present
                stixOrder = [auxiliaryData objectForKey:@"stixOrder"];
            }
            else if (ret == 1) { // stixOrder is missing
                stixOrder = [[NSMutableDictionary alloc] init];
            }
            else if (ret == 2) { // friendsList is missing
                stixOrder = [auxiliaryData objectForKey:@"stixOrder"];
            }
            else if (ret == -1) { // all are missing
                stixOrder = [[NSMutableDictionary alloc] init];
            }
            NSMutableSet * friendsList = [[NSMutableSet alloc] init];
            [friendsList addObject:@"bobo"];
            [friendsList addObject:@"willh103"];
            
            NSMutableDictionary * auxiliaryDict = [[NSMutableDictionary alloc] init];
            [auxiliaryDict setObject:stixOrder forKey:@"stixOrder"];
            [auxiliaryDict setObject:friendsList forKey:@"friendsList"];
            NSMutableData * newAuxData = [[KumulosData dictionaryToData:auxiliaryDict] retain];
            NSLog(@"User %@ now has %d stix and %d stixOrders and %d friends", username, [stix count], [stixOrder count], [friendsList count]);
            [sharedKumulosHelper.k updateAuxiliaryDataWithUsername:username andAuxiliaryData:newAuxData];
        }
    }
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray *)theResults {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsDidCompleteWithResult:(NSArray *)theResults {
    /*
     * update all tag info
     * extract time last updated or time created
     * save it to allTagsInfos table
     */
    if ([sharedKumulosHelper.function isEqualToString:@"adminSaveTagUpdateInfo"]) {
        for (NSMutableDictionary * d in theResults) {
            NSDate * timeUpdated = [d objectForKey:@"timeUpdated"];
            NSDate * timeCreated = [d objectForKey:@"timeCreated"];
            NSNumber * allTagID = [d objectForKey:@"allTagID"];
            NSLog(@"Most recent timestamp for id %d: %@", [allTagID intValue], [timeUpdated laterDate:timeCreated]);
            //[kumulos createPixTimestampWithAllTagID:[allTagID intValue] andLastUpdated:[timeUpdated laterDate:timeCreated]];
//            [kumulos updatePixTimestampWithAllTagID:[allTagID intValue] andLastUpdated:[timeUpdated laterDate:timeCreated]];
        }
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updatePixTimestampDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"rows: %d", [affectedRows intValue]);
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createPixTimestampDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"rows: %d", [affectedRows intValue]);
}

@end