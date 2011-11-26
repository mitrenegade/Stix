//
//  ImageCache.h
//  ARKitDemo
//
//  Created by Administrator on 6/19/11.
//  Copyright 2011 Neroh. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// creates a cache of images in the application's memory

@interface ImageCache : NSObject {
	NSMutableDictionary	* dictionary;
}
+(ImageCache *) sharedImageCache;
-(void)setImage:(UIImage *) i forKey:(NSString *) s;
-(UIImage *) imageForKey:(NSString*) s;
-(void) deleteImageForKey:(NSString*) s;

@end
