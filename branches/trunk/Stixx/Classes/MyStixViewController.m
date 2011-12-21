//
//  MyStixViewController.m
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyStixViewController.h"

@implementation MyStixViewController

@synthesize badgeView;
@synthesize delegate;
@synthesize buttonRules;
@synthesize tableController;

#define BADGE_MYSTIX_PADDING 45 // how many pixels per side in mystix view

-(id)init
{
	[super initWithNibName:@"MyStixViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"My Stix"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_mystix.png"];
	[tbi setImage:i];
    
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [delegate didCreateBadgeView:badgeView];
    
    badges = [[NSMutableArray alloc] initWithCapacity:BADGE_TYPE_MAX];
    labels = [[NSMutableArray alloc] initWithCapacity:BADGE_TYPE_MAX];
    empties = [[NSMutableArray alloc] initWithCapacity:BADGE_TYPE_MAX];

    //[self generateAllStix];
    
    buttonRules = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
    [buttonRules addTarget:self
               action:@selector(didClickOnButtonRules:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRules];
    [buttonRules setHidden:YES];
        
    tableController = [[GiftStixTableController alloc] init];
    [tableController.view setFrame:CGRectMake(0, 215, 320, 180)];
    [tableController setDelegate:self];
    [self.view addSubview:tableController.view];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self forceLoadMyStix];
}

-(void)generateAllStix {
    NSArray * stixLabels = [BadgeView stixDescriptors];
    int x=0;
    int y=0;
    int i;
    for (i=0; i<BADGE_TYPE_MAX; i++) {
        UIImageView * badgeLarge = [[BadgeView getLargeBadgeOfType:i] retain];
        badgeLarge.frame = CGRectMake(0, 0, badgeLarge.frame.size.width * .9, badgeLarge.frame.size.height * .9);
        //int centerx = (320-2*BADGE_MYSTIX_PADDING)/3 * x + (320-2*BADGE_MYSTIX_PADDING)/6 + BADGE_MYSTIX_PADDING;
        
        int centerx = (320 - 2*BADGE_MYSTIX_PADDING)/2 * x + (320-2*BADGE_MYSTIX_PADDING)/4 + BADGE_MYSTIX_PADDING;
        int centery;// = 480/3 * y + 150;
        if (y == 0)
            centery = 140;
        else
            centery = 330;
        badgeLarge.center = CGPointMake(centerx, centery);
        
        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badgeLarge.frame];
        [label setCenter:CGPointMake(centerx, centery+60)];
        [label setTextAttributesForBadgeType:2];
        [label drawTextInRect:CGRectMake(0,0, badgeLarge.frame.size.width*2, 80)];
        [label setText:[stixLabels objectAtIndex:i]];
         
        UIImageView * empty = [[BadgeView getEmptyBadgeOfType:i] retain];
        empty.center = CGPointMake(centerx, centery);

        [badges insertObject:badgeLarge atIndex:i];
        [labels insertObject:label atIndex:i];
        [empties insertObject:empty atIndex:i];   

        [self.view addSubview:badgeLarge];
        [self.view addSubview:label];
        [self.view addSubview:empty];
        [label release];

        x++;
        if (x==2) {
            x=0;
            y++;
        }
        
    }
}

-(void)forceLoadMyStix {
#if 0
    int level = BADGE_TYPE_ICE + 1; //[delegate getStixLevel];
    for (int i=0; i<level; i++) {
        [[badges objectAtIndex:i] setHidden:NO];
        [[labels objectAtIndex:i] setHidden:NO];
        [[empties objectAtIndex:i] setHidden:YES];
    }
    for (int i=level;i<BADGE_TYPE_MAX; i++) {
        [[badges objectAtIndex:i] setHidden:YES];
        [[labels objectAtIndex:i] setHidden:YES];
        [[empties objectAtIndex:i] setHidden:NO];
        
        //[[badges objectAtIndex:i] removeFromSuperview];
        //[[labels objectAtIndex:i] removeFromSuperview];
        //[self.view addSubview:[empties objectAtIndex:i]];
    }
#endif
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [badgeView release];
    badgeView = nil;
    [badges release];
    badges = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**** badgeViewDelegate - never used because no badgeView is shown ****/
-(void)didDropStix:(UIImageView *)badge ofType:(int)type {};
-(int)getStixLevel {
    return [self.delegate getStixLevel];
}


/**** ScrollView delegate *****/

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {        
    
    UITouch *touch = [[event allTouches] anyObject];	        
    CGPoint location = [touch locationInView:self.view];
    
    return;
#if 0
    // eventually this behavior will be done through scrollview
    // right now it's just a click
    //[myDelegate didClickAtLocation:location];
    UIImageView * badgeSelected = nil;
    UIImageView * emptySelected = nil;
    int type = -1;
    for (int i=0; i<[delegate getStixLevel]; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        if (location.x >= badge.frame.origin.x && location.x <= badge.frame.origin.x + badge.frame.size.width && location.y >= badge.frame.origin.y && location.y <= badge.frame.origin.y + badge.frame.size.height) {
            badgeSelected = badge;
            type = i;
        }
    }
    for (int i=[delegate getStixLevel]; i<BADGE_TYPE_MAX; i++)
    {
        UIImageView * badge = [empties objectAtIndex:i];
        if (location.x >= badge.frame.origin.x && location.x <= badge.frame.origin.x + badge.frame.size.width && location.y >= badge.frame.origin.y && location.y <= badge.frame.origin.y + badge.frame.size.height) {
            emptySelected = badge;
            type = i;
        }
    }
    
    if (badgeSelected != nil && emptySelected == nil) {
#if 0
        // display approporiate badge info
        NSMutableArray * filenames = [[NSMutableArray alloc] initWithObjects:@"Fire Stix: what's hot?", @"Ice Stix: what's not hot?", @"Heart Stix: what's passionate?", @"Leaf Stix: What's natural?", nil];
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setTitle:@"About the Stix"];
        [alert setMessage:[filenames objectAtIndex:type]];
        [alert show];
        [alert release];
#else
        NSMutableArray * filenames = [[NSMutableArray alloc] initWithObjects:@"graphic_rules_fire.png", @"graphic_rules_ice.png", @"graphic_rules_heart.png", @"graphic_rules_leaf.png", nil];
        UIImage * rules = [UIImage imageNamed:[filenames objectAtIndex:type]];
        [buttonRules setHidden:NO];
        [buttonRules setImage:rules forState:UIControlStateNormal];
        [buttonRules setCenter:CGPointMake(160,230)];
        //[rules release];
        [filenames release];
#endif
    }
    else if (badgeSelected == nil && emptySelected != nil) {
        // display approporiate empty info
#if 0
        NSMutableArray * filenames = [[NSMutableArray alloc] initWithObjects:@"Fire Stix: what's hot?", @"Ice Stix: what's not hot?", @"Heart Stix: what's passionate?", @"Leaf Stix: What's natural?", nil];
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setTitle:@"About the Stix"];
        [alert setMessage:[filenames objectAtIndex:type]];
        [alert show];
        [alert release];
#else
        NSMutableArray * filenames = [[NSMutableArray alloc] initWithObjects:@"graphic_rules_fire.png", @"graphic_rules_ice.png", @"graphic_rules_heart.png", @"graphic_rules_leaf.png", nil];
        UIImage * rules = [UIImage imageNamed:[filenames objectAtIndex:type]];
        [buttonRules setHidden:NO];
        [buttonRules setImage:rules forState:UIControlStateNormal];
        [buttonRules setCenter:CGPointMake(160,230)];
        //[rules release];
        [filenames release];
#endif
    }
    else {
        // not a touch for info, do nothing
    }
#endif
}

-(IBAction)didClickOnButtonRules:(id)sender {
    [buttonRules setHidden:YES];
}

/*** GiftStixTableControllerDelegate ***/

-(int)getStixCount:(int)type {
    // also a badgeViewDelegate call
    return [self.delegate getStixCount:type];
}

@end
