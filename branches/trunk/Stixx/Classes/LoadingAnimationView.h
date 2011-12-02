

#import <UIKit/UIKit.h>

@interface LoadingAnimationView : UIImageView {
	UIImageView * customActivityIndicator;
    bool shouldStop;
}
@property (nonatomic, retain) UIImageView * customActivityIndicator;

-(void)startCompleteAnimation;
-(void)stopCompleteAnimation;
-(void)checkForShouldStop;
@end