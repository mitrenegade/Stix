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

@protocol NewsletterViewDelegate <NSObject>

-(NSString*)getUsername;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;

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
}
@property (nonatomic, unsafe_unretained) NSObject<NewsletterViewDelegate> *delegate;
@property (nonatomic) IBOutlet UITableView * tableView;

-(void)initializeNewsletter;
-(void)refreshUserPhotos;
@end
