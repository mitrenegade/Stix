//
//  MySHKConfigurator.m
//  Stixx
//
//  Created by Bobby Ren on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySHKConfigurator.h"

@implementation MySHKConfigurator

- (NSString*)appName {
	return @"Stix";
}

- (NSString*)appURL {
	return @"http://stixmobile.com";
}

- (NSString*)facebookAppId {
	return @"191699640937330";
}

//Change if your app needs some special Facebook permissions only. In most cases you can leave it as it is.
- (NSArray*)facebookListOfPermissions {    
    return [NSArray arrayWithObjects: @"user_about_me",@"user_photos",@"publish_stream",@"email",nil];
}
#if 1
- (NSString*)twitterConsumerKey {
	return @"TGqIwGetsrJYAoPYsthQ";
}

- (NSString*)twitterSecret {
	return @"EMVxBTllAHbTSFbS91BqplipZYq14J76Pn9QPCUWxk";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"http://www.stixmobile.com";
}
#else
- (NSString*)twitterConsumerKey {
	return @"48Ii81VO5NtDKIsQDZ3Ggw";
}

- (NSString*)twitterSecret {
	return @"WYc2HSatOQGXlUCsYnuW3UjrlqQj0xvkvvOIsKek32g";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"http://twitter.sharekit.com";
}
#endif

// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}
@end
