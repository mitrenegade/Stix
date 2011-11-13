//
//  FeedItemViewController.h
//  ARKitDemo
//
//  Created by Administrator on 9/13/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"

@interface FeedItemViewController : UIViewController {
    
	IBOutlet UILabel * labelName;
	IBOutlet UILabel * labelComment;
	IBOutlet UILabel * labelTime;
	IBOutlet UIImageView * imageView;
    IBOutlet UIImageView * userPhotoView;
    
    NSString * nameString;
    NSString * commentString;
    UIImage * imageData;
   
}
@property (retain, nonatomic) IBOutlet UILabel * labelName;
@property (retain, nonatomic) IBOutlet UILabel * labelComment;
@property (retain, nonatomic) IBOutlet UILabel * labelTime;
@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UIImageView * userPhotoView;
@property (nonatomic, retain) NSString * nameString;
@property (nonatomic, retain) NSString * commentString;
@property (nonatomic, retain) UIImage * imageData;

-(void)populateWithName:(NSString *)name andWithComment:(NSString*)comment andWithImage:(UIImage*)image;
-(void)populateWithUserPhoto:(UIImage*)photo;
-(void)populateWithTimestamp:(NSDate *)timestamp;

@end
