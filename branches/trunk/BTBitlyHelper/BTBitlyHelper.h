//
//  BTBitlyHelper.h
//  Blast
//
//  Created by Brandon Tate on 9/19/11.
//  Copyright 2011 Brandon Tate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol BTBitlyHelperDelegate <NSObject>

@optional

/**
 *  Receives the shortened url for the given original url.
 *
 *  @param  shortUrl    The short url received from bit.ly.
 *  @param  originalUrl The original url given to bit.ly.
 */
- (void) BTBitlyShortUrl: (NSString *) shortUrl receivedForOriginalUrl: (NSString *) originalUrl;

/**
 *  Called when the queue starts processing.
 */
- (void) BTBitlyQueueStartedProcessing;

/**
 *  Called when the queue is done processing.
 */
- (void) BTBitlyQueueFinishedProcessing;


@end

@interface BTBitlyHelper : NSObject <ASIHTTPRequestDelegate>{
    
    @private
    
    /** Bitly Helper Delegate. */
    id<BTBitlyHelperDelegate> _delegate;
    
    /** Flag for when the helper is running. */
    BOOL    _isRunning;
}

/** Bitly Helper Delegate Property. */
@property (nonatomic, assign)   id<BTBitlyHelperDelegate> delegate;

// Bitly Methods
- (BOOL) shortenURLSInText: (NSString *) text;

// Queue Management
- (void) addToQueue: (NSString *) url;


// Helpers
- (BOOL) isBitlyURL: (NSString *) url;
- (BOOL) isInQueue: (NSString *) url;
- (NSInteger) queueCount;



@end
