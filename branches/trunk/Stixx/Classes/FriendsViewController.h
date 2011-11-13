//
//  FriendsViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "PagedScrollView.h"

@protocol FriendsViewDelegate

- (void)checkForUpdatePhotos;
-(NSMutableDictionary *)getUserPhotos;

@end

@interface FriendsViewController : UIViewController <BadgeViewDelegate, PagedScrollViewDelegate>
{
    NSMutableDictionary *userPhotos;
    IBOutlet UIButton * buttonInstructions;
    BadgeView * badgeView;
    IBOutlet UIActivityIndicatorView * activityIndicator;

    PagedScrollView *scrollView;	

    NSObject<FriendsViewDelegate> * delegate;
}
@property (nonatomic, retain) NSMutableDictionary * userPhotos;
@property (nonatomic, assign) NSObject<FriendsViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) PagedScrollView *scrollView;

-(IBAction)closeInstructions:(id)sender;
-(void)setIndicator:(BOOL)animate;

@end

