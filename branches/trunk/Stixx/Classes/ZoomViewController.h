//
//  ZoomViewController.h
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "Tag.h"
#import "OutlineLabel.h"
#import "StixView.h"
#import "StixAnimation.h"

@protocol ZoomViewDelegate

-(void)didDismissZoom;

@end

@interface ZoomViewController : UIViewController <StixViewDelegate, StixAnimationDelegate>

{
//    IBOutlet UILabel * labelComment;
//    IBOutlet UILabel * labelLocationString;
	NSObject<ZoomViewDelegate> *delegate;
    StixView * stixView;
    
    int animationID[2];
}
//@property (nonatomic, retain) IBOutlet UILabel * labelComment;
//@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, assign) NSObject<ZoomViewDelegate> *delegate;
@property (nonatomic, retain) StixView * stixView;

//-(IBAction)didPressBackButton:(id)sender;
-(void)initStixView:(Tag *)tag;
@end
