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
-(void)forceReloadAll;

@optional
-(void)updateScrollPagesAtPage:(int)page;
-(void)didClickAtLocation:(CGPoint)location;

@end

@interface PagedScrollView : UIScrollView <UIScrollViewDelegate>
{
	NSMutableArray *scrollViewPages;
	NSObject<PagedScrollViewDelegate> * __unsafe_unretained myDelegate;
    
    int lastPageCount;
    bool isLazy;
    int drag;
}
/**** from old BSPreviewScrollView ******/
@property (nonatomic, unsafe_unretained) NSObject<PagedScrollViewDelegate> * myDelegate;
@property (nonatomic) NSMutableArray * scrollViewPages;
@property (nonatomic, assign) bool isLazy;
@property (nonatomic, assign) int lastPageCount;
@property (nonatomic, assign) int drag;

-(void)populateScrollPagesAtPage:(int)currentPage;
-(void)loadPage:(int)page;
-(void)reloadPage:(int)page;
-(int)currentPage;
-(void)clearNonvisiblePages; // called by didReceiveMemoryWarning
-(void)clearAllPages;
-(void)jumpToPage:(int)page;
@end
