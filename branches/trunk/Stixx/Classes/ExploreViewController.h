//
//  ExploreViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "PagedScrollView.h"
#import "Kumulos.h"
#import "Tag.h"

@protocol ExploreViewDelegate
-(int)getStixCount:(int)stix_type;
-(UIView*)didCreateBadgeView:(UIView*)newBadgeView;

@end

@interface ExploreViewController : UIViewController <BadgeViewDelegate, PagedScrollViewDelegate, KumulosDelegate> 
{
    BadgeView * badgeView; // for dragging and releasing badge

    PagedScrollView *scrollView;	
    NSObject<ExploreViewDelegate> * delegate;
    
    IBOutlet UIButton * refreshButton;
    
    NSMutableArray * allTagIDs;
    NSMutableArray * allTags;
    Kumulos * k;
}

@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, assign) NSObject<ExploreViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * refreshButton;
@property (nonatomic, retain) NSMutableArray * allTagIDs; 
@property (nonatomic, retain) NSMutableArray * allTags; 

- (IBAction)refreshUpdates:(id)sender;
-(void)getTagWithID:(int)id;
@end
