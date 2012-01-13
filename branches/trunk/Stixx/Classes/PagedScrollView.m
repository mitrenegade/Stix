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
@synthesize lastPageCount;
@synthesize drag;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        isLazy = NO;
        scrollViewPages = [[NSMutableArray alloc] init];
        lastPageCount = 0;
    }
    return self;
}

-(void)populateScrollPagesAtPage:(int)currentPage {
    // todo: fill out/update a dictionary instead of recreating the whole scroll
    int pageCount = [self.myDelegate itemCount];
    //NSLog(@"Initializing %d pages in scroll", pageCount);
    if (pageCount != lastPageCount)
    {
        // clear old scrollViewPages
        if (scrollViewPages){
            for (int i=0; i<[scrollViewPages count]; i++){
                UIView * d = (UIView*) [scrollViewPages objectAtIndex:i];
                if ((NSNull*)d != [NSNull null])
                    [d removeFromSuperview];
            }
            [scrollViewPages release];
        }
        scrollViewPages = [[NSMutableArray alloc] initWithCapacity:pageCount];

        // Fill our pages collection with empty placeholders
        for(int i = 0; i < pageCount; i++) // - lastPageCount; i++)
        {
            //[scrollViewPages addObject:[NSNull null]];
            [scrollViewPages insertObject:[NSNull null] atIndex:i];
        }
    
        // Calculate the size of all combined views that we are scrolling through 
        self.contentSize = CGSizeMake([self.myDelegate itemCount] * self.frame.size.width, self.frame.size.height);
        lastPageCount = pageCount;
    }
    
    // Load the first two pages
    if (currentPage>0)
        [self loadPage:currentPage-1];
    [self loadPage:currentPage];
    if (currentPage<pageCount || pageCount == 1)
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
        //if ((NSNull *)view != [NSNull null]) 
        //{
        //    [view removeFromSuperview];
        //}
        if ((NSNull *)view == [NSNull null]) {
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
            //NSLog(@"Inserting frame %d at (%f %f)", page, viewFrame.origin.x, viewFrame.origin.y);
            
            view.frame = viewFrame;
            
            [self addSubview:view];
        }
    }
}

-(void)reloadPage:(int)page {
    if (page >= [scrollViewPages count])
        return;
    UIView *view = [scrollViewPages objectAtIndex:page];
    [view removeFromSuperview];
    
    UIView * newview = [[self.myDelegate viewForItemAtIndex:page] retain];
    [scrollViewPages replaceObjectAtIndex:page withObject:newview];
    [newview release];
    
    // Position the view in our scrollview
    view = [scrollViewPages objectAtIndex:page];
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = viewFrame.size.width * page;
    viewFrame.origin.y = 0;
    
    view.frame = viewFrame;    
    [self addSubview:view];
    
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

-(void)clearAllPages {
    // forces reload of all views
    lastPageCount = -1;
}

/******** process clicks *******/
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	drag = 0;    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	drag = 1;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag != 1)
	{
        UITouch *touch = [[event allTouches] anyObject];	
        CGPoint location = [touch locationInView:self];//touch.view];
        [myDelegate didClickAtLocation:location];
    }
}

-(void)dealloc
{
    [scrollViewPages release];
    [super dealloc];
}

@end
