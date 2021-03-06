//
//  UserTagAggregator.m
//  Stixx
//
//  Created by Bobby Ren on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserTagAggregator.h"
#import "GlobalHeaders.h"

@implementation UserTagAggregator

@synthesize k;
@synthesize allUsernamesOfTagIDs, allTagIDs, usernameForOperations;
@synthesize delegate;
@synthesize aggregationQueue;
@synthesize featuredUsers, remainderSet;
-(id)init {
    self = [super init];
    if (self) {
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
        allTagIDs = [[NSMutableArray alloc] init];
        allUsernamesOfTagIDs = [[NSMutableDictionary alloc] init];
        usernameForOperations = [[NSMutableDictionary alloc] init];
        userTagList = [[NSMutableDictionary alloc] init];
        
        // create queue of tagIDs to insert in background
        aggregationQueue = [[NSMutableArray alloc] init];
        [self processAggregationQueueInBackground]; 
        
        idOfNewestTagAggregated = -1;
        followingCountLeftToAggregate = 0; // keep track of whether all friends have been aggregated
        isFirstTimeAggregating = YES;
        firstTimeAggregatingTrigger = 0;
        aggregationGetTagRequested = NO;
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
        //NSLog(@"Aggregating tags for followed user: %@", name);
        //[self aggregateTagIDsForUser:name];
        [k getAllPixBelongingToUserWithUsername:name];
    }
    [followingSetWithMe release];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllPixBelongingToUserDidCompleteWithResult:(NSArray *)theResults {
    
    //NSLog(@"getAllPixBelongingToUser completed with %d results", [theResults count]);
    [aggregationQueue addObjectsFromArray:theResults];
}

-(void)loadCachedUserTagListForUsers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [userTagList addEntriesFromDictionary:[defaults objectForKey:@"AggregateUserTags"]]; // gets the most recent tag for all friends
    [allTagIDs removeAllObjects];
    [allTagIDs addObjectsFromArray:[defaults objectForKey:@"AggregateTagIDs"]]; // gets the ordered list of friends' tags
    if ([allTagIDs count] > 0 || [userTagList count] > 0) {
        NSLog(@"Loaded cached user tag list with %d users, %d previously aggregated tagIDs", [userTagList count], [allTagIDs count]);
        
        const int TAGS_TO_LOAD = 5;
        if (!aggregationGetTagRequested) {
            for (int j=0; j<TAGS_TO_LOAD; j++) {
                if ([allTagIDs count] > j) {
                    // tell delegate to request a tag to start
                    NSNumber * tagID = [allTagIDs objectAtIndex:([allTagIDs count] - 1 - j)];
                    aggregationGetTagRequested = YES;
                    NSLog(@"First time requesting a friend's tag: %d", [tagID intValue]);            
                    [delegate didStartAggregationWithTagID:tagID];
                }
            }
        }
    }
}
    
// TODO: first time aggregate happens, notify delegate

-(void)aggregateNewTagIDs {
    NSLog(@"Starting aggregateNewTagIDs");
    if (![delegate isLoggedIn]) {
        NSLog(@"Trying to aggregate tagIDs for following list but user is not logged in!");
        return;
    }
    aggregationDebugMessageIdleCount = 0;
    showDebugMessageAfterStartAggregation = YES;
    [self aggregationDebugMessage];
   
    // uncomment this line if you want to skip aggregation for testing
    //return;
    
    NSMutableSet * allFollowing = [delegate getFollowingList];    
    NSMutableSet * followingSetWithMe = [[NSMutableSet alloc] initWithSet:allFollowing];
    [followingSetWithMe addObject:[delegate getUsername]];
    
    followingCountLeftToAggregate = [allFollowing count];
    NSLog(@"AggregateNewTagIDs: You are following %d people", [allFollowing count]);
/*
 int ct = 0;
    for (NSString * name in followingSetWithMe) {
        //NSNumber * newestTagID = [NSNumber numberWithInt:idOfNewestTagAggregated]; //[allTagIDs objectAtIndex:0];
        NSNumber * newestTagID = [userTagList objectForKey:name];
#if VERBOSE
        NSLog(@"Aggregating new tags for followed user: %@ newer than %d", name, [newestTagID intValue]);
#endif
        KSAPIOperation * kOp = [k getNewPixBelongingToUserWithUsername:name andTagID:[newestTagID intValue]];
        [usernameForOperations setObject:name forKey:[NSNumber numberWithInt:[kOp hash]]];
    }    
    [followingSetWithMe release];
 */
    // if any of the followingSet is a featured user, separate that out
    NSLog(@"FollowingSetWithMe has %d elements initially", [followingSetWithMe count]);
    if (!featuredUsers) {
        NSSet * featuredSetFromDelegate = [delegate getFeaturedUserSet];
        NSLog(@"Delegate's featured User set: %@", featuredSetFromDelegate);
        featuredUsers = [[NSMutableSet alloc] initWithSet:[delegate getFeaturedUserSet]];
    }
    else {
        NSSet * featuredSetFromDelegate = [delegate getFeaturedUserSet];
        NSLog(@"Delegate's featured User set: %@", featuredSetFromDelegate);
        [featuredUsers removeAllObjects];
        [featuredUsers unionSet:[delegate getFeaturedUserSet]];
    }
    [featuredUsers addObject:@"William Ho"];
    [featuredUsers addObject:[[delegate getUsername] copy]]; // this must be a copy or we get some weird memory error!
    NSLog(@"FeaturedUsers has %d elements: %@", [featuredUsers count], featuredUsers);
    [featuredUsers intersectSet:followingSetWithMe];
    NSLog(@"FeaturedUsers and FollowingSetWithMe has %d intersections, %@", [featuredUsers count], featuredUsers);
    [followingSetWithMe minusSet:featuredUsers];
    NSLog(@"FollowingSetWithMe minus FeaturedUsers has %d elements", [followingSetWithMe count]);
    if (remainderSet == nil) 
        remainderSet = [[NSMutableSet alloc] init];
    [remainderSet unionSet:followingSetWithMe];
    [self getUserPixForUsers]; 
}

-(void)getUserPixForUsers { //:(NSMutableSet*)followingSetWithMe {
    if (!pauseAggregation) {
        NSString * name = nil;
        //NSLog(@"Featured users left: %@ remainderSet left: %d", featuredUsers, [remainderSet count]);
        if ([featuredUsers count] > 0) {
            NSEnumerator * enumerator = [featuredUsers objectEnumerator];
            name = [enumerator nextObject];
            if (name) {
                // next line causes crash but only in debug mode...???
                NSLog(@"Aggregating new tags for featured user %@", name);
                if ([featuredUsers containsObject:name])
                    [featuredUsers removeObject:name];
            }
        }
        else {
            //NSLog(@"Featured users left: %d remainderSet: %d", [featuredUsers count], [remainderSet count]);
            NSEnumerator * enumerator = [remainderSet objectEnumerator];
            name = [enumerator nextObject];
            if (name)
                if ([remainderSet containsObject:name])
                    [remainderSet removeObject:name];
        }
        
        if (!name)
            return;
        
        NSNumber * newestTagID = [userTagList objectForKey:name];
        
#if VERBOSE
        NSLog(@"Aggregating new tags for followed user: %@ newer than %d", name, [newestTagID intValue]);
#endif
        
        //KSAPIOperation * kOp = [k getNewPixBelongingToUserWithUsername:name andTagID:[newestTagID intValue]];
        KSAPIOperation * kOp = [k getSomeNewPixBelongingToUserWithUsername:name andTagID:[newestTagID intValue] andMaxPix:[NSNumber numberWithInt:50]];
        //[usernameForOperations setObject:name forKey:[NSNumber numberWithInt:[kOp hash]]];
    } else {
        //NSLog(@"getUserPixForUsers paused!");
        [self performSelector:@selector(getUserPixForUsers) withObject:self afterDelay:1];
    }
    
    //if ([remainderSet count] > 0)
    //    [self performSelector:@selector(getUserPixForUsers:) withObject:remainderSet afterDelay:.1];
    
    //[remainderSet autorelease];
    
    // todo: call next friend only after kumulos has returned
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
        //NSLog(@"Aggregating new tags for followed user: %@ newer than %d", name, newestTagID);
        [k getNewPixBelongingToUserWithUsername:name andTagID:newestTagID];
    }    
    [followingSetWithMe release];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getNewPixBelongingToUserDidCompleteWithResult:(NSArray *)theResults {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getSomeNewPixBelongingToUserDidCompleteWithResult:(NSArray *)theResults {
    // followName causes problems
    //NSString * followName = [usernameForOperations objectForKey:[NSNumber numberWithInt:[operation hash]]];
    if ([theResults count] > 0)
    {
        //NSString * followName = [[theResults objectAtIndex:0] objectForKey:@"username"];
#if VERBOSE
        NSLog(@"getNewPixBelongingToUser completed with %d results - %d users remaining, queue size %d", [theResults count], followingCountLeftToAggregate-1, [aggregationQueue count]);
#endif
        isLocked = YES;
        [aggregationQueue addObjectsFromArray:theResults];
        isLocked = NO;

        /*
        if (isFirstTimeAggregating) {
            NSLog(@"UserAggregator setting trigger for firstTimeAggregating");
            firstTimeAggregatingTrigger = 1;
            isFirstTimeAggregating = NO;
            
            // call parse now 
            [delegate didSetAggregationTrigger];
        }
         */
    }
    else {
#if VERBOSE
        if (!isLocked) 
            NSLog(@"getNewPixBelongingToUser returned no results for followingCount %d - queue size %d", followingCountLeftToAggregate-1, [aggregationQueue count]);
#endif
    }
    
    followingCountLeftToAggregate--;
    if (followingCountLeftToAggregate == 0) {
        // we've added all tags for any user to the queue
        // that means we can start downloading those tags
        [delegate dismissAggregateIndicator]; // if used pull to refresh, dismiss that
        
        if (isFirstTimeAggregating) {
            NSLog(@"UserAggregator setting trigger for firstTimeAggregating");
            firstTimeAggregatingTrigger = 1;
            isFirstTimeAggregating = NO;
            
            // call parse now 
            [delegate didSetAggregationTrigger];
        }
        else {
            NSLog(@"UserAggregator trigger is not first time aggregating");
        }
         
        if ([aggregationQueue count] == 0) {
            NSLog(@"No new aggregation to do! trigger something here!");
            
            // hack: sometimes the following lists get downloaded slowly so no content
            // appears
            [delegate didFinishAggregation:YES];
        }
    }
    
    // hack: start next user
    if ([remainderSet count] > 0 || [featuredUsers count] > 0)
        [self performSelector:@selector(getUserPixForUsers) withObject:self afterDelay:0];
}

-(void)kumulosAPI:(kumulosProxy *)kumulos apiOperation:(KSAPIOperation *)operation didFailWithError:(NSString *)theError {
    NSLog(@"UserAggregator kumulos failed: op %@ error %@", [operation description], [theError description]);
}

-(void)insertNewTagID:(NSNumber*)tagID {
    id newObject = tagID;
    NSComparator comparator = ^(id obj1, id obj2) {
        return [obj1 compare: obj2];
    };
    
    if ([allTagIDs containsObject:tagID])
        return;
    
    isLocked = YES;
    
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

    isLocked = NO;
    
    //NSLog(@"Aggregation queue: processed tagID %d username %@ index %d, remaining %d, allTagID size %d", [tagID intValue], username, newIndex, [aggregationQueue count], [allTagIDs count]);
#if VERBOSE
    if ([allTagIDs count]>=3)
    {
        if (newIndex > 0 && newIndex < [allTagIDs count]-1)
            NSLog(@"Inserting tagID %@ into aggregation queue at index %d: queue now %@ %@ %@", tagID, newIndex, [allTagIDs objectAtIndex:newIndex-1], [allTagIDs objectAtIndex:newIndex], [allTagIDs objectAtIndex:newIndex+1]);
        else if (newIndex == 0)
            NSLog(@"Inserting tagID %@ into aggregation queue at head: queue now %@ %@", tagID, [allTagIDs objectAtIndex:newIndex], [allTagIDs objectAtIndex:newIndex+1]);
        else if (newIndex == [allTagIDs count]-1)
            NSLog(@"Inserting tagID %@ into aggregation queue at tail: queue now %@ %@", tagID, [allTagIDs objectAtIndex:newIndex-1], [allTagIDs objectAtIndex:newIndex]);
    }    
#endif
    // set new most recent tagID
    if ([tagID intValue] > idOfNewestTagAggregated) {
        NSLog(@"Aggregator: newest tagID found: %d old newestTagID: %d", [tagID intValue], idOfNewestTagAggregated);
        idOfNewestTagAggregated = [tagID intValue];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:allTagIDs forKey:@"AggregateTagIDs"];
}

-(void)processAggregationQueueInBackground {
    // run continuous while loop in separate background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, (unsigned long)NULL), ^(void) 
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        while (1) {
            if (isLocked)
                continue;
            if (pauseAggregation)
                continue;
            
            if ([aggregationQueue count]>0) {
                // insert sorted
                // assumes allTagIDs is sorted in ascending
                //NSLog(@"Current aggregationQueue count %d", [aggregationQueue count]);
                NSMutableDictionary * d = [[aggregationQueue objectAtIndex:0] retain];
                if (d != nil) {
                    [aggregationQueue removeObject:d];
                    NSString * username = [d valueForKey:@"username"];
                    NSNumber * tagID = [d valueForKey:@"tagID"];
#if VERBOSE
                    NSLog(@"Aggregating queue now size %d user %@ tagID %d idOfNewestTagAggregated %d trigger %d", [aggregationQueue count], username, [tagID intValue], idOfNewestTagAggregated, firstTimeAggregatingTrigger);
#endif     
                    // update userTagList if new tagID is more recent 
                    if ([[userTagList objectForKey:username] intValue] < [tagID intValue]) {
                        [userTagList setObject:tagID forKey:username];
                        [defaults setObject:userTagList forKey:@"AggregateUserTags"];
                        [defaults synchronize];
                    }
                    
                    // insert into sorted array
                    @try {
                        // hack: tagID 9999 was a debug/test number, not valid
                        if ([tagID intValue] == 9999)
                            continue;
                        [self insertNewTagID:tagID];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"UserTagAggregator: Caught enumeration error while inserting tagID %@", tagID);
                        if (!IS_ADMIN_USER([delegate getUsername]))
                            [FlurryAnalytics logEvent:@"AggregationError" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[delegate getUsername], @"username", tagID, @"tagID", nil]];
                    }
#if VERBOSE
                    NSLog(@"Aggregator queue: trigger %d queue size %d", firstTimeAggregatingTrigger, [aggregationQueue count]);
#endif
                    if (firstTimeAggregatingTrigger == 1 && [aggregationQueue count] == 0) {
                        // triggers "completion" of aggregator initially
                        // the highest id in this should be the most recent tagID for this user's following list
                        NSLog(@"FirstTimeAggregatingTrigger fired; allTagIDs now %d", [allTagIDs count]);
                        [delegate didFinishAggregation:YES];
                        firstTimeAggregatingTrigger = 0;
                        showDebugMessageAfterStartAggregation = NO;
                    }
                    //                else
                    //                    NSLog(@"ProcessAggregationQueue: aggregation queue object is nil! Error??");
                    
                    // if there are no cached tagIDs, then we will start loading the first of our friends
                    if (!aggregationGetTagRequested) {
                        // tell delegate to request a tag to start
                        aggregationGetTagRequested = YES;
                        NSLog(@"First time requesting a friend's tag: %@ %d", username, [tagID intValue]);
                        
                        [delegate didStartAggregationWithTagID:tagID];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self delayAggregationForTime:1.5]; // 1.5 seconds should be enough for the first tag to get downloaded
                        });
                        //[self performSelector:@selector(continueAggregation) withObject:self afterDelay:5];
                    }
                }
            }
        }
    }); // end of dispatch_async
}

-(void)displayState {
#if VERBOSE
    NSLog(@"****Aggregator State ****");
    NSMutableSet * allFollowing = [delegate getFollowingList];
    NSLog(@"Following people: %@", allFollowing);
    NSLog(@"AllTagIDs: %@", allTagIDs);
    NSLog(@"idOfNewestTagAggregated: %d", idOfNewestTagAggregated);
#endif
}

-(NSArray*)getTagIDsGreaterThanTagID:(int)tagID totalTags:(int)numTags {
    if ([allTagIDs count] == 0)
        return nil;
    
    // allTagIDs are ordered ascending
    // debug
    NSLog(@"GetTagIDGreaterThan %d, requesting %d tags in AllTagIDs with %d elements", tagID, numTags, [allTagIDs count]); 
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
    
#if VERBOSE
    for (int i=0; i<[allTagIDs count]; i++) {
        NSLog(@"AllTagIDs %d: %d", i, [[allTagIDs objectAtIndex:i] intValue]);
    }
#endif
    
    NSUInteger newIndex;
    NSRange range;
    
    newIndex = [allTagIDs indexOfObject:[NSNumber numberWithInt:tagID]];        
    if (newIndex == NSNotFound) {
        newIndex = [allTagIDs indexOfObject:[NSNumber numberWithInt:tagID]
                              inSortedRange:(NSRange){0, [allTagIDs count]}
                                    options:NSBinarySearchingInsertionIndex
                            usingComparator:^(id obj1, id obj2) {
                                return [obj1 compare: obj2];
                            }];
        NSLog(@"Tag not found, binary search returned index %d", newIndex);
    }
    
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
    range = (NSRange){start, end-start+1};
    NSLog(@"Aggregator getTagIDsLessThanTagID %d newIndex %d allTagIDs %d range start %d end %d", tagID, newIndex, [allTagIDs count], start, end);
        
    @try {
        NSArray * ret = [allTagIDs subarrayWithRange:range];        
        for (int i=0; i<[ret count]; i++) {
            NSLog(@"Aggregated tagIDs less than %d: tag %d = %d ", tagID, i, [[ret objectAtIndex:i] intValue]);
        }
        return ret;
    } @catch (NSException * e) {
        NSLog(@"getTagIDs: NSRange error %@", [e reason]);
    }
    return nil;
}
 
-(void)aggregationDebugMessage {
    // shows debug message every 5 seconds, even without Verbose
    NSLog(@"AggregationDebugMessage: Aggregating queue now size %d idOfNewestTagAggregated %d trigger %d idle count %d", [aggregationQueue count],  idOfNewestTagAggregated, firstTimeAggregatingTrigger, aggregationDebugMessageIdleCount);
    if ([aggregationQueue count] > 0)
        aggregationDebugMessageIdleCount = 0;
    if (showDebugMessageAfterStartAggregation && ([aggregationQueue count] > 0 || aggregationDebugMessageIdleCount < 5)) {
        [self performSelector:@selector(aggregationDebugMessage) withObject:self afterDelay:5];
        if ([aggregationQueue count] == 0)
            aggregationDebugMessageIdleCount++;
    }
    else 
        aggregationDebugMessageIdleCount++; // if queue count is 0, give it some more time to aggregate more numbers for debug display
}

-(void)continueAggregation {
    NSLog(@"Unpausing aggregation!");
    pauseAggregation = NO;
    showDebugMessageAfterStartAggregation = YES;
    aggregationDebugMessageIdleCount = 0;
}

-(void)delayAggregationForTime:(float)timeInSec {
    pauseAggregation = YES;
    NSLog(@"Pausing aggregation for %f seconds", timeInSec);
    [self performSelector:@selector(continueAggregation) withObject:self afterDelay:timeInSec];
}

@end
