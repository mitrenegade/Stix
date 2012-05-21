//
//  Kumulos.m
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on May 14, 2012
//  Copyright Neroh All rights reserved.
//

#import "Kumulos.h"

@implementation Kumulos

-(Kumulos*)init {

    if ([super init]) {
        theAPIKey = @"4dtqjx1n83c3y7p8d8zy132h1nr6z4nn";
        theSecretKey = @"x5s767hm";
        useSSL = NO;
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


-(KSAPIOperation*) addHighResImageWithDataPNG:(NSData*)dataPNG andTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:dataPNG forKey:@"dataPNG"];
                    [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addHighResImage" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addHighResImageDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addHighResPixWithDataPNG:(NSData*)dataPNG andTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:dataPNG forKey:@"dataPNG"];
                    [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addHighResPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addHighResPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getHighResImageWithTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getHighResImage" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getHighResImageDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addCommentToPixWithTagID:(NSInteger)tagID andUsername:(NSString*)username andComment:(NSString*)comment andStixStringID:(NSString*)stixStringID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                    [theParams setValue:username forKey:@"username"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:stixStringID forKey:@"stixStringID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addCommentToPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addCommentToPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) backupAllPixHistories{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"backupAllPixHistories" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: backupAllPixHistoriesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllHistoryWithTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllHistory" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllHistoryDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getCommentCountForUserWithUsername:(NSString*)username andStixStringID:(NSString*)stixStringID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:stixStringID forKey:@"stixStringID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getCommentCountForUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getCommentCountForUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getHistoryCountForUserWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getHistoryCountForUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getHistoryCountForUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addScaleAndRotationToPixWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addScaleAndRotationToPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addScaleAndRotationToPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminDeleteTestDataWithDescriptor:(NSString*)descriptor{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:descriptor forKey:@"descriptor"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminDeleteTestData" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminDeleteTestDataDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) backupAllTags{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"backupAllTags" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: backupAllTagsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) clearAllTagsBeforeTagIDWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"clearAllTagsBeforeTagID" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: clearAllTagsBeforeTagIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createNewPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andTagCoordinate:(NSData*)tagCoordinate andPendingID:(NSInteger)pendingID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:descriptor forKey:@"descriptor"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:locationString forKey:@"locationString"];
                    [theParams setValue:image forKey:@"image"];
                    [theParams setValue:tagCoordinate forKey:@"tagCoordinate"];
                    [theParams setValue:[NSNumber numberWithInt:pendingID] forKey:@"pendingID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createNewPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createNewPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andTagCoordinate:(NSData*)tagCoordinate andAuxStix:(NSData*)auxStix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:descriptor forKey:@"descriptor"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:locationString forKey:@"locationString"];
                    [theParams setValue:image forKey:@"image"];
                    [theParams setValue:tagCoordinate forKey:@"tagCoordinate"];
                    [theParams setValue:auxStix forKey:@"auxStix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createPixDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getMostRecentlyUpdatedTagDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getNewlyCreatedPixWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getNewlyCreatedPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getNewlyCreatedPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUpdatedPixByTimeWithTimeUpdated:(NSDate*)timeUpdated andNumPix:(NSNumber*)numPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:timeUpdated forKey:@"timeUpdated"];
                    [theParams setValue:numPix forKey:@"numPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUpdatedPixByTime" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUpdatedPixByTimeDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserPixByTimeWithUsername:(NSString*)username andLastUpdated:(NSDate*)lastUpdated andNumRequested:(NSNumber*)numRequested{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:lastUpdated forKey:@"lastUpdated"];
                    [theParams setValue:numRequested forKey:@"numRequested"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPixByTime" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPixByTimeDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserPixByUpdateTimeWithUsername:(NSString*)username andTimeUpdated:(NSDate*)timeUpdated andNumRequested:(NSNumber*)numRequested{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:timeUpdated forKey:@"timeUpdated"];
                    [theParams setValue:numRequested forKey:@"numRequested"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPixByUpdateTime" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPixByUpdateTimeDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserPixCountWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPixCount" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPixCountDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) touchPixWithAllTagID:(NSUInteger)allTagID andUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"touchPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: touchPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) touchPixToUpdateWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"touchPixToUpdate" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: touchPixToUpdateDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updatePixWithDescriptorWithAllTagID:(NSUInteger)allTagID andDescriptor:(NSString*)descriptor{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:descriptor forKey:@"descriptor"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updatePixWithDescriptor" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updatePixWithDescriptorDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updateStixOfPixWithAllTagID:(NSUInteger)allTagID andAuxStix:(NSData*)auxStix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:auxStix forKey:@"auxStix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateStixOfPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateStixOfPixDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addStixToUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addUserWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andPhoto:(NSData*)photo andStix:(NSData*)stix andAuxiliaryData:(NSData*)auxiliaryData andTotalTags:(NSInteger)totalTags andBux:(NSInteger)bux andFacebookID:(NSInteger)facebookID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                    [theParams setValue:email forKey:@"email"];
                    [theParams setValue:photo forKey:@"photo"];
                    [theParams setValue:stix forKey:@"stix"];
                    [theParams setValue:auxiliaryData forKey:@"auxiliaryData"];
                    [theParams setValue:[NSNumber numberWithInt:totalTags] forKey:@"totalTags"];
                    [theParams setValue:[NSNumber numberWithInt:bux] forKey:@"bux"];
                    [theParams setValue:[NSNumber numberWithInt:facebookID] forKey:@"facebookID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminAddStixToAllUsersWithStix:(NSData*)stix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:stix forKey:@"stix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminAddStixToAllUsers" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminAddStixToAllUsersDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminDeleteAllTestUsersWithEmail:(NSString*)email{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:email forKey:@"email"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminDeleteAllTestUsers" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminDeleteAllTestUsersDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminIncrementAllUserBuxWithBux:(NSInteger)bux{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:bux] forKey:@"bux"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminIncrementAllUserBux" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminIncrementAllUserBuxDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminLoginWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminLogin" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminLoginDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) adminSetAllUserBuxWithBux:(NSInteger)bux{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:bux] forKey:@"bux"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"adminSetAllUserBux" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: adminSetAllUserBuxDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) changeUserBuxByAmountWithUsername:(NSString*)username andBuxChange:(NSInteger)buxChange{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:buxChange] forKey:@"buxChange"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"changeUserBuxByAmount" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: changeUserBuxByAmountDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) checkUsernameExistenceWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"checkUsernameExistence" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: checkUsernameExistenceDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createUserWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andPhoto:(NSData*)photo andStix:(NSData*)stix andAuxiliaryData:(NSData*)auxiliaryData andTotalTags:(NSInteger)totalTags andBux:(NSInteger)bux{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                    [theParams setValue:email forKey:@"email"];
                    [theParams setValue:photo forKey:@"photo"];
                    [theParams setValue:stix forKey:@"stix"];
                    [theParams setValue:auxiliaryData forKey:@"auxiliaryData"];
                    [theParams setValue:[NSNumber numberWithInt:totalTags] forKey:@"totalTags"];
                    [theParams setValue:[NSNumber numberWithInt:bux] forKey:@"bux"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createUserDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllUsersDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAuxiliaryDataWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAuxiliaryData" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAuxiliaryDataDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getBuxForUserWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getBuxForUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getBuxForUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getFacebookUserWithFacebookID:(NSInteger)facebookID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:facebookID] forKey:@"facebookID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getFacebookUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getFacebookUserDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserByEmailWithEmail:(NSString*)email{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:email forKey:@"email"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserByEmail" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserByEmailDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserByIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserStixWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserStix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserStixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updateAuxiliaryDataWithUsername:(NSString*)username andAuxiliaryData:(NSData*)auxiliaryData{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:auxiliaryData forKey:@"auxiliaryData"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateAuxiliaryData" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateAuxiliaryDataDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateTotalTagsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updateUserByEmailWithEmail:(NSString*)email andUsername:(NSString*)username andPassword:(NSString*)password andPhoto:(NSData*)photo andFacebookID:(NSInteger)facebookID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:email forKey:@"email"];
                    [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                    [theParams setValue:photo forKey:@"photo"];
                    [theParams setValue:[NSNumber numberWithInt:facebookID] forKey:@"facebookID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateUserByEmail" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateUserByEmailDidCompleteWithResult:)];
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
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: userLoginDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createAppInfoWithInfoType:(NSString*)infoType andStringInfo:(NSString*)stringInfo andIntegerInfo:(NSInteger)integerInfo{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:infoType forKey:@"infoType"];
                    [theParams setValue:stringInfo forKey:@"stringInfo"];
                    [theParams setValue:[NSNumber numberWithInt:integerInfo] forKey:@"integerInfo"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createAppInfo" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createAppInfoDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAppInfoWithInfoType:(NSString*)infoType{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:infoType forKey:@"infoType"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAppInfo" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAppInfoDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updateAppInfoWithInfoType:(NSString*)infoType andStringInfo:(NSString*)stringInfo andIntegerInfo:(NSInteger)integerInfo{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:infoType forKey:@"infoType"];
                    [theParams setValue:stringInfo forKey:@"stringInfo"];
                    [theParams setValue:[NSNumber numberWithInt:integerInfo] forKey:@"integerInfo"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateAppInfo" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateAppInfoDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addAuxiliaryStixToPixWithTagID:(NSInteger)tagID andStixStringID:(NSString*)stixStringID andX:(float)x andY:(float)y andTransform:(NSString*)transform{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                    [theParams setValue:stixStringID forKey:@"stixStringID"];
                    [theParams setValue:[NSNumber numberWithFloat:x] forKey:@"x"];
                    [theParams setValue:[NSNumber numberWithFloat:y] forKey:@"y"];
                    [theParams setValue:transform forKey:@"transform"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addAuxiliaryStixToPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addAuxiliaryStixToPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllAuxiliaryStixWithTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllAuxiliaryStix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllAuxiliaryStixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) removeAuxiliaryStixFromPixWithTagID:(NSInteger)tagID andStixStringID:(NSString*)stixStringID andX:(float)x andY:(float)y{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                    [theParams setValue:stixStringID forKey:@"stixStringID"];
                    [theParams setValue:[NSNumber numberWithFloat:x] forKey:@"x"];
                    [theParams setValue:[NSNumber numberWithFloat:y] forKey:@"y"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"removeAuxiliaryStixFromPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: removeAuxiliaryStixFromPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllCategories{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllCategories" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllCategoriesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getSubcategoriesWithCategoryName:(NSString*)categoryName{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:categoryName forKey:@"categoryName"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getSubcategories" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getSubcategoriesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) lastUpdatedCategoriesWithTimeUpdated:(NSDate*)timeUpdated{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:timeUpdated forKey:@"timeUpdated"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"lastUpdatedCategories" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: lastUpdatedCategoriesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addFollowerWithUsername:(NSString*)username andFollowsUser:(NSString*)followsUser{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:followsUser forKey:@"followsUser"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addFollower" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addFollowerDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getFollowersOfUserWithFollowsUser:(NSString*)followsUser{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:followsUser forKey:@"followsUser"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getFollowersOfUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getFollowersOfUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getFollowListWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getFollowList" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getFollowListDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) removeFollowerWithUsername:(NSString*)username andFollowsUser:(NSString*)followsUser{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:followsUser forKey:@"followsUser"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"removeFollower" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: removeFollowerDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addMetricWithDescription:(NSString*)description andUsername:(NSString*)username andStringValue:(NSString*)stringValue andIntegerValue:(NSInteger)integerValue{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:description forKey:@"description"];
                    [theParams setValue:username forKey:@"username"];
                    [theParams setValue:stringValue forKey:@"stringValue"];
                    [theParams setValue:[NSNumber numberWithInt:integerValue] forKey:@"integerValue"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addMetric" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addMetricDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addMetricHitWithDescription:(NSString*)description andStringValue:(NSString*)stringValue andIntegerValue:(NSInteger)integerValue{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:description forKey:@"description"];
                    [theParams setValue:stringValue forKey:@"stringValue"];
                    [theParams setValue:[NSNumber numberWithInt:integerValue] forKey:@"integerValue"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addMetricHit" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addMetricHitDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) addPixBelongsToUserWithUsername:(NSString*)username andTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addPixBelongsToUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addPixBelongsToUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) backupPixBelongingToUsers{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"backupPixBelongingToUsers" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: backupPixBelongingToUsersDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllPixBelongingToUserWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllPixBelongingToUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllPixBelongingToUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getNewPixBelongingToUserWithUsername:(NSString*)username andTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getNewPixBelongingToUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getNewPixBelongingToUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) didPurchasePremiumPackWithUsername:(NSString*)username andStixPackName:(NSString*)stixPackName{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:stixPackName forKey:@"stixPackName"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"didPurchasePremiumPack" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: didPurchasePremiumPackDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserPremiumPacksWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPremiumPacks" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPremiumPacksDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getSharedPixWithSharedPixID:(NSUInteger)sharedPixID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:sharedPixID] forKey:@"sharedPixID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getSharedPix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getSharedPixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) savePixWithPixPNG:(NSData*)pixPNG{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:pixPNG forKey:@"pixPNG"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"savePix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: savePixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createStixWithStixStringID:(NSString*)stixStringID andDataPNG:(NSData*)dataPNG andStixDescriptor:(NSString*)stixDescriptor andLikelihood:(NSInteger)likelihood andOrder:(NSInteger)order andCategoryName:(NSString*)categoryName andTags:(NSString*)tags andDesignerName:(NSString*)designerName{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:stixStringID forKey:@"stixStringID"];
                    [theParams setValue:dataPNG forKey:@"dataPNG"];
                    [theParams setValue:stixDescriptor forKey:@"stixDescriptor"];
                    [theParams setValue:[NSNumber numberWithInt:likelihood] forKey:@"likelihood"];
                    [theParams setValue:[NSNumber numberWithInt:order] forKey:@"order"];
                    [theParams setValue:categoryName forKey:@"categoryName"];
                    [theParams setValue:tags forKey:@"tags"];
                    [theParams setValue:designerName forKey:@"designerName"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createStix" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createStixDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllStixViews{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllStixViews" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllStixViewsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getStixDataByStixStringIDWithStixStringID:(NSString*)stixStringID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:stixStringID forKey:@"stixStringID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getStixDataByStixStringID" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getStixDataByStixStringIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getAllStixTypes{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getAllStixTypes" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getAllStixTypesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getStixOfCategoryWithCategoryName:(NSString*)categoryName{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:categoryName forKey:@"categoryName"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getStixOfCategory" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getStixOfCategoryDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) lastUpdatedStixTypesWithTimeUpdated:(NSDate*)timeUpdated{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:timeUpdated forKey:@"timeUpdated"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"lastUpdatedStixTypes" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: lastUpdatedStixTypesDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

@end