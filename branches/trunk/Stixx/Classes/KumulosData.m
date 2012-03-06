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

// use this if the data to be stored into the archiver is of type dictionary
+(NSMutableSet *) dataToSet:(NSMutableData *) data{ 
    @try {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableSet * set = [unarchiver decodeObjectForKey:@"set"];
        [unarchiver finishDecoding];
        [unarchiver release];
        //[data release];
        return set;
    }
    @catch (NSException *exception) {
        NSLog(@"DataToSet failed with exception %@", [exception reason]);
        @throw exception;
    }
}
+(NSMutableData * ) setToData:(NSMutableSet *) set {
    @try {
        // used to be dictionaryToData
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:set forKey:@"set"];
        [archiver finishEncoding];
        [archiver release];
        return [data autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"SetToData failed with exception %@", [exception reason]);
        @throw exception;
    }
}

+(int) extractAuxiliaryDataFromUserData:(NSMutableDictionary *) dict intoAuxiliaryData:(NSMutableDictionary *)auxiliaryData{
    // d is output from getAllUsers or getUser
    // return values: 
    // -1 if nothing exists
    // 0 if everything is present
    // 1 if stixOrder is missing
    // 2 if friendsList is missing
    NSMutableDictionary * stixOrder;
    NSMutableSet * friendsList;
    NSString * username = [dict valueForKey:@"username"];
    NSMutableData * data = [dict valueForKey:@"auxiliaryData"];
    NSMutableDictionary * auxData = nil;
    if ([data isKindOfClass:[NSMutableData class]]) {
        @try {
            auxData = [[KumulosData dataToDictionary:data] retain];
            if (!auxData || ![auxData isKindOfClass:[NSMutableDictionary class]]) {
                NSLog(@"%@ has empty auxiliary data", username);
                // set to nil to make delegate generate default one
                stixOrder = nil;
                friendsList = nil;
                return -1;
            } 
            else {
                [auxiliaryData addEntriesFromDictionary:auxData];

                NSEnumerator *e = [auxData keyEnumerator];
                id key;
                while (key = [e nextObject]) {
                    NSLog(@"Key: %@", key);
                }
                
                stixOrder = [auxData objectForKey:@"stixOrder"];
                friendsList = [auxData objectForKey:@"friendsList"];
                NSLog(@"stixOrder count: %d", [stixOrder count]);
                NSLog(@"friendsList count: %d", [friendsList count]);
                if (stixOrder == nil && friendsList == nil)
                    return -1;
                else if (stixOrder == nil)
                    return 1;
                else if (friendsList == nil)
                    return 2;
                return 0;
            }
        } @catch (NSException * exception) {
            NSLog(@"Error! Exception caught while trying to load aux data! Error %@", [exception reason]);
            return -1;
        }
    }
    else {
        NSLog(@"%@ does not have auxiliary data", [dict valueForKey:@"username"]);
        return -1;
    }
    return -1;
}
@end
