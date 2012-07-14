//
//  NewsletterViewController.h
//  Stixx
//
//  Created by Bobby Ren on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"
#import "GlobalHeaders.h"
#import "LoadingAnimationView.h"
#import "EGORefreshTableHeaderView.h"

@protocol NewsletterViewDelegate <NSObject>

-(NSString*)getUsername;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
-(void)didGetNews;
@end

@interface NewsletterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, KumulosDelegate>
{
    IBOutlet UITableView * tableView;
    Kumulos * k;    
    NSObject<NewsletterViewDelegate>* __unsafe_unretained delegate;
    NSMutableArray * headerViews;
    
    NSMutableArray * agentArray;
    NSMutableArray * newsArray;
    NSMutableArray * thumbnailArray;

    LoadingAnimationView * activityIndicator;
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
@property (nonatomic, unsafe_unretained) NSObject<NewsletterViewDelegate> *delegate;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) LoadingAnimationView * activityIndicator;

#if USE_PULL_TO_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL hasHeaderRow;
#endif

#if USE_PULL_TO_REFRESH
- (void)dataSourceDidFinishLoadingNewData;
#endif
-(void)initializeNewsletter;
-(void)refreshUserPhotos;
@end
