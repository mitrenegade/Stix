//
//  KumulosHelper.m
//  Stixx
//
//  Created by Bobby Ren on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KumulosHelper.h"
#import "KumulosData.h"
#import "GlobalHeaders.h"
#import "BadgeView.h"

@implementation KumulosHelper
@synthesize k;
@synthesize function;
@synthesize callback;
@synthesize delegate;
@synthesize inputParams;

static NSMutableSet * retainedHelpers;

/*
static KumulosHelper *sharedKumulosHelper = nil;
+(KumulosHelper*)sharedKumulosHelper 
{
	if (!sharedKumulosHelper){
		sharedKumulosHelper = [[KumulosHelper alloc] init];
	}
	return sharedKumulosHelper;
}
*/

// KumulosHelper should not be a singleton!

-(id)init
{
	self = [super init];
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    
    savedInfo = [[NSMutableDictionary alloc] init];
    
    if (retainedHelpers == nil)
        retainedHelpers = [[NSMutableSet alloc] init];
    
	return self;
}

-(void)execute:(NSString*)_function withParams:(NSMutableArray*)params withCallback:(SEL)_callback withDelegate:(NSObject<KumulosHelperDelegate>*)helperDelegate{
    
    NSLog(@"KumulosHelper starting executing %@", _function);

    [retainedHelpers addObject:self];
    
    KSAPIOperation * kOp = nil;
    
    [self setInputParams:params];
    [self setFunction:_function];
    [self setCallback:_callback];
    delegate = helperDelegate;
    if ([function isEqualToString:@"getAllUsersForUpdatePhotos"]) {
        kOp = [k getAllUsers];
    }
    else if ([function isEqualToString:@"sharePix"]) {
        assert([inputParams count] == 1);
        [k savePixWithPixPNG:[inputParams objectAtIndex:0]];
    }
    else if ([function isEqualToString:@"getSubcategories"]) {
        [k getAllCategories];
    }
    else if ([function isEqualToString:@"getCommentHistory"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        kOp = [k getAllHistoryWithTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"addCommentToPix"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * name = [inputParams objectAtIndex:1];
        NSString * comment = [inputParams objectAtIndex:2];
        NSString * stixStringID = [inputParams objectAtIndex:3];
        [k addCommentToPixWithTagID:[tagID intValue] andUsername:name andComment:comment andStixStringID:stixStringID];
        
        [savedInfo setObject:tagID forKey:@"addCommentToPix_tagID"];
    }
    else if ([function isEqualToString:@"addCommentToPixWithDetailViewController"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * name = [inputParams objectAtIndex:1];
        NSString * comment = [inputParams objectAtIndex:2];
        NSString * stixStringID = [inputParams objectAtIndex:3];
        id detailViewController = [inputParams objectAtIndex:4];
        [k addCommentToPixWithTagID:[tagID intValue] andUsername:name andComment:comment andStixStringID:stixStringID];
        
        [savedInfo setObject:tagID forKey:@"addCommentToPix_tagID"];
        [savedInfo setObject:detailViewController forKey:@"addCommentToPix_detailViewController"];
    }
    else if ([function isEqualToString:@"getFacebookUser"]) {
        NSNumber * facebookString = [inputParams objectAtIndex:0];
        NSLog(@"Calling kumulos getFaceBookUser with facebookString %@", facebookString);
        kOp = [k getFacebookUserWithFacebookID:[facebookString longLongValue]];
    }
    else if ([function isEqualToString:@"addPixBelongsToUser"]) {
        NSString * username = [inputParams objectAtIndex:0];
        NSNumber * tagID = [inputParams objectAtIndex:1];
        NSLog(@"addPixBelongsToUser: %@ tagID %d", username, [tagID intValue]);
        [savedInfo setObject:username forKey:@"addPixBelongsToUser_username"];
        [savedInfo setObject:tagID forKey:@"addPixBelongsToUser_tagID"];
        kOp = [k addPixBelongsToUserWithUsername:username andTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"checkForUpdatedStix"]) {
        void * tag = [inputParams objectAtIndex:0];
        NSNumber * tagID = [inputParams objectAtIndex:1];
        [savedInfo setObject:tag forKey:@"tag"];
        //[k getAllHistoryWithTagID:[tagID intValue]];
        kOp = [k getAllAuxiliaryStixWithTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"updateStixForPix"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        [savedInfo setObject:tagID forKey:@"tagID"];
        kOp = [k getAllTagsWithIDRangeWithId_min:[tagID intValue]-1 andId_max:[tagID intValue]+1];
    }
    else if ([function isEqualToString:@"getAuxiliaryStixOfTag"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        [savedInfo setObject:tagID forKey:@"tagID"];
        NSLog(@"KumulosHelper trying to getAuxiliaryStixOfTag for tagID %d", [tagID intValue]);
        kOp = [k getAllAuxiliaryStixWithTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"removeAuxiliaryStix"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * stixStringID = [inputParams objectAtIndex:1];
        CGPoint location = [[inputParams objectAtIndex:2] CGPointValue];
        [savedInfo setObject:tagID forKey:@"tagID"];
        [k removeAuxiliaryStixFromPixWithTagID:[tagID intValue] andStixStringID:stixStringID andX:location.x andY:location.y];
    }
    else if ([function isEqualToString:@"createNewPix"]) {
        Tag * newTag = [inputParams objectAtIndex:0];
        NSNumber * remixMode = [inputParams objectAtIndex:1];
        NSData * theImgData = UIImageJPEGRepresentation([newTag image], .8); 
        NSData * theStixLayerData = UIImagePNGRepresentation([newTag stixLayer]); // must be PNG for transparency 
        [savedInfo setObject:newTag forKey:@"tag"];
        [savedInfo setObject:remixMode forKey:@"remixMode"];
#if ADMIN_TESTING_MODE
        // debug mode
        Tag * tag = [savedInfo objectForKey:@"tag"];
        NSNumber * newRecordID = [NSNumber numberWithInt:9999];
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, tag, remixMode, nil];
        [self doCallback:returnParams];
#else
        kOp = [k createPixWithUsername:newTag.username andDescriptor:newTag.descriptor andImage:theImgData andStixLayer:theStixLayerData andPendingID:[newTag.tagID intValue] andHighResImageID:[newTag.highResImageID intValue]];
#endif
    }
    else if ([function isEqualToString:@"getFollowList"]) {
        NSString * name = [inputParams objectAtIndex:0];
        kOp = [k getFollowListWithUsername:name];
    }
    else if ([function isEqualToString:@"getFollowersOfUser"]) {
        NSString * name = [inputParams objectAtIndex:0];
        kOp = [k getFollowersOfUserWithFollowsUser:name];
    }
    else if ([function isEqualToString:@"getHighResImage"]) {
        Tag * tag = [inputParams objectAtIndex:0];
        NSNumber * highResImageID = tag.highResImageID;
        [savedInfo setObject:tag forKey:@"tag"];
        kOp = [k getHighResImageWithAllPixHighReID:[highResImageID intValue]];
    }
    else if ([function isEqualToString:@"getHighResImageForTagID"]) {
        Tag * tag = [inputParams objectAtIndex:0];
        [savedInfo setObject:tag forKey:@"tag"];
        kOp = [k getHighResImageForTagIDWithTagID:[tag.tagID intValue]];
    }
    else if ([function isEqualToString:@"addHighResPix"]) {
        NSData * largeImgData = [inputParams objectAtIndex:0];
        NSNumber * tagID = [inputParams objectAtIndex:1];
        kOp = [k addHighResPixWithDataPNG:largeImgData andTagID:[tagID intValue]];
        [savedInfo setObject:tagID forKey:@"tagID"];
    }
    else if ([function isEqualToString:@"setHighResImageID"]) {
        NSNumber * highResID = [inputParams objectAtIndex:0];
        NSNumber * tagID = [inputParams objectAtIndex:1];
        kOp = [k setHighResImageIDWithAllTagID:[tagID intValue] andHighResImageID:[highResID intValue]];
    }
    else if ([function isEqualToString:@"updateStixLayer"]) {
        Tag * tag = [inputParams objectAtIndex:0];
        NSData * stixLayerData = [inputParams objectAtIndex:1];
        kOp = [k updateStixLayerWithAllTagID:[tag.tagID intValue] andStixLayer:stixLayerData];
        [savedInfo setObject:tag forKey:@"tag"];
    }
    else if ([function isEqualToString:@"setOriginalUsername"]) {
        NSNumber * tagID = [inputParams objectAtIndex:0];
        NSString * username = [inputParams objectAtIndex:1];
        kOp = [k setOriginalUsernameWithAllTagID:[tagID intValue] andOriginalUsername:username];
        //[savedInfo setObject:tagID forKey:@"tagID"];
        //[savedInfo setObject:tagID forKey:@"username"];
    }
    else if ([function isEqualToString:@"setFacebookString"]) {
        for (NSMutableDictionary * d in params) {
            NSString * name = [d valueForKey:@"username"];
            NSString * email = [d valueForKey:@"email"];
            NSNumber * facebookID = [d valueForKey:@"facebookID"];
            NSString * facebookString = [NSString stringWithFormat:@"%@", facebookID];
            NSLog(@"Updating facebookString for email %@ to %@", email, facebookString);
            [savedInfo setObject:name forKey:@"username"];
            //kOp = [k setFacebookStringForUserWithEmail:email andFacebookString:facebookString];
            [k setFacebookStringForUserWithEmail:email andFacebookString:facebookString];
        }
    }
    else if ([function isEqualToString:@"incrementPopularity"]) {
        // incremented when commented, shared, remixed, viewed from explore, liked
        NSNumber * tagID = [params objectAtIndex:0];
        kOp = [k incrementPopularityWithAllTagID:[tagID intValue]];
    }
    else if ([function isEqualToString:@"setTwitterString"]) {
        NSNumber * userID = [inputParams objectAtIndex:0];
        NSString * twitterString = [inputParams objectAtIndex:1];
        NSLog(@"Setting twitterString %@ for user %@", twitterString, userID);
        kOp = [k setTwitterStringForUserWithAllUserID:[userID intValue] andTwitterString:twitterString];
    }
    
    if (!kOp) 
        NSLog(@"KumulosHelper finished executing %@", _function);
    else if (kOp) 
        NSLog(@"KumulosHelper finished executing %@ %@", _function, [kOp description]);
}

-(void)execute:(NSString*)_function {
    [self execute:_function withParams:nil withCallback:nil withDelegate:nil];
}

-(void)doCallback:(NSMutableArray*)returnParams {
    if (self.delegate) {
        [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
    }
    [returnParams autorelease];
    [self cleanup];
}

//-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createNewPixDidCompleteWithResult:(NSNumber *)newRecordID {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createPixDidCompleteWithResult:(NSNumber *)newRecordID {
    Tag * tag = [savedInfo objectForKey:@"tag"];
    NSNumber * remixMode = [savedInfo objectForKey:@"remixMode"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, tag, remixMode, nil];
    [self doCallback:returnParams];
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation savePixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, nil];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllAuxiliaryStixDidCompleteWithResult:(NSArray *)theResults {
    if ([function isEqualToString:@"getAuxiliaryStixOfTag"]) {
        NSLog(@"KumulosHelper getAuxiliaryStixOfTag for tagID %@ returned with %d results", [savedInfo objectForKey:@"tagID"], [theResults count]);
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:[savedInfo objectForKey:@"tagID"], theResults, nil];         
        [self doCallback:returnParams];
    }
    else if ([function isEqualToString:@"checkForUpdatedStix"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] init];
        Tag * tag = [savedInfo objectForKey:@"tag"];
        [returnParams addObject:[savedInfo objectForKey:@"tag"]];
        [returnParams addObject:theResults];
        [self doCallback:returnParams];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation removeAuxiliaryStixFromPixDidCompleteWithResult:(NSArray *)theResults {
    // also returns the remaining stix
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:[savedInfo objectForKey:@"tagID"], theResults, nil];         
    [self doCallback:returnParams];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
    if (self.delegate && [function isEqualToString:@"getAllUsersForUpdatePhotos"]) {
        //NSLog(@"KumulosHelper finished getting all users photos: %d photos", [theResults count]);
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];         
        [self doCallback:returnParams];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addPixBelongsToUserDidCompleteWithResult:(NSNumber *)newRecordID {
    NSString * username = [savedInfo objectForKey:@"addPixBelongsToUser_username"];
    NSNumber * tagID = [savedInfo objectForKey:@"addPixBelongsToUser_tagID"];
    NSLog(@"addPixBelongsToUser completed for user %@ tagID %d record id %d", username, [tagID intValue], [newRecordID intValue]);
    [self cleanup];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllCategoriesDidCompleteWithResult:(NSArray *)theResults {
    if ([self.function isEqualToString:@"getSubcategories"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];
        [self doCallback:returnParams];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllHistoryDidCompleteWithResult:(NSArray *)theResults {
    if ([self.function isEqualToString:@"getCommentHistory"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:theResults, nil];
        [self doCallback:returnParams];
    }
    /*
    else if ([function isEqualToString:@"checkForUpdatedStix"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] init];
        [returnParams addObject:[savedInfo objectForKey:@"tag"]];
        [returnParams addObjectsFromArray:theResults];
        if (self.delegate) {
            [self.delegate kumulosHelperDidCompleteWithCallback:self.callback andParams:returnParams];
        }
        [returnParams autorelease];
    }
     */
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addCommentToPixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSNumber * tagID = [savedInfo objectForKey:@"addCommentToPix_tagID"];
    if ([function isEqualToString:@"addCommentToPix"]) {
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, nil];
        [self doCallback:returnParams];
    }    
    else if ([function isEqualToString:@"addCommentToPixWithDetailViewController"]) {
        id detailViewController = [savedInfo objectForKey:@"addCommentToPix_detailViewController"];        
        NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, detailViewController, nil];
        [self doCallback:returnParams];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray *)theResults {
    NSNumber * tagID = [savedInfo objectForKey:@"tagID"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tagID, theResults, nil];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithArray:theResults];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowListDidCompleteWithResult:(NSArray *)theResults {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithArray:theResults];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowersOfUserDidCompleteWithResult:(NSArray *)theResults {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithArray:theResults];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getHighResImageDidCompleteWithResult:(NSArray *)theResults {
    // called using the highResTagID
    Tag * tag = [savedInfo objectForKey:@"tag"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tag, theResults, nil];
    [self doCallback:returnParams];
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getHighResImageForTagIDDidCompleteWithResult:(NSArray *)theResults {
    Tag * tag = [savedInfo objectForKey:@"tag"];
    // called using tagID
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:tag, theResults, nil];
    [self doCallback:returnParams];
}

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addHighResPixDidCompleteWithResult:(NSNumber *)newRecordID {
    NSNumber * tagID = [savedInfo objectForKey:@"tagID"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:newRecordID, tagID, nil];
    [self doCallback:returnParams];
}

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation setOriginalUsernameDidCompleteWithResult:(NSNumber *)affectedRows {
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects:nil];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updateStixLayerDidCompleteWithResult:(NSNumber *)affectedRows {
    Tag * tag = [savedInfo objectForKey:@"tag"];
    NSMutableArray * returnParams = [[NSMutableArray alloc] initWithObjects: tag, nil];
    [self doCallback:returnParams];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation incrementPopularityDidCompleteWithResult:(NSNumber *)affectedRows {
    [self cleanup];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation setFacebookStringForUserDidCompleteWithResult:(NSNumber *)affectedRows {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation setFacebookStringForUserDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"SetFacebookString completed for %@", [savedInfo objectForKey:@"username"]);
    [self cleanup];
}

#pragma mark error handling for kumulos helper
-(void)kumulosAPI:(kumulosProxy *)kumulos apiOperation:(KSAPIOperation *)operation didFailWithError:(NSString *)theError {
    NSLog(@"KumulosHelper failed during function: %@ with op %@ with error %@", function, [operation description], theError);
    
    // retry if desired
    if ([function isEqualToString:@"getFacebookUser"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(kumulosHelperGetFacebookUserDidFail)])
            [delegate kumulosHelperGetFacebookUserDidFail];
    }
    else if ([function isEqualToString:@"getAllUsersForUpdatePhotos"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"createNewPix"]) {
        // NOT coming here so we create some other timeout
        if (self.delegate && [delegate respondsToSelector:@selector(kumulosHelperCreateNewPixDidFail:)]) {
            Tag * failedTag = [inputParams objectAtIndex:0];
            [delegate kumulosHelperCreateNewPixDidFail:failedTag];
        }
    }
    else if ([function isEqualToString:@"getAuxiliaryStixOfTag"]) {
        // if this happens while we are trying to load galleries, we need 
        // to decrement pendingContentCount
        // instead, redo
        NSLog(@"KumulosHelper: getAuxiliaryStixOfTag failed for tagID %@", [savedInfo objectForKey:@"tagID"]);
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"addPixBelongsToUser"]) {
        NSLog(@"addPixBelongsToUser failed!");
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"getFollowList"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"getFollowersOfUser"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"getHighResImage"]) {
        
    }
    else if ([function isEqualToString:@"addHighResPix"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"setHighResImageID"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
    else if ([function isEqualToString:@"setOriginalUsername"]) {
        [self execute:function withParams:inputParams withCallback:callback withDelegate:delegate];
    }
}

-(void)cleanup {
    [inputParams release];
    [retainedHelpers removeObject:self];
}

@end
