//
//  FeedTableController.h
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "EGORefreshTableHeaderView.h"
#import "VerticalFeedItemController.h"

#define LAZY_LOAD_BOUNDARY 0
#define HEADER_HEIGHT 40

@protocol FeedTableControllerDelegate <NSObject>

-(Tag *) tagAtIndex:(int)index; // to get tagID
-(UIView*)viewForItemAtIndex:(int)index;
-(UIView*)viewForItemWithTagID:(NSNumber*)tagID;
-(int)itemCount;
-(int)numberOfSections;
-(UIView*)headerForSection:(int)index;
-(int)getHeightForSection:(int)index;
-(int)heightForHeaderInSection:(int)index;
-(void)didPullToRefresh;
-(void)didPullToRefreshDoActivityIndicator;

@optional
-(void)updateScrollPagesAtPage:(int)page;
-(void)didClickAtLocation:(CGPoint)location;

@end

@interface FeedTableController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSObject<FeedTableControllerDelegate> * delegate;
    NSMutableDictionary * cellDictionary;

//    NSMutableArray *contentPageIDs; 
    int drag;

	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
}

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic) NSObject<FeedTableControllerDelegate> * delegate;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;

//-(void)setContentPageIDs:(NSMutableArray *) tags;
-(int)getCurrentSectionAtPoint:(CGPoint) point;
-(CGPoint)getContentPoint:(CGPoint)point inSection:(int)section;
-(CGPoint)getPointInTableViewFrame:(CGPoint)point fromPage:(int)section;
@end
