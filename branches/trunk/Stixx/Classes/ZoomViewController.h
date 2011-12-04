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
    UIImageView * stix;
    OutlineLabel * stixCount;
	NSObject<ZoomViewDelegate> *delegate;
}
@property (nonatomic, retain) IBOutlet UIButton * imageView;
//@property (nonatomic, retain) IBOutlet UIButton * backButton;
@property (nonatomic, retain) IBOutlet UILabel * labelComment;
@property (nonatomic, retain) IBOutlet UILabel * labelCommentBG;
@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, assign) NSObject<ZoomViewDelegate> *delegate;
@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) OutlineLabel * stixCount;
//@property (nonatomic, retain) UIImage * image;
-(IBAction)didPressBackButton:(id)sender;
-(void)forceImageAppear:(UIImage*)img;
-(void)setLabel:(NSString*)label;
-(void)setLocation:(NSString *)location;
-(void)setStixUsingTag:(Tag *)tag;
@end
