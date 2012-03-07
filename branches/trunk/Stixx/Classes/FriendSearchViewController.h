//
//  FriendSearchViewController.h
//  Stixx
//
//  Created by Irene Chen on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendSearchResultsController.h"
#import "Kumulos.h"

@interface FriendSearchViewController : UIViewController<FriendSearchResultsDelegate, KumulosDelegate>

@property (retain, nonatomic) FriendSearchResultsController * resultsTable;
@property (retain, nonatomic) NSMutableArray * allUserInfo;

@end
