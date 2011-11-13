//
//  PagedScrollView.h
//  Stixx
//
//  Created by Bobby Ren on 10/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LAZY_LOAD_BOUNDARY 0 // how many pages to keep as a buffer before initializing lazy load

@protocol PagedScrollViewDelegate <UIScrollViewDelegate>
-(UIView*)viewForItemAtIndex:(int)index;
-(void)initializeScrollWithPageSize:(CGSize)pageSize;
-(int)itemCount;

@optional
-(void)updateScrollPagesAtPage:(int)page;

@end

@interface PagedScrollView : UIScrollView <UIScrollViewDelegate>
{
	NSMutableArray *scrollViewPages;
	NSObject<PagedScrollViewDelegate> * myDelegate;
    
    bool isLazy;
}
/**** from old BSPreviewScrollView ******/
@property (nonatomic, assign) NSObject<PagedScrollViewDelegate> * myDelegate;
@property (nonatomic, retain) NSMutableArray * scrollViewPages;
@property (nonatomic, assign) bool isLazy;

-(void)populateScrollPagesAtPage:(int)currentPage;
-(void)loadPage:(int)page;
-(int)currentPage;
-(void)clearNonvisiblePages; // called by didReceiveMemoryWarning

@end
