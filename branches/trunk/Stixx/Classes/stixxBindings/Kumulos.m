//
//  Kumulos.m
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on Dec  5, 2011
//  Copyright Neroh All rights reserved.
//

#import "Kumulos.h"

@implementation Kumulos

-(Kumulos*)init {

    if ([super init]) {
        theAPIKey = @"4dtqjx1n83c3y7p8d8zy132h1nr6z4nn";
        theSecretKey = @"x5s767hm";
    }

    return self;
}

-(Kumulos*)initWithAPIKey:(NSString*)APIKey andSecretKey:(NSString*)secretKey{
    if([super init]){
        theAPIKey = [APIKey copy];
        theSecretKey = [secretKey copy];
    }
    return self;
 }


-(KSAPIOperation*) addNewStixWithUsername:(NSString*)username andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate andType:(NSInteger)type andScore:(NSInteger)score{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:locationString forKey:@"locationString"];
                    [theParams setValue:image forKey:@"image"];
                    [theParams setValue:[NSNumber numberWithInt:badge_x] forKey:@"badge_x"];
                    [theParams setValue:[NSNumber numberWithInt:badge_y] forKey:@"badge_y"];
                    [theParams setValue:tagCoordinate forKey:@"tagCoordinate"];
                    [theParams setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                    [theParams setValue:[NSNumber numberWithInt:score] forKey:@"score"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addNewStix" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addNewStixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addStixWithUsername:(NSString*)username andComment:(NSString*)comment andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate andType:(NSInteger)type andScore:(NSInteger)score{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:image forKey:@"image"];
                    [theParams setValue:[NSNumber numberWithInt:badge_x] forKey:@"badge_x"];
                    [theParams setValue:[NSNumber numberWithInt:badge_y] forKey:@"badge_y"];
                    [theParams setValue:tagCoordinate forKey:@"tagCoordinate"];
                    [theParams setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                    [theParams setValue:[NSNumber numberWithInt:score] forKey:@"score"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addStix" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addStixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addTagWithUsername:(NSString*)username andComment:(NSString*)comment andImage:(NSData*)image andBadge_x:(NSInteger)badge_x andBadge_y:(NSInteger)badge_y andTagCoordinate:(NSData*)tagCoordinate{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:image forKey:@"image"];
                    [theParams setValue:[NSNumber numberWithInt:badge_x] forKey:@"badge_x"];
                    [theParams setValue:[NSNumber numberWithInt:badge_y] forKey:@"badge_y"];
                    [theParams setValue:tagCoordinate forKey:@"tagCoordinate"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addTag" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addTagDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminUpdateAllUsersStixCountsWithStixCounts:(NSData*)stixCounts{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:stixCounts forKey:@"stixCounts"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminUpdateAllUsersStixCounts" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminUpdateAllUsersStixCountsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) deleteTagWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"deleteTag" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: deleteTagDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllTags{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllTags" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllTagsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllTagsWithIDGreaterThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:numTags forKey:@"numTags"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllTagsWithIDGreaterThan" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllTagsWithIDGreaterThanDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllTagsWithIDLessThanWithAllTagID:(NSUInteger)allTagID andNumTags:(NSNumber*)numTags{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:numTags forKey:@"numTags"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllTagsWithIDLessThan" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllTagsWithIDLessThanDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllTagsWithIDRangeWithId_min:(NSUInteger)id_min andId_max:(NSUInteger)id_max{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:id_min] forKey:@"id_min"];
                    [theParams setValue:[NSNumber numberWithInt:id_max] forKey:@"id_max"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllTagsWithIDRange" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllTagsWithIDRangeDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getLastTagIDWithNumEls:(NSNumber*)numEls{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:numEls forKey:@"numEls"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getLastTagID" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getLastTagIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getLastTagTimestampWithNumEls:(NSNumber*)numEls{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:numEls forKey:@"numEls"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getLastTagTimestamp" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getLastTagTimestampDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getMostRecentlyUpdatedTagWithNumEls:(NSNumber*)numEls{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:numEls forKey:@"numEls"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getMostRecentlyUpdatedTag" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getMostRecentlyUpdatedTagDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getStixOfUserWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getStixOfUser" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getStixOfUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updatePixWithStixCountsWithAllTagID:(NSUInteger)allTagID andStixCounts:(NSData*)stixCounts{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:stixCounts forKey:@"stixCounts"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updatePixWithStixCounts" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updatePixWithStixCountsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updateStixWithAllTagID:(NSUInteger)allTagID andScore:(NSInteger)score andType:(NSInteger)type{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:[NSNumber numberWithInt:score] forKey:@"score"];
                    [theParams setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateStix" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateStixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addStixToQueueWithUsername:(NSString*)username andFromUsername:(NSString*)fromUsername andType:(NSInteger)type andCount:(NSInteger)count{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:fromUsername forKey:@"fromUsername"];
                    [theParams setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                    [theParams setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addStixToQueue" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addStixToQueueDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addStixUpdateToQueueWithUsername:(NSString*)username andType:(NSInteger)type andCount:(NSInteger)count{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                    [theParams setValue:[NSNumber numberWithInt:count] forKey:@"count"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addStixUpdateToQueue" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addStixUpdateToQueueDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) processStixUpdatesWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"processStixUpdates" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: processStixUpdatesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addEmailToUserWithUsername:(NSString*)username andEmail:(NSString*)email{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:email forKey:@"email"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addEmailToUser" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addEmailToUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addPhotoWithUsername:(NSString*)username andPhoto:(NSData*)photo{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:photo forKey:@"photo"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addPhoto" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addPhotoDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addStixToUserWithUsername:(NSString*)username andStix:(NSData*)stix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:stix forKey:@"stix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addStixToUser" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addStixToUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addUserWithUsername:(NSString*)username andPassword:(NSString*)password andPhoto:(NSData*)photo{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                    [theParams setValue:photo forKey:@"photo"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addUser" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminResetAllStixLevelWithStixLevel:(NSInteger)stixLevel{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:stixLevel] forKey:@"stixLevel"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminResetAllStixLevel" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminResetAllStixLevelDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllUsers{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllUsers" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllUsersDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getStixOfUserForDecrementWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getStixOfUserForDecrement" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getStixOfUserForDecrementDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getStixOfUserForIncrementWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getStixOfUserForIncrement" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getStixOfUserForIncrementDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUser" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserByIDWithAllUserID:(NSUInteger)allUserID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allUserID] forKey:@"allUserID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserByID" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserByIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) setStixLevelWithUsername:(NSString*)username andStixLevel:(NSInteger)stixLevel{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:stixLevel] forKey:@"stixLevel"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"setStixLevel" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: setStixLevelDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updateTotalTagsWithUsername:(NSString*)username andTotalTags:(NSInteger)totalTags{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:totalTags] forKey:@"totalTags"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateTotalTags" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateTotalTagsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) userLoginWithUsername:(NSString*)username andPassword:(NSString*)password{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"userLogin" andParams:theParams];
    [newOp setDelegate:self];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: userLoginDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

@end