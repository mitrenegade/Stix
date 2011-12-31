//
//  KumulosData.h
//  Stixx
//
//  Created by Bobby Ren on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KumulosData : NSObject

+(NSMutableData * ) arrayToData:(NSMutableArray *) arr;
+(NSMutableArray *) dataToArray:(NSMutableData *) data; 
+(NSMutableData * ) dictionaryToData:(NSMutableDictionary *) dict;
+(NSMutableDictionary *) dataToDictionary:(NSMutableData *) data; 

@end
