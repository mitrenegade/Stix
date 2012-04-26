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
-(void)didFinishAggregation:(BOOL)isFirstTime;
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
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) NSMutableArray * allTagIDs;
@property (nonatomic, retain) NSMutableDictionary * allUsernamesOfTagIDs;
@property (nonatomic, assign) NSObject<UserTagAggregatorDelegate> * delegate;
@property (nonatomic, retain) NSMutableArray * aggregationQueue;

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
@end
