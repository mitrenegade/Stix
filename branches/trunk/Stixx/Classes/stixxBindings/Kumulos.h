//
//  Kumulos.h
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on Dec  5, 2011
//  Copyright Neroh All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libKumulos.h"


@class Kumulos;
@protocol KumulosDelegate <kumulosProxyDelegate>
@optional

 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addNewStixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addTagDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminUpdateAllUsersStixCountsDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation deleteTagDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagTimestampDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getMostRecentlyUpdatedTagDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixOfUserDidCompleteWithResult:(NSNumber*)aggregateResult;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updatePixWithStixCountsDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateStixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToQueueDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixUpdateToQueueDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation processStixUpdatesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addEmailToUserDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addUserDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminResetAllStixLevelDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixOfUserForDecrementDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixOfUserForIncrementDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserByIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation setStixLevelDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateTotalTagsDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation userLoginDidCompleteWithResult:(NSArray*)theResults;

@end

@interface Kumulos : kumulosProxy {
    NSString* theAPIKey;
    NSString* theSecretKey;
}

-(Kumulos*)init;
-(Kumulos*)initWithAPIKey:(NSString*)APIKey andSecretKey:(NSString*)secretKey;

   
-(KSAPIOperation*) addNewStixWithUsername:(NSString*)username andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate andType:(NSInteger)type andScore:(NSInteger)score;
    
   
-(KSAPIOperation*) addStixWithUsername:(NSString*)username andComment:(NSString*)comment andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate andType:(NSInteger)type andScore:(NSInteger)score;
    
   
-(KSAPIOperation*) addTagWithUsername:(NSString*)username andComment:(NSString*)comment andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate;
    
   
-(KSAPIOperation*) adminUpdateAllUsersStixCountsWithStixCounts:(NSData*)stixCounts;
    
   
-(KSAPIOperation*) deleteTagWithAllTagID:(NSUInteger)allTagID;
    
   
 -(KSAPIOperation*) getAllTags;
   
-(KSAPIOperation*) getAllTagsWithIDGreaterThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags;
    
   
-(KSAPIOperation*) getAllTagsWithIDLessThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags;
    
   
-(KSAPIOperation*) getAllTagsWithIDRangeWithId_min:(NSUInteger)id_min andId_max:(NSUInteger)id_max;
    
   
-(KSAPIOperation*) getLastTagIDWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getLastTagTimestampWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getMostRecentlyUpdatedTagWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getStixOfUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) updatePixWithStixCountsWithAllTagID:(NSUInteger)allTagID andStixCounts:(NSData*)stixCounts;
    
   
-(KSAPIOperation*) updateStixWithAllTagID:(NSUInteger)allTagID andScore:(NSInteger)score andType:(NSInteger)type;
    
   
-(KSAPIOperation*) addStixToQueueWithUsername:(NSString*)username andFromUsername:(NSString*)fromUsername andType:(NSInteger)type andCount:(NSInteger)count;
    
   
-(KSAPIOperation*) addStixUpdateToQueueWithUsername:(NSString*)username andType:(NSInteger)type andCount:(NSInteger)count;
    
   
-(KSAPIOperation*) processStixUpdatesWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) addEmailToUserWithUsername:(NSString*)username andEmail:(NSString*)email;
    
   
-(KSAPIOperation*) addPhotoWithUsername:(NSString*)username andPhoto:(NSData*)photo;
    
   
-(KSAPIOperation*) addStixToUserWithUsername:(NSString*)username andStix:(NSData*)stix;
    
   
-(KSAPIOperation*) addUserWithUsername:(NSString*)username andPassword:(NSString*)password andPhoto:(NSData*)photo;
    
   
-(KSAPIOperation*) adminResetAllStixLevelWithStixLevel:(NSInteger)stixLevel;
    
   
 -(KSAPIOperation*) getAllUsers;
   
-(KSAPIOperation*) getStixOfUserForDecrementWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getStixOfUserForIncrementWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getUserByIDWithAllUserID:(NSUInteger)allUserID;
    
   
-(KSAPIOperation*) setStixLevelWithUsername:(NSString*)username andStixLevel:(NSInteger)stixLevel;
    
   
-(KSAPIOperation*) updateTotalTagsWithUsername:(NSString*)username andTotalTags:(NSInteger)totalTags;
    
   
-(KSAPIOperation*) userLoginWithUsername:(NSString*)username andPassword:(NSString*)password;
    
            
@end