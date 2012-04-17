

#import <UIKit/UIKit.h>
#define LOADING_ANIMATION_X 200
@interface LoadingAnimationView : UIImageView {
	UIImageView * customActivityIndicator;
    bool shouldStop;
}
@property (nonatomic, retain) UIImageView * customActivityIndicator;

-(void)startCompleteAnimation;
-(void)stopCompleteAnimation;
-(void)checkForShouldStop;
@end