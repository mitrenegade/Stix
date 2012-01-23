//
//  Kumulos.h
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on Jan 23, 2012
//  Copyright Neroh All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libKumulos.h"


@class Kumulos;
@protocol KumulosDelegate <kumulosProxyDelegate>
@optional

 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addCommentToPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addHistoryToPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addNewStixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addScaleAndRotationToPixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminDeleteTestDataDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation createPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation deleteTagDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagTimestampDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getMostRecentlyUpdatedTagDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixOfUserDidCompleteWithResult:(NSNumber*)aggregateResult;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation newPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updatePixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updatePixWithDescriptorDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updatePixWithStixCountsDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateStixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateStixOfPixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addEmailToUserDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addUserDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminAddStixToAllUsersDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminResetAllStixLevelDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserByIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation setStixLevelDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateTotalTagsDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation userLoginDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllStixViewsDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllStixTypesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixDataForStixStringIDDidCompleteWithResult:(NSArray*)theResults;

@end

@interface Kumulos : kumulosProxy {
    NSString* theAPIKey;
    NSString* theSecretKey;
}

-(Kumulos*)init;
-(Kumulos*)initWithAPIKey:(NSString*)APIKey andSecretKey:(NSString*)secretKey;

   
-(KSAPIOperation*) addCommentToPixWithTagID:(NSInteger)tagID andUsername:(NSString*)username andComment:(NSString*)comment andStixStringID:(NSString*)stixStringID;
    
   
-(KSAPIOperation*) addHistoryToPixWithTagID:(NSInteger)tagID andUsername:(NSString*)username andComment:(NSString*)comment;
    
   
-(KSAPIOperation*) getAllHistoryWithTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) addNewStixWithUsername:(NSString*)username andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate andType:(NSInteger)type andScore:(NSInteger)score;
    
   
-(KSAPIOperation*) addScaleAndRotationToPixWithAllTagID:(NSUInteger)allTagID andStixScale:(float)stixScale andStixRotation:(float)stixRotation;
    
   
-(KSAPIOperation*) adminDeleteTestDataWithDescriptor:(NSString*)descriptor;
    
   
-(KSAPIOperation*) createPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andTagCoordinate:(NSData*)tagCoordinate andAuxStix:(NSData*)auxStix;
    
   
-(KSAPIOperation*) deleteTagWithAllTagID:(NSUInteger)allTagID;
    
   
 -(KSAPIOperation*) getAllTags;
   
-(KSAPIOperation*) getAllTagsWithIDGreaterThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags;
    
   
-(KSAPIOperation*) getAllTagsWithIDLessThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags;
    
   
-(KSAPIOperation*) getAllTagsWithIDRangeWithId_min:(NSUInteger)id_min andId_max:(NSUInteger)id_max;
    
   
-(KSAPIOperation*) getLastTagIDWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getLastTagTimestampWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getMostRecentlyUpdatedTagWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getStixOfUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) newPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andScore:(NSInteger)score andStixStringID:(NSString*)stixStringID andTagCoordinate:(NSData*)tagCoordinate andAuxStix:(NSData*)auxStix;
    
   
-(KSAPIOperation*) updatePixWithAllTagID:(NSUInteger)allTagID andScore:(NSInteger)score andStixStringID:(NSString*)stixStringID andAuxStix:(NSData*)auxStix;
    
   
-(KSAPIOperation*) updatePixWithDescriptorWithAllTagID:(NSUInteger)allTagID andDescriptor:(NSString*)descriptor;
    
   
-(KSAPIOperation*) updatePixWithStixCountsWithAllTagID:(NSUInteger)allTagID andStixCounts:(NSData*)stixCounts;
    
   
-(KSAPIOperation*) updateStixWithAllTagID:(NSUInteger)allTagID andScore:(NSInteger)score andType:(NSInteger)type;
    
   
-(KSAPIOperation*) updateStixOfPixWithAllTagID:(NSUInteger)allTagID andAuxStix:(NSData*)auxStix;
    
   
-(KSAPIOperation*) addEmailToUserWithUsername:(NSString*)username andEmail:(NSString*)email;
    
   
-(KSAPIOperation*) addPhotoWithUsername:(NSString*)username andPhoto:(NSData*)photo;
    
   
-(KSAPIOperation*) addStixToUserWithUsername:(NSString*)username andStix:(NSData*)stix;
    
   
-(KSAPIOperation*) addUserWithUsername:(NSString*)username andPassword:(NSString*)password andPhoto:(NSData*)photo;
    
   
-(KSAPIOperation*) adminAddStixToAllUsersWithStix:(NSData*)stix;
    
   
-(KSAPIOperation*) adminResetAllStixLevelWithStixLevel:(NSInteger)stixLevel;
    
   
 -(KSAPIOperation*) getAllUsers;
   
-(KSAPIOperation*) getUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getUserByIDWithAllUserID:(NSUInteger)allUserID;
    
   
-(KSAPIOperation*) setStixLevelWithUsername:(NSString*)username andStixLevel:(NSInteger)stixLevel;
    
   
-(KSAPIOperation*) updateTotalTagsWithUsername:(NSString*)username andTotalTags:(NSInteger)totalTags;
    
   
-(KSAPIOperation*) userLoginWithUsername:(NSString*)username andPassword:(NSString*)password;
    
   
 -(KSAPIOperation*) getAllStixViews;
   
 -(KSAPIOperation*) getAllStixTypes;
   
-(KSAPIOperation*) getStixDataForStixStringIDWithStixStringID:(NSString*)stixStringID;
    
            
@end