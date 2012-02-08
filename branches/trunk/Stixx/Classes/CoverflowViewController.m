//
//  CoverflowViewController.m
//  Stixx
//
//  Created by Bobby Ren on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoverflowViewController.h"

@implementation CoverflowViewController

@synthesize coverflow;
@synthesize delegate;

- (void)dealloc
{
	[covers release];
	[coverflow release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Setup the covers
	covers = [[NSMutableArray alloc] init];
    NSMutableArray * filenames = [self.delegate getCoverFilenames];
    for (int i=0; i<[filenames count]; i++) {
        NSString * name = [filenames objectAtIndex:i];
        UIImage * coverImage = [UIImage imageNamed:name];
        NSLog(@"Adding coverimage for category %i with filename %@", i, [filenames objectAtIndex:i]);
        [covers addObject:coverImage];
    }
               
/*
			   [UIImage imageNamed:@"category_entertainment.png"],[UIImage imageNamed:@"category_entertainment.png"],
			   [UIImage imageNamed:@"category_entertainment.png"],[UIImage imageNamed:@"category_entertainment.png"],
			   [UIImage imageNamed:@"category_entertainment.png"],[UIImage imageNamed:@"category_entertainment.png"],
			   [UIImage imageNamed:@"category_entertainment.png"],[UIImage imageNamed:@"category_entertainment.png"],
			   [UIImage imageNamed:@"category_entertainment.png"],nil] retain];
*/
	
	// Add the coverflow view
	coverflow = [[TKCoverflowView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];// self.view.frame];
	coverflow.coverflowDelegate = self;
	coverflow.dataSource = self;
	[self.view addSubview:coverflow];
	[coverflow setNumberOfCovers:[covers count]];
}

-(void)setCoverflowFrame:(CGRect)frame {
    [coverflow setFrame:frame];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma Coverflow delegate methods
- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasBroughtToFront:(int)index{
    //	NSLog(@"Front %d",index);
    [self.delegate didSelectCoverAtIndex:(int)index];
}

- (TKCoverflowCoverView*) coverflowView:(TKCoverflowView*)coverflowView coverAtIndex:(int)index{
	
	TKCoverflowCoverView *cover = [coverflowView dequeueReusableCoverView];
	
	if(cover == nil){
		// Change the covers size here
        // rules for baseline: must be greater than coverflow.width
        // baseline determines how far below the top the title is
        // width determines the density of titles
        // if baseline > width, then it is offcenter
        const int width = 200;
        const int baseline = 180;
		cover = [[[TKCoverflowCoverView alloc] initWithFrame:CGRectMake(0, 0, width, 0)] autorelease]; // 224
		cover.baseline = baseline;
		
	}
	cover.image = [covers objectAtIndex:index % [covers count]];
	
	return cover;
	
}
- (void) coverflowView:(TKCoverflowView*)coverflowView coverAtIndexWasDoubleTapped:(int)index{
	TKCoverflowCoverView *cover = [coverflowView coverAtIndex:index];
	if(cover == nil) return;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cover cache:YES];
	[UIView commitAnimations];
	
    //	NSLog(@"Index: %d",index);
}

@end
