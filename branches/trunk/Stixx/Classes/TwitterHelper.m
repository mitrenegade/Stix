//
//  TwitterHelper.m
//  Stixx
//
//  Created by Bobby Ren on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterHelper.h"

@implementation TwitterHelper

@synthesize delegate;
    
static TwitterHelper *sharedTwitterHelper;

+(TwitterHelper*)sharedTwitterHelper 
{
	if (!sharedTwitterHelper){
		sharedTwitterHelper = [[TwitterHelper alloc] init];
	}
	return sharedTwitterHelper;
}

-(void)initTwitter {
    twitter = [[TWTweetComposeViewController alloc] init];

    // Optional: set an image, url and initial text
    //[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
    [twitter addURL:[NSURL URLWithString:[NSString stringWithString:@"http://www.stixmobile.com/"]]];
    [twitter setInitialText:@"Tweeting from Stix."];
    
    // Called when the tweet dialog has been closed
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        NSString *title = @"Tweet Status";
        NSString *msg; 
        
        if (result == TWTweetComposeViewControllerResultCancelled)
            msg = @"Tweet compostion was canceled.";
        else if (result == TWTweetComposeViewControllerResultDone)
            msg = @"Tweet composition completed.";
        
        // Show alert to see how things went...
        //UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        //[alertView show];
        NSLog(@"%@: Tweet dialog completed with message: %@", title, msg);
        
        // Dismiss the controller
//        [self dismissModalViewControllerAnimated:YES];
        [self.delegate twitterDialogDidFinish];
    };
}

-(UIViewController*)getTwitterDialog {
    return twitter;
}

-(void)requestTwitterPostPermission {
    if (![TWTweetComposeViewController canSendTweet]) 
    {
    }
    else 
    {
    }
}

-(void) doTwitterDialog {
    // Create account store, followed by a twitter account identifier
    // At this point, twitter is the only account type available
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to access their Twitter account
    [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
     {
         // Did user allow us access?
         if (granted == YES)
         {
             // Populate array with all available Twitter accounts
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             // Sanity check
             if ([arrayOfAccounts count] > 0) 
             {
                 // Keep it simple, use the first account available
                 ACAccount *acct = [arrayOfAccounts objectAtIndex:0];
                 NSLog(@"Account: %@", acct.description);
             }
         }
     }];
}
@end
