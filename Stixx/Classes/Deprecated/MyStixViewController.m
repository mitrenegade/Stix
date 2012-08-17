//
//  MyStixViewController.m
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyStixViewController.h"

@implementation MyStixViewController

//@synthesize badgeView;
@synthesize delegate;
@synthesize buttonRules;
@synthesize tableController;
@synthesize buttonFeedback;

#define BADGE_MYSTIX_PADDING 45 // how many pixels per side in mystix view

-(id)init
{
	self = [super initWithNibName:@"MyStixViewController" bundle:nil];
	
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
        
    buttonRules = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
    [buttonRules addTarget:self
               action:@selector(didClickOnButtonRules:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRules];
    [buttonRules setHidden:YES];
        
    tableController = [[GiftStixTableController alloc] init];
    [tableController.view setFrame:CGRectMake(0, 215, 320, 200)];
    [tableController setDelegate:self];
    //[self.view addSubview:tableController.view];
    [self.view insertSubview:tableController.view belowSubview:[self buttonFeedback]];

}

-(void)createCarouselView {
    if (carouselView != nil && [carouselView isKindOfClass:[CarouselView class]]) {
        [carouselView clearAllViews];
        [carouselView release];
    }
    carouselView = [[CarouselView alloc] initWithFrame:self.view.frame];
    carouselView.delegate = self;
    [carouselView initCarouselWithFrame:CGRectMake(15,90,305,75)];
//    [self.view addSubview:carouselView];
    [self.view insertSubview:carouselView belowSubview:[self buttonFeedback]];

}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"MyStix view"];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [tableController reloadStixCounts];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**** badgeViewDelegate - never used because no badgeView is shown ****/
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {};

/**** ScrollView delegate *****/

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {        
    
    //UITouch *touch = [[event allTouches] anyObject];	        
    //CGPoint location = [touch locationInView:self.view];
    
    [super touchesEnded:touches withEvent:event];
}

-(IBAction)didClickOnButtonRules:(id)sender {
    [buttonRules setHidden:YES];
}

/*** GiftStixTableControllerDelegate ***/

-(int)getStixCount:(NSString *)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}

-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

@end
