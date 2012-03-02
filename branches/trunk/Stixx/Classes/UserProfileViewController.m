//
//  UserProfileViewController.m
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "UserProfileViewController.h"

@implementation UserProfileViewController

@synthesize friendCountButton;
@synthesize stixCountButton;
@synthesize delegate;
@synthesize nameLabel;
@synthesize photoButton;
@synthesize navBackButton;
@synthesize addFriendButton;
@synthesize k;

-(id)init
{
	self = [super initWithNibName:@"UserProfileViewController" bundle:nil];
    
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    
    //isLoggedIn = NO;
    
    return self;

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
	//return self;
}

// getUserWithUsername in ProfileViewController is a login operation that populates the profile with all the new user's info
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults {
    if ([theResults count] > 0)
    {
        //for (NSMutableDictionary * d in theResults) {
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        
        // update friend count
        NSMutableDictionary * allUserPhotos = [self.delegate getUserPhotos];
        int ct = [allUserPhotos count];
        [friendCountButton setTitle:[NSString stringWithFormat:@"%d Friends", ct] forState:UIControlStateNormal];

        // total Pix count
        int totalTags = [[d valueForKey:@"totalTags"] intValue];
        // int bux = [[d valueForKey:@"bux"] intValue];
        
        // set Pix count
        [stixCountButton setTitle:[NSString stringWithFormat:@"%d Pix", totalTags] forState:UIControlStateNormal];
    }
    else if ([theResults count] == 0)
    {
        NSLog(@"user doesn't exist!"); // force logout
    }
}




#if 0
-(void)updateFriendCount {
    NSMutableDictionary * allUserPhotos = [self.delegate getUserPhotos];
    int ct = [allUserPhotos count];
    [friendCountButton setTitle:[NSString stringWithFormat:@"%d Friends", ct] forState:UIControlStateNormal];
}

-(void)updatePixCount {
    //int ct = [delegate getStixCount:BADGE_TYPE_FIRE] + [delegate getStixCount:BADGE_TYPE_ICE];
}
#endif

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"Set config namelabel as %@", username);
}

-(void)setUsername:(NSString*)username {
    [nameLabel setText:username];
    
}
-(void)setPhoto:(UIImage*)photo {
    [photoButton setImage:photo forState:UIControlStateNormal];
    [photoButton setBackgroundColor:[UIColor blackColor]];
}

-(void)initializeProfile:(NSString*)username withPhoto: (UIImage*)photo {
    [nameLabel setText:username];
    [photoButton setImage:photo forState:UIControlStateNormal];
    [photoButton setBackgroundColor:[UIColor blackColor]];
    
    // check if trying to access own page
    if ([username isEqualToString:[self.delegate getUsername]])
    {
        [addFriendButton setHidden:YES];
    }
    
    if (k == nil)
    {
        k = [[Kumulos alloc]init];
        [k setDelegate:self];    
    }
    
    [k getUserWithUsername:username];
}

-(void)addFriendButtonClicked:(id)sender {
    
}

-(void)navBackButtonClicked:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    [self.delegate didDismissUserProfileView];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {    
    [stixCountButton release];
    stixCountButton = nil;
    [friendCountButton release];
    friendCountButton = nil;
    [nameLabel release];
    nameLabel = nil;
    [photoButton release];
    photoButton = nil;
    [navBackButton release];
    navBackButton = nil;
    [addFriendButton release];
    addFriendButton = nil;

    [super viewDidUnload];
}


- (void)dealloc {
    [stixCountButton release];
    stixCountButton = nil;
    [friendCountButton release];
    friendCountButton = nil;
    [nameLabel release];
    nameLabel = nil;
    [photoButton release];
    photoButton = nil;
    [navBackButton release];
    navBackButton = nil;
    [addFriendButton release];
    addFriendButton = nil;
    [super dealloc];
}


@end
