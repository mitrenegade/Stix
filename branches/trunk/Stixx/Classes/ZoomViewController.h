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

@protocol ZoomViewDelegate

-(void)didDismissZoom;

@end

@interface ZoomViewController : UIViewController

{
    IBOutlet UIButton * imageView;
    IBOutlet UILabel * labelComment;
    IBOutlet UILabel * labelLocationString;
	NSObject<ZoomViewDelegate> *delegate;
    StixView * stixView;
}
@property (nonatomic, retain) IBOutlet UIButton * imageView;
@property (nonatomic, retain) IBOutlet UILabel * labelComment;
@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, assign) NSObject<ZoomViewDelegate> *delegate;
@property (nonatomic, retain) StixView * stixView;

-(IBAction)didPressBackButton:(id)sender;
-(void)forceImageAppear:(UIImage*)img;
-(void)setLabel:(NSString*)label;
-(void)setStixUsingTag:(Tag *)tag;
-(void)initStixView:(Tag *)tag;
@end
