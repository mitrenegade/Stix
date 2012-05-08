//
//  Kumulos.h
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on May  5, 2012
//  Copyright Neroh All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libKumulos.h"


@class Kumulos;
@protocol KumulosDelegate <kumulosProxyDelegate>
@optional

 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addHighResImageDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addHighResPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getHighResImageDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addCommentToPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation backupAllPixHistoriesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getCommentCountForUserDidCompleteWithResult:(NSNumber*)aggregateResult;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getHistoryCountForUserDidCompleteWithResult:(NSNumber*)aggregateResult;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addScaleAndRotationToPixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminDeleteTestDataDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation backupAllTagsDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation clearAllTagsBeforeTagIDDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation createNewPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation createPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation deleteTagDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagTimestampDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getMostRecentlyUpdatedTagDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getNewlyCreatedPixDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUpdatedPixByTimeDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserPixByTimeDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserPixCountDidCompleteWithResult:(NSNumber*)aggregateResult;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation touchPixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation touchPixToUpdateDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updatePixWithDescriptorDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateStixOfPixDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addEmailToUserDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminAddStixToAllUsersDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminDeleteAllTestUsersDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminIncrementAllUserBuxDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminLoginDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation adminSetAllUserBuxDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation changeUserBuxByAmountDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation checkUsernameExistenceDidCompleteWithResult:(NSNumber*)aggregateResult;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation createUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAuxiliaryDataDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getBuxForUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getFacebookUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserByEmailDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserByIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserStixDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateAuxiliaryDataDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateTotalTagsDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateUserByEmailDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation userLoginDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation createAppInfoDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAppInfoDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateAppInfoDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addAuxiliaryStixToPixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllAuxiliaryStixDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation removeAuxiliaryStixFromPixDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllCategoriesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getSubcategoriesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation lastUpdatedCategoriesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addFollowerDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getFollowersOfUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getFollowListDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation removeFollowerDidCompleteWithResult:(NSNumber*)affectedRows;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addMetricDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addMetricHitDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPixBelongsToUserDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation backupPixBelongingToUsersDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllPixBelongingToUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getNewPixBelongingToUserDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getSharedPixDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation savePixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation createStixDidCompleteWithResult:(NSNumber*)newRecordID;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllStixViewsDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllStixTypesDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getStixOfCategoryDidCompleteWithResult:(NSArray*)theResults;
 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation lastUpdatedStixTypesDidCompleteWithResult:(NSArray*)theResults;

@end

@interface Kumulos : kumulosProxy {
    NSString* theAPIKey;
    NSString* theSecretKey;
}

-(Kumulos*)init;
-(Kumulos*)initWithAPIKey:(NSString*)APIKey andSecretKey:(NSString*)secretKey;

   
-(KSAPIOperation*) addHighResImageWithDataPNG:(NSData*)dataPNG andTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) addHighResPixWithDataPNG:(NSData*)dataPNG andTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) getHighResImageWithTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) addCommentToPixWithTagID:(NSInteger)tagID andUsername:(NSString*)username andComment:(NSString*)comment andStixStringID:(NSString*)stixStringID;
    
   
 -(KSAPIOperation*) backupAllPixHistories;
   
-(KSAPIOperation*) getAllHistoryWithTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) getCommentCountForUserWithUsername:(NSString*)username andStixStringID:(NSString*)stixStringID;
    
   
-(KSAPIOperation*) getHistoryCountForUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) addScaleAndRotationToPixWithAllTagID:(NSUInteger)allTagID;
    
   
-(KSAPIOperation*) adminDeleteTestDataWithDescriptor:(NSString*)descriptor;
    
   
 -(KSAPIOperation*) backupAllTags;
   
-(KSAPIOperation*) clearAllTagsBeforeTagIDWithAllTagID:(NSUInteger)allTagID;
    
   
-(KSAPIOperation*) createNewPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andTagCoordinate:(NSData*)tagCoordinate andPendingID:(NSInteger)pendingID;
    
   
-(KSAPIOperation*) createPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andTagCoordinate:(NSData*)tagCoordinate andAuxStix:(NSData*)auxStix;
    
   
-(KSAPIOperation*) deleteTagWithAllTagID:(NSUInteger)allTagID;
    
   
 -(KSAPIOperation*) getAllTags;
   
-(KSAPIOperation*) getAllTagsWithIDGreaterThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags;
    
   
-(KSAPIOperation*) getAllTagsWithIDLessThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags;
    
   
-(KSAPIOperation*) getAllTagsWithIDRangeWithId_min:(NSUInteger)id_min andId_max:(NSUInteger)id_max;
    
   
-(KSAPIOperation*) getLastTagIDWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getLastTagTimestampWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getMostRecentlyUpdatedTagWithNumEls:(NSNumber*)numEls;
    
   
-(KSAPIOperation*) getNewlyCreatedPixWithAllTagID:(NSUInteger)allTagID;
    
   
-(KSAPIOperation*) getUpdatedPixByTimeWithTimeUpdated:(NSDate*)timeUpdated andNumPix:(NSNumber*)numPix;
    
   
-(KSAPIOperation*) getUserPixByTimeWithUsername:(NSString*)username andLastUpdated:(NSDate*)lastUpdated andNumRequested:(NSNumber*)numRequested;
    
   
-(KSAPIOperation*) getUserPixCountWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) touchPixWithAllTagID:(NSUInteger)allTagID andUsername:(NSString*)username;
    
   
-(KSAPIOperation*) touchPixToUpdateWithAllTagID:(NSUInteger)allTagID;
    
   
-(KSAPIOperation*) updatePixWithDescriptorWithAllTagID:(NSUInteger)allTagID andDescriptor:(NSString*)descriptor;
    
   
-(KSAPIOperation*) updateStixOfPixWithAllTagID:(NSUInteger)allTagID andAuxStix:(NSData*)auxStix;
    
   
-(KSAPIOperation*) addEmailToUserWithUsername:(NSString*)username andEmail:(NSString*)email;
    
   
-(KSAPIOperation*) addPhotoWithUsername:(NSString*)username andPhoto:(NSData*)photo;
    
   
-(KSAPIOperation*) addStixToUserWithUsername:(NSString*)username andStix:(NSData*)stix;
    
   
-(KSAPIOperation*) addUserWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andPhoto:(NSData*)photo andStix:(NSData*)stix andAuxiliaryData:(NSData*)auxiliaryData andTotalTags:(NSInteger)totalTags andBux:(NSInteger)bux andFacebookID:(NSInteger)facebookID;
    
   
-(KSAPIOperation*) adminAddStixToAllUsersWithStix:(NSData*)stix;
    
   
-(KSAPIOperation*) adminDeleteAllTestUsersWithEmail:(NSString*)email;
    
   
-(KSAPIOperation*) adminIncrementAllUserBuxWithBux:(NSInteger)bux;
    
   
-(KSAPIOperation*) adminLoginWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) adminSetAllUserBuxWithBux:(NSInteger)bux;
    
   
-(KSAPIOperation*) changeUserBuxByAmountWithUsername:(NSString*)username andBuxChange:(NSInteger)buxChange;
    
   
-(KSAPIOperation*) checkUsernameExistenceWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) createUserWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andPhoto:(NSData*)photo andStix:(NSData*)stix andAuxiliaryData:(NSData*)auxiliaryData andTotalTags:(NSInteger)totalTags andBux:(NSInteger)bux;
    
   
 -(KSAPIOperation*) getAllUsers;
   
-(KSAPIOperation*) getAuxiliaryDataWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getBuxForUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getFacebookUserWithFacebookID:(NSInteger)facebookID;
    
   
-(KSAPIOperation*) getUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getUserByEmailWithEmail:(NSString*)email;
    
   
-(KSAPIOperation*) getUserByIDWithAllUserID:(NSUInteger)allUserID;
    
   
-(KSAPIOperation*) getUserStixWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) updateAuxiliaryDataWithUsername:(NSString*)username andAuxiliaryData:(NSData*)auxiliaryData;
    
   
-(KSAPIOperation*) updateTotalTagsWithUsername:(NSString*)username andTotalTags:(NSInteger)totalTags;
    
   
-(KSAPIOperation*) updateUserByEmailWithEmail:(NSString*)email andUsername:(NSString*)username andPassword:(NSString*)password andPhoto:(NSData*)photo andFacebookID:(NSInteger)facebookID;
    
   
-(KSAPIOperation*) userLoginWithUsername:(NSString*)username andPassword:(NSString*)password;
    
   
-(KSAPIOperation*) createAppInfoWithInfoType:(NSString*)infoType andStringInfo:(NSString*)stringInfo andIntegerInfo:(NSInteger)integerInfo;
    
   
-(KSAPIOperation*) getAppInfoWithInfoType:(NSString*)infoType;
    
   
-(KSAPIOperation*) updateAppInfoWithInfoType:(NSString*)infoType andStringInfo:(NSString*)stringInfo andIntegerInfo:(NSInteger)integerInfo;
    
   
-(KSAPIOperation*) addAuxiliaryStixToPixWithTagID:(NSInteger)tagID andStixStringID:(NSString*)stixStringID andX:(float)x andY:(float)y andTransform:(NSString*)transform;
    
   
-(KSAPIOperation*) getAllAuxiliaryStixWithTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) removeAuxiliaryStixFromPixWithTagID:(NSInteger)tagID andStixStringID:(NSString*)stixStringID andX:(float)x andY:(float)y;
    
   
 -(KSAPIOperation*) getAllCategories;
   
-(KSAPIOperation*) getSubcategoriesWithCategoryName:(NSString*)categoryName;
    
   
-(KSAPIOperation*) lastUpdatedCategoriesWithTimeUpdated:(NSDate*)timeUpdated;
    
   
-(KSAPIOperation*) addFollowerWithUsername:(NSString*)username andFollowsUser:(NSString*)followsUser;
    
   
-(KSAPIOperation*) getFollowersOfUserWithFollowsUser:(NSString*)followsUser;
    
   
-(KSAPIOperation*) getFollowListWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) removeFollowerWithUsername:(NSString*)username andFollowsUser:(NSString*)followsUser;
    
   
-(KSAPIOperation*) addMetricWithDescription:(NSString*)description andUsername:(NSString*)username andStringValue:(NSString*)stringValue andIntegerValue:(NSInteger)integerValue;
    
   
-(KSAPIOperation*) addMetricHitWithDescription:(NSString*)description andStringValue:(NSString*)stringValue andIntegerValue:(NSInteger)integerValue;
    
   
-(KSAPIOperation*) addPixBelongsToUserWithUsername:(NSString*)username andTagID:(NSInteger)tagID;
    
   
 -(KSAPIOperation*) backupPixBelongingToUsers;
   
-(KSAPIOperation*) getAllPixBelongingToUserWithUsername:(NSString*)username;
    
   
-(KSAPIOperation*) getNewPixBelongingToUserWithUsername:(NSString*)username andTagID:(NSInteger)tagID;
    
   
-(KSAPIOperation*) getSharedPixWithSharedPixID:(NSUInteger)sharedPixID;
    
   
-(KSAPIOperation*) savePixWithPixPNG:(NSData*)pixPNG;
    
   
-(KSAPIOperation*) createStixWithStixStringID:(NSString*)stixStringID andDataPNG:(NSData*)dataPNG andStixDescriptor:(NSString*)stixDescriptor andLikelihood:(NSInteger)likelihood andOrder:(NSInteger)order andCategoryName:(NSString*)categoryName andTags:(NSString*)tags andDesignerName:(NSString*)designerName;
    
   
 -(KSAPIOperation*) getAllStixViews;
   
-(KSAPIOperation*) getStixDataByStixStringIDWithStixStringID:(NSString*)stixStringID;
    
   
 -(KSAPIOperation*) getAllStixTypes;
   
-(KSAPIOperation*) getStixOfCategoryWithCategoryName:(NSString*)categoryName;
    
   
-(KSAPIOperation*) lastUpdatedStixTypesWithTimeUpdated:(NSDate*)timeUpdated;
    
            
@end