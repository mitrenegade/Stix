//
//  Kumulos.m
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on Aug 20, 2012
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


-(KSAPIOperation*) getUserPixForUsersWithCsvUsers:(NSString*)csvUsers andMaxTagId:(NSInteger)maxTagId andMaxPix:(NSInteger)maxPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:csvUsers forKey:@"csvUsers"];
                    [theParams setValue:maxTagId forKey:@"maxTagId"];
                    [theParams setValue:maxPix forKey:@"maxPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPixForUsers" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPixForUsersDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getUserPixKScriptTest{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPixKScriptTest" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPixKScriptTestDidCompleteWithResult:)];
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

-(KSAPIOperation*) getHighResImageWithAllPixHighReID:(NSUInteger)allPixHighReID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allPixHighReID] forKey:@"allPixHighReID"];
                        
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

-(KSAPIOperation*) getHighResImageForTagIDWithTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getHighResImageForTagID" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getHighResImageForTagIDDidCompleteWithResult:)];
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

-(KSAPIOperation*) adminDeleteTestData{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
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

-(KSAPIOperation*) createNewPixWithUsername:(NSString*)username andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(NSData*)image andPendingID:(NSInteger)pendingID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:comment forKey:@"comment"];
                    [theParams setValue:locationString forKey:@"locationString"];
                    [theParams setValue:image forKey:@"image"];
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

-(KSAPIOperation*) createPixWithUsername:(NSString*)username andDescriptor:(NSString*)descriptor andImage:(NSData*)image andStixLayer:(NSData*)stixLayer andPendingID:(NSInteger)pendingID andHighResImageID:(NSUInteger)highResImageID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:descriptor forKey:@"descriptor"];
                    [theParams setValue:image forKey:@"image"];
                    [theParams setValue:stixLayer forKey:@"stixLayer"];
                    [theParams setValue:[NSNumber numberWithInt:pendingID] forKey:@"pendingID"];
                    [theParams setValue:[NSNumber numberWithInt:highResImageID] forKey:@"highResImageID"];
                        
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

-(KSAPIOperation*) getPixByPopularityWithNumPix:(NSNumber*)numPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:numPix forKey:@"numPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getPixByPopularity" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getPixByPopularityDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getPixByRecentWithTimeCreated:(NSDate*)timeCreated andNumPix:(NSNumber*)numPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:timeCreated forKey:@"timeCreated"];
                    [theParams setValue:numPix forKey:@"numPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getPixByRecent" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getPixByRecentDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getPopularPixInTimeRangeWithTimeStart:(NSDate*)timeStart andTimeEnd:(NSDate*)timeEnd andNumPix:(NSNumber*)numPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:timeStart forKey:@"timeStart"];
                    [theParams setValue:timeEnd forKey:@"timeEnd"];
                    [theParams setValue:numPix forKey:@"numPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getPopularPixInTimeRange" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getPopularPixInTimeRangeDidCompleteWithResult:)];
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

-(KSAPIOperation*) getUserPixByTimeCreatedWithUsername:(NSString*)username andTimeCreated:(NSDate*)timeCreated andNumPix:(NSNumber*)numPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:timeCreated forKey:@"timeCreated"];
                    [theParams setValue:numPix forKey:@"numPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getUserPixByTimeCreated" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getUserPixByTimeCreatedDidCompleteWithResult:)];
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

-(KSAPIOperation*) incrementPopularityWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"incrementPopularity" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: incrementPopularityDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) setHighResImageIDWithAllTagID:(NSUInteger)allTagID andHighResImageID:(NSUInteger)highResImageID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:[NSNumber numberWithInt:highResImageID] forKey:@"highResImageID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"setHighResImageID" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: setHighResImageIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) setOriginalUsernameWithAllTagID:(NSUInteger)allTagID andOriginalUsername:(NSString*)originalUsername{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:originalUsername forKey:@"originalUsername"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"setOriginalUsername" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: setOriginalUsernameDidCompleteWithResult:)];
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

-(KSAPIOperation*) updateImageWithAllTagID:(NSUInteger)allTagID andImage:(NSData*)image{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:image forKey:@"image"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateImage" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateImageDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) updatePixWithDescriptorWithAllTagID:(NSUInteger)allTagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                        
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

-(KSAPIOperation*) updateStixLayerWithAllTagID:(NSUInteger)allTagID andStixLayer:(NSData*)stixLayer{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allTagID] forKey:@"allTagID"];
                    [theParams setValue:stixLayer forKey:@"stixLayer"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateStixLayer" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateStixLayerDidCompleteWithResult:)];
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

-(KSAPIOperation*) checkValidNewUserWithUsername:(NSString*)username andEmail:(NSString*)email{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:email forKey:@"email"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"checkValidNewUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: checkValidNewUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createEmailUserWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andPhoto:(NSData*)photo{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                    [theParams setValue:email forKey:@"email"];
                    [theParams setValue:photo forKey:@"photo"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createEmailUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createEmailUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createFacebookUserWithUsername:(NSString*)username andEmail:(NSString*)email andPhoto:(NSData*)photo andFacebookString:(NSString*)facebookString{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:email forKey:@"email"];
                    [theParams setValue:photo forKey:@"photo"];
                    [theParams setValue:facebookString forKey:@"facebookString"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"createFacebookUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: createFacebookUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) createUserWithUsername:(NSString*)username andEmail:(NSString*)email andPhoto:(NSData*)photo andFacebookString:(NSString*)facebookString andTwitterString:(NSString*)twitterString{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:email forKey:@"email"];
                    [theParams setValue:photo forKey:@"photo"];
                    [theParams setValue:facebookString forKey:@"facebookString"];
                    [theParams setValue:twitterString forKey:@"twitterString"];
                        
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

-(KSAPIOperation*) deleteUserWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"deleteUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: deleteUserDidCompleteWithResult:)];
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

-(KSAPIOperation*) loginViaFacebookWithFacebookID:(NSInteger)facebookID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:facebookID] forKey:@"facebookID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"loginViaFacebook" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: loginViaFacebookDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) loginViaFacebookStringWithFacebookString:(NSString*)facebookString{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:facebookString forKey:@"facebookString"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"loginViaFacebookString" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: loginViaFacebookStringDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) loginViaTwitterWithTwitterString:(NSString*)twitterString{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:twitterString forKey:@"twitterString"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"loginViaTwitter" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: loginViaTwitterDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) loginWithNameOrEmailWithLoginName:(NSString*)loginName{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:loginName forKey:@"loginName"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"loginWithNameOrEmail" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: loginWithNameOrEmailDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) setFacebookStringForUserWithEmail:(NSString*)email andFacebookString:(NSString*)facebookString{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:email forKey:@"email"];
                    [theParams setValue:facebookString forKey:@"facebookString"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"setFacebookStringForUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: setFacebookStringForUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) setTwitterStringForUserWithAllUserID:(NSUInteger)allUserID andTwitterString:(NSString*)twitterString{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:allUserID] forKey:@"allUserID"];
                    [theParams setValue:twitterString forKey:@"twitterString"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"setTwitterStringForUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: setTwitterStringForUserDidCompleteWithResult:)];
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

-(KSAPIOperation*) updateUserInfoByEmailWithEmail:(NSString*)email andUsername:(NSString*)username andPassword:(NSString*)password andPhoto:(NSData*)photo{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:email forKey:@"email"];
                    [theParams setValue:username forKey:@"username"];
                    [theParams setValue:password forKey:@"password"];
                    [theParams setValue:photo forKey:@"photo"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"updateUserInfoByEmail" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: updateUserInfoByEmailDidCompleteWithResult:)];
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

-(KSAPIOperation*) addFeaturedUserWithUsername:(NSString*)username andDescription:(NSString*)description{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:description forKey:@"description"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addFeaturedUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addFeaturedUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getFeaturedUsers{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
                
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getFeaturedUsers" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getFeaturedUsersDidCompleteWithResult:)];
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

-(KSAPIOperation*) addNewsWithUsername:(NSString*)username andAgentName:(NSString*)agentName andNews:(NSString*)news andThumbnail:(NSData*)thumbnail andTagID:(NSInteger)tagID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:agentName forKey:@"agentName"];
                    [theParams setValue:news forKey:@"news"];
                    [theParams setValue:thumbnail forKey:@"thumbnail"];
                    [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"addNews" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: addNewsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) countUnseenNewsWithUsername:(NSString*)username andHasBeenSeen:(BOOL)hasBeenSeen{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithBool:hasBeenSeen] forKey:@"hasBeenSeen"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"countUnseenNews" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: countUnseenNewsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) deleteNewsWithNews:(NSString*)news{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:news forKey:@"news"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"deleteNews" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: deleteNewsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) deleteNewsByIDWithNewsfeedID:(NSUInteger)newsfeedID{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:newsfeedID] forKey:@"newsfeedID"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"deleteNewsByID" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: deleteNewsByIDDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) getNewsWithUsername:(NSString*)username{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getNews" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getNewsDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
    [newOp release];
    [theParams release];
    return newOp;
    
}

-(KSAPIOperation*) hasSeenNewsWithNewsfeedID:(NSUInteger)newsfeedID andHasBeenSeen:(BOOL)hasBeenSeen{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:[NSNumber numberWithInt:newsfeedID] forKey:@"newsfeedID"];
                    [theParams setValue:[NSNumber numberWithBool:hasBeenSeen] forKey:@"hasBeenSeen"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"hasSeenNews" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: hasSeenNewsDidCompleteWithResult:)];
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

-(KSAPIOperation*) getSomeNewPixBelongingToUserWithUsername:(NSString*)username andTagID:(NSInteger)tagID andMaxPix:(NSNumber*)maxPix{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:[NSNumber numberWithInt:tagID] forKey:@"tagID"];
                    [theParams setValue:maxPix forKey:@"maxPix"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"getSomeNewPixBelongingToUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: getSomeNewPixBelongingToUserDidCompleteWithResult:)];
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