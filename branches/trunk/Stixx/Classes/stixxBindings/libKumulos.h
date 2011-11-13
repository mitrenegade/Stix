//
//  libKumulos.h
//  Kumulos
//
//  Created by Kumulos on 13/05/2011
//  Copyright 2010 Kumulos All rights reserved.
//
//	version 0.6.2

#import <Foundation/Foundation.h>

#define PROD_API_SERVER_LEGACY 101
#define PROD_API_SERVER_BETA2  102
#define STAGING_API_SERVER 103
#define PROD_API_SERVER_BETA2_1 104

//
//  KSOperation
//

@class KSAPIOperation;
@protocol KSAPIOperationDelegate <NSObject>
@required
- (void) apiOperation:(KSAPIOperation*)operation didCompleteWithResult:(NSArray*)theResult;
@optional
- (void) apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError;
@end


@interface KSAPIOperation : NSOperation{
	id<KSAPIOperationDelegate,NSObject> delegate;
	
	//the selector that kumulosProxy subclass calls on success
	SEL callbackSelector;
    NSMethodSignature* delegateCallbackMethodSignature;
	
	//the main thread method signature of the kumulosProxy callback
	NSMethodSignature* successCallbackMethodSignature;
	NSMethodSignature* errorCallbackMethodSignature;
	
	NSArray* theResults;
	NSString* APIKey;
	NSString* secretKey;
	NSString* method;
	NSDictionary* params;
	float connectionTimeout;
	
	BOOL debugMode;
    
    NSInteger APIServer;
	NSInteger tag;
	
	//Connection vars
	NSMutableData* receivedData;
	NSString* theError;
	BOOL connFinished;
	NSURLConnection *theConnection;

    
}

@property (nonatomic, assign) id<KSAPIOperationDelegate,NSObject> delegate;
@property (nonatomic) SEL callbackSelector;

@property (nonatomic, retain) NSMethodSignature* successCallbackMethodSignature;
@property (nonatomic, retain) NSMethodSignature* errorCallbackMethodSignature;
@property (nonatomic, retain) NSMethodSignature* delegateCallbackMethodSignature;

@property (nonatomic, retain) NSString* APIKey;
@property (nonatomic, retain) NSString* secretKey;
@property (nonatomic) BOOL debugMode;
@property (nonatomic) NSInteger tag;
@property (nonatomic) NSInteger APIServer;

-(KSAPIOperation*) initWithAPIKey:(NSString*)theAPIKey andSecretKey:(NSString*)theSecretKey andMethodName:(NSString*)methodName andParams:(NSDictionary*)theParams;
-(NSString*) md5:(NSString*) inString;
- (NSString *)encodeUTF8String:(NSString *)string;
- (NSString *) getDeviceID;
- (NSString *) encodeBase64WithString:(NSString *)strData;
- (NSString *) encodeBase64WithData:(NSData *)objData;
- (NSData *) decodeBase64WithString:(NSString *)strBase64;

@end


@class kumulosProxy;
@protocol kumulosProxyDelegate <NSObject>
@optional
- (void) kumulosAPI:(kumulosProxy*)kumulos apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError;
@end

@interface kumulosProxy : NSObject <KSAPIOperationDelegate> {
	SEL callbackSelector;
	BOOL isLoading;
	id<kumulosProxyDelegate> delegate;
	NSOperationQueue* opQueue;
}

@property (nonatomic) SEL callbackSelector;
@property (nonatomic,assign) id<kumulosProxyDelegate> delegate;
@property (nonatomic,retain) NSOperationQueue* opQueue;

-(NSString*) md5:(NSString*) inString;
-(kumulosProxy*)init;

@end

