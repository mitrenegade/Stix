//
//  UserTagAggregator.h
//  Stixx
//
//  Created by Bobby Ren on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"

@protocol UserTagAggregatorDelegate <NSObject>

-(NSMutableSet*)getFollowingList;
-(void)didStartAggregationWithTagID:(NSNumber*)tagID;
-(void)didFinishAggregation:(BOOL)isFirstTime;
-(void)didSetAggregationTrigger;
-(void)dismissAggregateIndicator;
-(NSString*)getUsername;
-(BOOL)isLoggedIn;
@end

@interface UserTagAggregator : NSObject <KumulosDelegate>
{
    int idOfNewestTagAggregated;
    int followingCountLeftToAggregate;
    BOOL isFirstTimeAggregating;
    int firstTimeAggregatingTrigger; // when all friends have been added to the aggregator queue for the first time, this trigger is set to 1 so that when the aggregator queue empties, we know the tagID is in order with the most recent tag in it
    
    BOOL aggregationGetTagRequested; // first time a friend's tag has been found, tell delegate to download that tag
    NSMutableDictionary * userTagList;
}

@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) NSMutableArray * allTagIDs;
@property (nonatomic, retain) NSMutableDictionary * allUsernamesOfTagIDs;
@property (nonatomic, assign) NSObject<UserTagAggregatorDelegate> * delegate;
@property (nonatomic, retain) NSMutableArray * aggregationQueue;
@property (nonatomic, retain) NSMutableDictionary * usernameForOperations;

-(void)processAggregationQueueInBackground;
-(void)startAggregatingTagIDs;
-(void)aggregateNewTagIDs;
-(void)reaggregateTagIDs;
-(NSArray*)getTagIDsGreaterThanTagID:(int)tagID totalTags:(int)numTags;
-(NSArray*)getTagIDsLessThanTagID:(int)tagID totalTags:(int)numTags;
-(int)getNewestTag; 
-(int)getOldestTag;
-(void)displayState;
-(void)resetFirstTimeState;
-(void)loadCachedUserTagListForUsers;
-(void)insertNewTagID:(NSNumber*)tagID;
@end
