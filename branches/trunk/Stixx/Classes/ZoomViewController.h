//
//  ZoomViewController.h
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZoomViewDelegate

-(void)didDismissZoom;

@end

@interface ZoomViewController : UIViewController

{
    IBOutlet UIButton * imageView;
    //IBOutlet UIButton * backButton;
    IBOutlet UILabel * labelComment;
    IBOutlet UILabel * labelCommentBG;
    IBOutlet UILabel * labelLocationString;
	NSObject<ZoomViewDelegate> *delegate;
}
@property (nonatomic, retain) IBOutlet UIButton * imageView;
//@property (nonatomic, retain) IBOutlet UIButton * backButton;
@property (nonatomic, retain) IBOutlet UILabel * labelComment;
@property (nonatomic, retain) IBOutlet UILabel * labelCommentBG;
@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, retain) NSObject<ZoomViewDelegate> *delegate;
@property (nonatomic, retain) ZoomViewController * zoomViewController;
//@property (nonatomic, retain) UIImage * image;
-(IBAction)didPressBackButton:(id)sender;
-(void)forceImageAppear:(UIImage*)img;
-(void)setLabel:(NSString*)label;
-(void)setLocation:(NSString *)location;
@end
