//
//  KumulosData.m
//  Stixx
//
//  Created by Bobby Ren on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KumulosData.h"

@implementation KumulosData

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// use this if the data to be stored into the archiver is of type array
+(NSMutableData * ) arrayToData:(NSMutableArray *) arr {
    @try {
        // used to be dictionaryToData
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:arr forKey:@"dictionary"];
        [archiver finishEncoding];
        [archiver release];
        return [data autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"ArrayToData failed with exception %@", [exception reason]);
        @throw exception;
    }
}
+(NSMutableArray *) dataToArray:(NSMutableData *) data{ 
    @try{
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableArray * arr = [unarchiver decodeObjectForKey:@"dictionary"];
        [unarchiver finishDecoding];
        [unarchiver release];
        //[data release];
        return arr;
    }
    @catch (NSException *exception) {
        NSLog(@"DataToArray failed with exception %@", [exception reason]);
        @throw exception;
    }
}

// use this if the data to be stored into the archiver is of type dictionary
+(NSMutableDictionary *) dataToDictionary:(NSMutableData *) data{ 
    @try {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableDictionary * dict = [unarchiver decodeObjectForKey:@"dictionary"];
        [unarchiver finishDecoding];
        [unarchiver release];
        //[data release];
        return dict;
    }
    @catch (NSException *exception) {
        NSLog(@"DataToDictionary failed with exception %@", [exception reason]);
        @throw exception;
    }
}
+(NSMutableData * ) dictionaryToData:(NSMutableDictionary *) dict {
    @try {
        // used to be dictionaryToData
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:dict forKey:@"dictionary"];
        [archiver finishEncoding];
        [archiver release];
        return [data autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"DictionaryToData failed with exception %@", [exception reason]);
        @throw exception;
    }
}
@end
