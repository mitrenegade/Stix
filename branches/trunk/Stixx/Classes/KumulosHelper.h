//
//  KumulosHelper.h
//  Stixx
//
//  Created by Bobby Ren on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// for clean callbacks of kumulos objects

#import <Foundation/Foundation.h>
#import "Kumulos.h"
#import "Tag.h"

@protocol KumulosHelperDelegate <NSObject>

@optional
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray*)params;
-(void)kumulosHelperGetFacebookUserDidFail;
-(void)kumulosHelperCreateNewPixDidFail:(Tag*)failedTag;
-(void)kumulosHelperGetFeaturedUsersDidFail;
@end

@interface KumulosHelper : NSObject <KumulosDelegate>
{
    Kumulos * k;
    NSString * function;
    SEL callback; 
    NSMutableDictionary * savedInfo;
}

@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, assign) NSString * function;
@property (nonatomic, assign) SEL callback;
@property (nonatomic, assign) NSObject<KumulosHelperDelegate> * delegate;
@property (nonatomic, retain) NSMutableArray * inputParams;

-(void)execute:(NSString*)_function withParams:(NSMutableArray*)params withCallback:(SEL)_callback withDelegate:(NSObject<KumulosHelperDelegate>*)helperDelegate;
-(void)execute:(NSString*)_function;
//+(KumulosHelper*)sharedKumulosHelper;
-(void)doCallback:(NSMutableArray*)returnParams;
-(void)cleanup;
@end
