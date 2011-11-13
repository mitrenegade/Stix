//
//  PagedScrollView.m
//  Stixx
//
//  Created by Bobby Ren on 10/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PagedScrollView.h"

@implementation PagedScrollView

@synthesize myDelegate;
@synthesize scrollViewPages;
@synthesize isLazy;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        isLazy = NO;
    }
    
    return self;
}

-(void)populateScrollPagesAtPage:(int)currentPage {
    // todo: fill out/update a dictionary instead of recreating the whole scroll
    int pageCount = [self.myDelegate itemCount];
    NSLog(@"Initializing %d pages in scroll", pageCount);
    if (scrollViewPages){
        [scrollViewPages release];
    }
    scrollViewPages = [[NSMutableArray alloc] initWithCapacity:pageCount];
    
    // Fill our pages collection with empty placeholders
    for(int i = 0; i < pageCount; i++)
    {
        [scrollViewPages addObject:[NSNull null]];
    }
    
    // Calculate the size of all combined views that we are scrolling through 
    self.contentSize = CGSizeMake([self.myDelegate itemCount] * self.frame.size.width, self.frame.size.height);
    
    // Load the first two pages
    if (currentPage>0)
        [self loadPage:currentPage-1];
    [self loadPage:currentPage];
    if (currentPage<pageCount)
        [self loadPage:currentPage+1];
}

-(void)loadPage:(int)page
{
	// loading pages that do not exist - request from delegate
    if (isLazy && 
        ([scrollViewPages count] == 0 || page < LAZY_LOAD_BOUNDARY || page>=[scrollViewPages count]-LAZY_LOAD_BOUNDARY))
    { 
        // page = -1: look for newer data on server
        // page > total pages: look for older data on server - only for delayed load
        [self.myDelegate updateScrollPagesAtPage:page]; // must use myDelegate, not delegate
    }
	else {
        if (!isLazy) {
            // sanity checks for nonlazy loading
            if ([scrollViewPages count] == 0)
                return;
            if (page < 0)
                return;
            if (page >= [scrollViewPages count])
                return;
        }
        // Check if the page is already loaded
        UIView *view = [scrollViewPages objectAtIndex:page];
        
        // if the view is null we request the view from our delegate
        if ((NSNull *)view == [NSNull null]) 
        {
            view = [[self.myDelegate viewForItemAtIndex:page] retain];
            [scrollViewPages replaceObjectAtIndex:page withObject:view];
            [view release];
        }
        
        // add the controller's view to the scroll view	if it's not already added
        if (view.superview == nil) 
        {
            // Position the view in our scrollview
            CGRect viewFrame = view.frame;
            viewFrame.origin.x = viewFrame.size.width * page;
            viewFrame.origin.y = 0;
            
            view.frame = viewFrame;
            
            [self addSubview:view];
        }
    }
}

-(int)currentPage
{
	// Calculate which page is visible 
	CGFloat pageWidth = self.frame.size.width;
	int page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	return page;
}

-(void)clearNonvisiblePages {
        
    // Calculate the current page in scroll view
    int currentPage = [self currentPage];
    
    // unload the pages which are no longer visible
    for (int i = 0; i < [scrollViewPages count]; i++) 
    {
        UIView *viewController = [scrollViewPages objectAtIndex:i];
        if((NSNull *)viewController != [NSNull null])
        {
            if(i < currentPage-1 || i > currentPage+1)
            {
                [viewController removeFromSuperview];
                [scrollViewPages replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        }
    }
}

-(void)dealloc
{
    [scrollViewPages release];
    [super dealloc];
}

@end
