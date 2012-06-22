//
//  ColumnTableController.h
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "EGORefreshTableHeaderView.h"
#import "GlobalHeaders.h"

@protocol ColumnTableControllerDelegate <NSObject>

-(int)numberOfRows;
-(void)loadContentPastRow:(int)row;
-(UIView*)viewForItemAtIndex:(int)index;

#if USE_PULL_TO_REFRESH
-(void)didPullToRefresh;
#endif

@optional
-(void)didClickAtLocation:(CGPoint)location;
-(UIView*)headerForSection:(NSInteger)section;
-(int)heightForHeader;
@end

@interface ColumnTableController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSObject<ColumnTableControllerDelegate> * delegate;
    NSMutableDictionary * cellDictionary;

#if USE_PULL_TO_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
    int numColumns;
    int borderWidth;
    int columnPadding;
    int columnWidth;
    int columnHeight;
#endif
    
}

@property (nonatomic) NSObject<ColumnTableControllerDelegate> * delegate;
#if USE_PULL_TO_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL hasHeaderRow;
#endif

-(void)setNumberOfColumns:(int)columns andBorder:(int)border;
- (void)reloadTableViewDataSource;
-(int)getContentWidth;
#if USE_PULL_TO_REFRESH
- (void)dataSourceDidFinishLoadingNewData;
#endif
@end
