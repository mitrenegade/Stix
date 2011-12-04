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
    for (int i=0; i<BADGE_TYPE_MAX; i++)
    {
        [badges addObject:[NSNull null]];
        [labels addObject:[NSNull null]];
    }
    [self forceLoadMyStix];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)forceLoadMyStix {
    NSArray * stixLabels = [[NSArray alloc] initWithObjects:@"Fire", @"Ice", @"Heart", @"Leaf", nil];
    int x=0;
    int y=0;
    int i;
    for (i=0; i<[delegate getStixLevel]; i++) {
        UIImageView * badgeLarge = [[BadgeView getLargeBadgeOfType:i] retain];
        //int centerx = (320-2*BADGE_MYSTIX_PADDING)/3 * x + (320-2*BADGE_MYSTIX_PADDING)/6 + BADGE_MYSTIX_PADDING;
        int centerx = (320 - 2*BADGE_MYSTIX_PADDING)/2 * x + (320-2*BADGE_MYSTIX_PADDING)/4 + BADGE_MYSTIX_PADDING;
        int centery = 480/4 * y + 100;
        badgeLarge.center = CGPointMake(centerx, centery);
        
        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badgeLarge.frame];
        [label setCenter:CGPointMake(centerx, centery+60)];
        [label setTextAttributesForBadgeType:2];
        [label drawTextInRect:CGRectMake(0,0, badgeLarge.frame.size.width*2, 80)];
        [label setText:[stixLabels objectAtIndex:i]];
         
        if ([badges objectAtIndex:i] == [NSNull null]) {
            [badges replaceObjectAtIndex:i withObject:badgeLarge];
            [labels replaceObjectAtIndex:i withObject:label];
        }
        else {
            [[badges objectAtIndex:i] removeFromSuperview];
            [[labels objectAtIndex:i] removeFromSuperview];
            [badges replaceObjectAtIndex:i withObject:badgeLarge];
            [labels replaceObjectAtIndex:i withObject:label];
        }
        [self.view addSubview:badgeLarge];
        [self.view addSubview:label];
        [badgeLarge release];
        [label release];
        x++;
        if (x==2) {
            x=0;
            y++;
        }
    }
    NSLog(@"Badges: %d badge max: %d xy %d %d\n", [delegate getStixLevel], BADGE_TYPE_MAX, x,y);
    for (i=[delegate getStixLevel];i<BADGE_TYPE_MAX; i++) {
        UIImageView * badgeLarge = [[BadgeView getEmptyBadgeOfType:i] retain];
        int centerx = (320 - 2*BADGE_MYSTIX_PADDING)/2 * x + (320-2*BADGE_MYSTIX_PADDING)/4 + BADGE_MYSTIX_PADDING;
        //int centerx = (320-2*BADGE_MYSTIX_PADDING)/3 * x + (320-2*BADGE_MYSTIX_PADDING)/6 + BADGE_MYSTIX_PADDING;
        int centery = 480/4 * y + 100;
        badgeLarge.center = CGPointMake(centerx, centery);
        if ([badges objectAtIndex:i] == nil) {
            [badges replaceObjectAtIndex:i withObject:badgeLarge];
        }
        [self.view addSubview:badgeLarge];
        [badgeLarge release];
        x++;
        if (x==2) {
            x=0;
            y++;
        }

    }
    [stixLabels release];
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
-(int)getStixCount:(int)stix_type {return 0;};
-(int)getStixLevel {
    return [self.delegate getStixLevel];
}

@end
