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

static NSMutableSet * retainedHelpers;

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
    
    if (retainedHelpers == nil)
        retainedHelpers = [[NSMutableSet alloc] init];
    
	return self;
}

-(void)execute:(NSString*)_function withParams:(NSMutableArray*)params withCallback:(SEL)_callback withDelegate:(NSObject<KumulosHelperDelegate>*)helperDelegate{
    
    [retainedHelpers addObject:self];
    
    [self setInputParams:params];
    [self setFunction:_function];
    [self setCallback:_callback];
    NSLog(@"KumulosHelper executing %@", _function);
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
    else if ([function isEqualToString:@"addCommentToPixWithDetailViewController"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * name = [inputParams objectAtIndex:1];
        NSString * comment = [inputParams objectAtIndex:2];
        NSString * stixStringID = [inputParams objectAtIndex:3];
        DetailViewController * detailViewController = [inputParams objectAtIndex:4];
        [k addCommentToPixWithTagID:[tagID intValue] andUsername:name andComment:comment andStixStringID:stixStringID];
        
        [savedInfo setObject:tagID forKey:@"addCommentToPix_tagID"];
        [savedInfo setObject:detailViewController forKey:@"addCommentToPix_detailViewController"];
    }
    else if ([function isEqualToString:@"getFacebookUser"]) {
        NSNumber * fbID = [inputParams objectAtIndex:0];
        NSLog(@"Calling kumulos getFaceBookUser with id %d", [fbID intValue]);
        [k getFacebookUserWithFacebookID:[fbID intValue]];
    }
    else if ([function isEqualToString:@"addPixBelongsToUser"]) {
        NSString * username = [inputParams objectAtIndex:0];
        NSNumber * tagID = [inputParams objectAtIndex:1];
        NSLog(@"addPixBelongsToUser: %@ tagID %d", username, [tagID intValue]);
        [savedInfo setObject:username forKey:@"addPixBelongsToUser_username"];
        [savedInfo setObject:tagID forKey:@"addPixBelongsToUser_tagID"];
        [k addPixBelongsToUserWithUsername:username andTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"checkForUpdatedStix"]) {
        void * tag = [inputParams objectAtIndex:0];
        NSNumber * tagID = [inputParams objectAtIndex:1];
        [savedInfo setObject:tag forKey:@"tag"];
        //[k getAllHistoryWithTagID:[tagID intValue]];
        [k getAllAuxiliaryStixWithTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"updateStixForPix"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        [savedInfo setObject:tagID forKey:@"tagID"];
        [k getAllTagsWithIDRangeWithId_min:[tagID intValue]-1 andId_max:[tagID intValue]+1];
    }
    else if ([function isEqualToString:@"getAuxiliaryStixOfTag"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        [savedInfo setObject:tagID forKey:@"tagID"];
        [k getAllAuxiliaryStixWithTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"removeAuxiliaryStix"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * stixStringID = [inputParams objectAtIndex:1];
        CGPoint location = [[inputParams objectAtIndex:2] CGPointValue];
        [savedInfo setObject:tagID forKey:@"tagID"];
        [k removeAuxiliaryStixFromPixWithTagID:[tagID intValue] andStixStringID:stixStringID andX:location.x andY:location.y];
    }
    else if ([function isEqualToString:@"createNewPix"]) {
        Tag * newTag = [inputParams objectAtIndex:0];
        NSData * theImgData = UIImageJPEGRepresentation([newTag image], .8); 
        KSAPIOperation * kOP = [k createNewPixWithUsername:newTag.username andDescriptor:newTag.descriptor andComment:newTag.comment andLocationString:newTag.locationString andImage:theImgData andTagCoordinate:nil andPendingID:[newTag.tagID intValue]];
        //[kOP setDelegate:self];
        //[kOP setDebugMode:YES];
    }
}

-(void)execute:(NSString*)_function {
    [self execute:_function withParams:nil withCallback:nil withDelegate:nil];
}

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createNewPixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, nil];
    if (self.delegate)
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    [returnParams autorelease];
    [self cleanup];
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation savePixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, nil];
    if (self.delegate)
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    [returnParams autorelease];
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllAuxiliaryStixDidCompleteWithResult:(NSArray *)theResults {
    if ([function isEqualToString:@"getAuxiliaryStixOfTag"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:[savedInfo objectForKey:@"tagID"], theResults, nil];         
        [delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];        
        [returnParams autorelease];
    }
    else if ([function isEqualToString:@"checkForUpdatedStix"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] init];
        Tag * tag = [savedInfo objectForKey:@"tag"];
        [returnParams addObject:[savedInfo objectForKey:@"tag"]];
        [returnParams addObject:theResults];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
        [returnParams autorelease];
    }

    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation removeAuxiliaryStixFromPixDidCompleteWithResult:(NSArray *)theResults {
    // also returns the remaining stix
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:[savedInfo objectForKey:@"tagID"], theResults, nil];         
    [delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];        
    [returnParams autorelease];
    [self cleanup];
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
            //NSMutableDictionary * auxiliaryData = [[NSMutableDictionary alloc] init];
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
            while (key = [e nextObject]) {
                if ([[stix objectForKey:key] intValue] != 0) {
                    [stixOrder setValue:[NSNumber numberWithInt:total++] forKey:key];
                }
            }

            NSMutableDictionary * auxiliaryDict = [[NSMutableDictionary alloc] init];
            [auxiliaryDict setObject:stixOrder forKey:@"stixOrder"];
            //[auxiliaryDict setObject:friendsList forKey:@"friendsList"];
            NSMutableData * newAuxData = [[KumulosData dictionaryToData:auxiliaryDict] retain];
            NSLog(@"User %@ now has %d stix and %d stixOrders", username, [stix count], [stixOrder count]);
            [k updateAuxiliaryDataWithUsername:username andAuxiliaryData:newAuxData];
            
            [stix release];
            [stixOrder release];
            [auxiliaryDict release];
            [newAuxData autorelease];
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
        [delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];        
        [returnParams autorelease];
    }

    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updatePixTimestampDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"rows: %d", [affectedRows intValue]);
    [self cleanup];
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createPixTimestampDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"rows: %d", [affectedRows intValue]);
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addPixBelongsToUserDidCompleteWithResult:(NSNumber *)newRecordID {
    NSString * username = [savedInfo objectForKey:@"addPixBelongsToUser_username"];
    NSNumber * tagID = [savedInfo objectForKey:@"addPixBelongsToUser_tagID"];
    NSLog(@"addPixBelongsToUser completed for user %@ tagID %d record id %d", username, [tagID intValue], [newRecordID intValue]);
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllCategoriesDidCompleteWithResult:(NSArray *)theResults {
    if ([self.function isEqualToString:@"getSubcategories"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];
        if (self.delegate)
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        [returnParams autorelease];
    }
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllHistoryDidCompleteWithResult:(NSArray *)theResults {
    if ([self.function isEqualToString:@"getCommentHistory"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
        [returnParams autorelease];
    }
    /*
    else if ([function isEqualToString:@"checkForUpdatedStix"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] init];
        [returnParams addObject:[savedInfo objectForKey:@"tag"]];
        [returnParams addObjectsFromArray:theResults];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
        [returnParams autorelease];
    }
     */
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addCommentToPixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSNumber * tagID = [savedInfo objectForKey:@"addCommentToPix_tagID"];
    if ([function isEqualToString:@"addCommentToPix"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, nil];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
        [returnParams autorelease];
    }    
    else if ([function isEqualToString:@"addCommentToPixWithDetailViewController"]) {
        DetailViewController * detailViewController = [savedInfo objectForKey:@"addCommentToPix_detailViewController"];        
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, detailViewController, nil];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
        [returnParams autorelease];
    }
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray *)theResults {
    NSNumber * tagID = [savedInfo objectForKey:@"tagID"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, theResults, nil];
    if (self.delegate) {
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    }
    [returnParams autorelease];
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithArray:theResults];
    if (self.delegate) {
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    }
    [returnParams autorelease];
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
    else if ([function isEqualToString:@"createNewPix"]) {
        // NOT coming here so we create some other timeout
        if (self.delegate && [delegate respondsToSelector:@selector(kumulosHelperCreateNewPixDidFail:)]) {
            Tag * failedTag = [inputParams objectAtIndex:0];
            [delegate kumulosHelperCreateNewPixDidFail:failedTag];
        }
    }
    else if ([function isEqualToString:@"getAuxiliaryStixOfTag"]) {
        // if this happens while we are trying to load galleries, we need 
        // to decrement pendingContentCount
        // instead, redo
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"addPixBelongsToUser"]) {
        NSLog(@"addPixBelongsToUser failed!");
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
}

-(void)cleanup {
    [inputParams release];
    [retainedHelpers removeObject:self];
}

@end
