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

-(id)init
{
	self = [super initWithNibName:@"UserProfileViewController" bundle:nil];
    return self;

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
	//return self;
}
#if 0
-(void)updateFriendCount {
    NSMutableDictionary * allUserPhotos = [self.delegate getUserPhotos];
    int ct = [allUserPhotos count];
    [friendCountButton setTitle:[NSString stringWithFormat:@"%d Friends", ct] forState:UIControlStateNormal];
}

-(void)updatePixCount {
    //int ct = [delegate getStixCount:BADGE_TYPE_FIRE] + [delegate getStixCount:BADGE_TYPE_ICE];
    int ct = [delegate getUserTagTotal];
    [stixCountButton setTitle:[NSString stringWithFormat:@"%d Pix", ct] forState:UIControlStateNormal];
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
