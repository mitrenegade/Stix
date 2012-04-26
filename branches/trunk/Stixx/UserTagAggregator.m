//
//  UserTagAggregator.m
//  Stixx
//
//  Created by Bobby Ren on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserTagAggregator.h"

@implementation UserTagAggregator

@synthesize k;
@synthesize allUsernamesOfTagIDs, allTagIDs;
@synthesize delegate;
@synthesize aggregationQueue;

-(id)init {
    self = [super init];
    if (self) {
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
        allTagIDs = [[NSMutableArray alloc] init];
        allUsernamesOfTagIDs = [[NSMutableDictionary alloc] init];

        backgroundQueue = dispatch_queue_create("com.Neroh.Stix.stixApp.aggregator", NULL);
        
        // create queue of tagIDs to insert in background
        aggregationQueue = [[NSMutableArray alloc] init];
        [self processAggregationQueueInBackground]; 
        
        idOfNewestTagAggregated = -1;
        followingCountLeftToAggregate = 0; // keep track of whether all friends have been aggregated
        isFirstTimeAggregating = YES;
        firstTimeAggregatingTrigger = 0;
        
    }
    return self;
}
-(int)getNewestTag {return idOfNewestTagAggregated;}
-(int)getOldestTag {
    if ([allTagIDs count] == 0)
        return -1;
    return [[allTagIDs objectAtIndex:0] intValue];
}
-(void)resetFirstTimeState {
    idOfNewestTagAggregated = -1;
    isFirstTimeAggregating = YES;
}

-(void)startAggregatingTagIDs {
    if (![delegate isLoggedIn])
        return;
    NSMutableSet * allFollowing = [delegate getFollowingList];
    NSMutableSet * followingSetWithMe = [[NSMutableSet alloc] initWithSet:allFollowing];
    [followingSetWithMe addObject:[delegate getUsername]];
    NSLog(@"StartAggregatingTagIDs: You are following %d people", [allFollowing count]);
    for (NSString * name in followingSetWithMe) {
        NSLog(@"Aggregating tags for followed user: %@", name);
        //[self aggregateTagIDsForUser:name];
        [k getAllPixBelongingToUserWithUsername:name];
    }
    [followingSetWithMe release];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllPixBelongingToUserDidCompleteWithResult:(NSArray *)theResults {
    
    NSLog(@"getAllPixBelongingToUser completed with %d results", [theResults count]);
    [aggregationQueue addObjectsFromArray:theResults];
}

// TODO: first time aggregate happens, notify delegate

-(void)aggregateNewTagIDs {
    if (![delegate isLoggedIn]) {
        NSLog(@"Trying to aggregate tagIDs for following list but user is not logged in!");
        return;
    }
    NSMutableSet * allFollowing = [delegate getFollowingList];
    NSMutableSet * followingSetWithMe = [[NSMutableSet alloc] initWithSet:allFollowing];
    [followingSetWithMe addObject:[delegate getUsername]];
    followingCountLeftToAggregate = [allFollowing count];
    NSLog(@"AggregateNewTagIDs: You are following %d people", [allFollowing count]);
    for (NSString * name in followingSetWithMe) {
        NSNumber * newestTagID = [NSNumber numberWithInt:idOfNewestTagAggregated]; //[allTagIDs objectAtIndex:0]; 
        NSLog(@"Aggregating new tags for followed user: %@ newer than %d", name, [newestTagID intValue]);
        [k getNewPixBelongingToUserWithUsername:name andTagID:[newestTagID intValue]];
    }    
    [followingSetWithMe release];
}

-(void)reaggregateTagIDs {
    // resets everything in case friends changed
    if (![delegate isLoggedIn])
        return;
    [allTagIDs removeAllObjects];
    NSMutableSet * allFollowing = [delegate getFollowingList];
    NSMutableSet * followingSetWithMe = [[NSMutableSet alloc] initWithSet:allFollowing];
    [followingSetWithMe addObject:[delegate getUsername]];
    followingCountLeftToAggregate = [allFollowing count];
    NSLog(@"ReaggregatingTagIDs: You are following %d people", [allFollowing count]);
    for (NSString * name in followingSetWithMe) {
        int newestTagID = -1; //[allTagIDs objectAtIndex:0]; 
        NSLog(@"Aggregating new tags for followed user: %@ newer than %d", name, newestTagID);
        [k getNewPixBelongingToUserWithUsername:name andTagID:newestTagID];
    }    
    [followingSetWithMe release];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getNewPixBelongingToUserDidCompleteWithResult:(NSArray *)theResults {
    
    NSLog(@"getNewPixBelongingToUser completed with %d results - %d users remaining", [theResults count], followingCountLeftToAggregate-1);
    [aggregationQueue addObjectsFromArray:theResults];
    
    followingCountLeftToAggregate--;
    if (followingCountLeftToAggregate == 0) {
        [delegate dismissAggregateIndicator]; // if used pull to refresh, dismiss that
        if (isFirstTimeAggregating) {
            NSLog(@"UserAggregator setting trigger for firstTimeAggregating");
            firstTimeAggregatingTrigger = 1;
            isFirstTimeAggregating = NO;
        }
    }
}

-(void)processAggregationQueueInBackground {
    // run continuous while loop in separate background thread
    dispatch_async(backgroundQueue, ^(void) {                
        while (1) {
            if ([aggregationQueue count]>0) {
                // insert sorted
                // assumes allTagIDs is sorted in ascending
                //NSLog(@"Current aggregationQueue count %d", [aggregationQueue count]);
                NSMutableDictionary * d = [[aggregationQueue objectAtIndex:0] retain];
                if (d != nil) {
                    [aggregationQueue removeObject:d];
                    //NSString * username = [d valueForKey:@"username"];
                    NSNumber * tagID = [d valueForKey:@"tagID"];
                    NSLog(@"Aggregating queue now size %d tagID %d idOfNewestTagAggregated %d trigger %d", [aggregationQueue count], [tagID intValue], idOfNewestTagAggregated, firstTimeAggregatingTrigger);
                    
                    id newObject = tagID;
                    NSComparator comparator = ^(id obj1, id obj2) {
                        return [obj1 compare: obj2];
                    };
                    
                    if ([allTagIDs containsObject:tagID]) {
                        NSLog(@"allTagIDs contains object");
                        continue;
                    }
                    if (!newObject) {
                        [k addMetricWithDescription:@"Invalid Aggregation Tag" andUsername:[delegate getUsername] andStringValue:[d valueForKey:@"username"] andIntegerValue:[tagID intValue]];
                        continue;
                    }
                    
                    NSUInteger newIndex = [allTagIDs indexOfObject:newObject
                                                     inSortedRange:(NSRange){0, [allTagIDs count]}
                                                           options:NSBinarySearchingInsertionIndex
                                                   usingComparator:comparator];
                    if (newIndex < [allTagIDs count]) {
                        if ([[allTagIDs objectAtIndex:newIndex] intValue] != [tagID intValue])
                            [allTagIDs insertObject:newObject atIndex:newIndex];
                    }
                    else
                        [allTagIDs insertObject:newObject atIndex:newIndex];
                    
                    //NSLog(@"Aggregation queue: processed tagID %d username %@ index %d, remaining %d, allTagID size %d", [tagID intValue], username, newIndex, [aggregationQueue count], [allTagIDs count]);
                    
                    // set new most recent tagID
                    if ([tagID intValue] > idOfNewestTagAggregated) {
                        NSLog(@"Aggregator: newest tagID found: %d old newestTagID: %d", [tagID intValue], idOfNewestTagAggregated);
                        idOfNewestTagAggregated = [tagID intValue];
                    }
                    
                    if (firstTimeAggregatingTrigger == 1 && [aggregationQueue count] == 0) {
                        // triggers "completion" of aggregator initially
                        // the highest id in this should be the most recent tagID for this user's following list
                        NSLog(@"FirstTimeAggregatingTrigger fired; allTagIDs now %d", [allTagIDs count]);
                        [delegate didFinishAggregation:YES];
                        firstTimeAggregatingTrigger = 0;
                    }
                    //                else
                    //                    NSLog(@"ProcessAggregationQueue: aggregation queue object is nil! Error??");
                }
            }
        }        
    }); // end of dispatch_async
}

-(void)displayState {
    NSLog(@"****Aggregator State ****");
    NSMutableSet * allFollowing = [delegate getFollowingList];
    NSLog(@"Following people: %@", allFollowing);
    NSLog(@"AllTagIDs: %@", allTagIDs);
    NSLog(@"idOfNewestTagAggregated: %d", idOfNewestTagAggregated);
}

-(NSArray*)getTagIDsGreaterThanTagID:(int)tagID totalTags:(int)numTags {
    if ([allTagIDs count] == 0)
        return nil;
    
    // allTagIDs are ordered ascending
    // debug
    //NSLog(@"GetTagIDGreaterThan %d in AllTagIDs: %@", tagID, allTagIDs);

    NSUInteger newIndex = [allTagIDs indexOfObject:[NSNumber numberWithInt:tagID]
                                     inSortedRange:(NSRange){0, [allTagIDs count]}
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:^(id obj1, id obj2) {
                                       return [obj1 compare: obj2];
                                   }];
    if (newIndex == NSNotFound)
        NSLog(@"Tag not found, index returned %d", newIndex);
    
    if (newIndex > [allTagIDs count] -1)
        //return nil; // requesting tag that is above what we have - return nothing
        newIndex = [allTagIDs count]-1;
    
    NSUInteger start = newIndex +1;
    if ([allTagIDs count]==0) {
        NSLog(@"AllTagIDs empty!");
    }
    if (tagID < [[allTagIDs objectAtIndex:newIndex] intValue])
        start = newIndex;
    else if (tagID == [[allTagIDs objectAtIndex:newIndex] intValue])
        start = newIndex+1;
    NSUInteger end = MIN([allTagIDs count]-1, start+numTags);
    if (numTags == -1)
        end = [allTagIDs count]-1;
    if (end<start || start>[allTagIDs count]-1) {
        NSLog(@"Aggregator getTagIDsMoreThan %d has no range: newIndex %d of total %d", tagID, newIndex, [allTagIDs count]-1);
        return nil;
    }
    
    if (numTags == -1)
        end = [allTagIDs count]-1;
    NSRange range = (NSRange){start, end-start+1};
    NSLog(@"Aggregator getTagIDsGreaterThanTagID %d newIndex %d allTagIDs %d range start %d end %d", tagID, newIndex, [allTagIDs count], start, end);
    @try {
        NSArray * ret = [allTagIDs subarrayWithRange:range];        
        for (int i=0; i<[ret count]; i++) {
            NSLog(@"Aggregated tagIDs greater than %d: tag %d = %d ", tagID, i, [[ret objectAtIndex:i] intValue]);
            return ret;
        }
    } @catch (NSException * e) {
        NSLog(@"getTagIDs: NSRange error %@", [e reason]);
    }
    return nil;
}

-(NSArray*)getTagIDsLessThanTagID:(int)tagID totalTags:(int)numTags {
    if ([allTagIDs count] == 0)
        return nil;
    
    // debug
    //NSLog(@"GetTagIDLessThan %d in AllTagIDs: %@", tagID, allTagIDs);
    
    // allTagIDs are ordered ascending
    
    NSUInteger newIndex = [allTagIDs indexOfObject:[NSNumber numberWithInt:tagID]
                                 inSortedRange:(NSRange){0, [allTagIDs count]}
                                       options:NSBinarySearchingInsertionIndex
                                   usingComparator:^(id obj1, id obj2) {
                                       return [obj1 compare: obj2];
                                   }];
    if (newIndex == NSNotFound)
        NSLog(@"Tag not found, index returned %d", newIndex);
    
    int end = newIndex - 1;
    int start = MAX(0, newIndex - numTags);
    if (start<0)
        start=0;
    if (end<start || end<0) {
        NSLog(@"Aggregator getTagIDSLessThan %d has no range: newIndex %d", tagID, newIndex);
        return nil;
    }

    if (numTags == -1)
        start = 0;
    NSRange range = (NSRange){start, end-start+1};
    NSLog(@"Aggregator getTagIDsLessThanTagID %d newIndex %d allTagIDs %d range start %d end %d", tagID, newIndex, [allTagIDs count], start, end);
    @try {
        NSArray * ret = [allTagIDs subarrayWithRange:range];        
        for (int i=0; i<[ret count]; i++) {
            NSLog(@"Aggregated tagIDs less than %d: tag %d = %d ", tagID, i, [[ret objectAtIndex:i] intValue]);
            return ret;
        }
    } @catch (NSException * e) {
        NSLog(@"getTagIDs: NSRange error %@", [e reason]);
    }
    return nil;
}


@end