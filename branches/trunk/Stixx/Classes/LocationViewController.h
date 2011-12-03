//
//  LocationViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationSelectedDelegate
-(void)didChooseLocation:(NSString*)location;
@end

@interface LocationViewController : UITableViewController {
    NSObject<LocationSelectedDelegate> *delegate;
}

@property (nonatomic, assign) NSObject<LocationSelectedDelegate> *delegate;
-(void)getFoursquareVenues:(NSString*)text;

@end
