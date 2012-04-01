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
@synthesize inputParams;

/*
static KumulosHelper *sharedKumulosHelper = nil;
+(KumulosHelper*)sharedKumulosHelper 
{
	if (!sharedKumulosHelper){
		sharedKumulosHelper = [[KumulosHelper alloc] init];
	}
	return sharedKumulosHelper;
}
*/

// KumulosHelper should not be a singleton!

-(id)init
{
	self = [super init];
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    
    savedInfo = [[NSMutableDictionary alloc] init];
	return self;
}

-(void)execute:(NSString*)_function withParams:(NSMutableArray*)params withCallback:(SEL)_callback withDelegate:(NSObject<KumulosHelperDelegate>*)helperDelegate{
    [self setInputParams:params];
    [self setFunction:_function];
    [self setCallback:_callback];
    delegate = helperDelegate;
    if ([function isEqualToString:@"adminUpdateAllStixOrders"]) {
        [k getAllUsers];
    }
    else if ([function isEqualToString:@"adminUpdateAllFriendsLists"]) {
        [k getAllUsers];
    }
    else if ([function isEqualToString:@"getAllUsersForUpdatePhotos"]) {
        [k getAllUsers];
    }
    else if ([function isEqualToString:@"sharePix"]) {
        assert([inputParams count] == 1);
        [k savePixWithPixPNG:[inputParams objectAtIndex:0]];
    }
    else if ([function isEqualToString:@"getSubcategories"]) {
        [k getAllCategories];
    }
    else if ([function isEqualToString:@"getCommentHistory"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        [k getAllHistoryWithTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"addCommentToPix"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * name = [inputParams objectAtIndex:1];
        NSString * comment = [inputParams objectAtIndex:2];
        NSString * stixStringID = [inputParams objectAtIndex:3];
        [k addCommentToPixWithTagID:[tagID intValue] andUsername:name andComment:comment andStixStringID:stixStringID];
        
        [savedInfo setObject:tagID forKey:@"addCommentToPix_tagID"];
    }
    else if ([function isEqualToString:@"getFacebookUser"]) {
        NSNumber * fbID = [inputParams objectAtIndex:0];
        NSLog(@"Calling kumulos getFaceBookUser with id %d", [fbID intValue]);
        [k getFacebookUserWithFacebookID:[fbID intValue]];
    }
}

-(void)execute:(NSString*)_function {
    [self execute:_function withParams:nil withCallback:nil withDelegate:nil];
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation savePixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, nil];
    if (self.delegate)
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
    if ([self.function isEqualToString:@"adminUpdateAllStixOrders"]) {
        // recreates stixOrder completely. this fixes several problems:
        // if stixOrder is repeated
        // if stixOrder exists for a stix that is at 0 counts
        // if stixOrder does not exist for a user
        // we don't check for validity of stixOrder so we just reset everything
        NSString * username = @"";
        NSLog(@"Total users: %d", [theResults count]);
        for (NSMutableDictionary * d in theResults) {
            username = [d objectForKey:@"username"];
            NSMutableDictionary * stix = [[KumulosData dataToDictionary:[d objectForKey:@"stix"]] retain];
            NSLog(@"User %@ has %d stix", username, [stix count]);
            NSMutableDictionary * auxiliaryData = [[NSMutableDictionary alloc] init];
            /*
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
             */
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
            //[auxiliaryDict setObject:friendsList forKey:@"friendsList"];
            NSMutableData * newAuxData = [[KumulosData dictionaryToData:auxiliaryDict] retain];
            NSLog(@"User %@ now has %d stix and %d stixOrders", username, [stix count], [stixOrder count]);
            [k updateAuxiliaryDataWithUsername:username andAuxiliaryData:newAuxData];
        }
    }
    else if ([self.function isEqualToString:@"adminUpdateAllFriendsLists"]) {
        // recreates stixOrder completely. this fixes several problems:
        // if stixOrder is repeated
        // if stixOrder exists for a stix that is at 0 counts
        // if stixOrder does not exist for a user
        // we don't check for validity of stixOrder so we just reset everything
        /*
        NSLog(@"Total users: %d", [theResults count]);
        NSString * username = @"";
        for (NSMutableDictionary * d in theResults) {
            username = [d objectForKey:@"username"];
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
         */
    }
    else if (self.delegate && [function isEqualToString:@"getAllUsersForUpdatePhotos"]) {
        //NSLog(@"KumulosHelper finished getting all users photos: %d photos", [theResults count]);
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];         
//        [theResults release];
        //NSLog(@"return params: %@", returnParams);
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];        
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updatePixTimestampDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"rows: %d", [affectedRows intValue]);
    [self cleanup];
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createPixTimestampDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"rows: %d", [affectedRows intValue]);
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllCategoriesDidCompleteWithResult:(NSArray *)theResults {
    if ([self.function isEqualToString:@"getSubcategories"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];
        if (self.delegate)
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    }
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllHistoryDidCompleteWithResult:(NSArray *)theResults {
    if ([self.function isEqualToString:@"getCommentHistory"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
    }
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addCommentToPixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSNumber * tagID = [savedInfo objectForKey:@"addCommentToPix_tagID"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, nil];
    if (self.delegate) {
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    }
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithArray:theResults];
    if (self.delegate) {
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    }
    [self cleanup];
}

#pragma mark error handling for kumulos helper
-(void)kumulosAPI:(kumulosProxy *)kumulos apiOperation:(KSAPIOperation *)operation didFailWithError:(NSString *)theError {
    NSLog(@"KumulosHelper failed during function: %@", function);
    
    // retry if desired
    if ([function isEqualToString:@"getFacebookUser"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(kumulosHelperGetFacebookUserDidFail)])
            [self.delegate kumulosHelperGetFacebookUserDidFail];
    }
    else if ([function isEqualToString:@"getAllUsersForUpdatePhotos"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    [self cleanup];
}

-(void)cleanup {
    [inputParams release];
}

@end
