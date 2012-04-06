//
//  StixView.m
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StixView.h"
#import <QuartzCore/QuartzCore.h>

@implementation StixView

@synthesize stix;
@synthesize stixCount;
@synthesize interactionAllowed;
//@synthesize stixScale;
//@synthesize stixRotation;
@synthesize auxStixViews, auxStixStringIDs;
@synthesize isPeelable;
@synthesize delegate;
@synthesize referenceTransform;
@synthesize selectStixStringID;
@synthesize tagID;
@synthesize stixViewID;

static NSMutableDictionary * requestDictionaryForStix;
static NSMutableDictionary * requestDictionaryForSuperViews;
static NSMutableDictionary * requestDictionaryForDelegates;
static NSMutableDictionary * requestDictionaryForKOps;

static int currentStixViewID = 0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        interactionAllowed = YES;
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
        
        stixViewsMissing = [[NSMutableDictionary alloc] init];
        stixViewID = currentStixViewID++;
    }
    return self;
}

// populates with the image data for the pix
-(void)initializeWithImage:(UIImage*)imageData {
    originalImageSize = imageData.size;
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:imageData];
    [self addSubview:imageView];
    [imageView release];
    _activeRecognizers = [[NSMutableSet alloc] init];
}
-(void)initializeWithImage:(UIImage*)imageData withContextFrame:(CGRect)contextFrame{
    // context frame in which a stix will be dropped - different if we are dropping directly 
    // onto stix View or dropping it from a feed or a live camera
    originalImageSize = CGSizeMake(contextFrame.size.width, contextFrame.size.height);
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:imageData];
    [self addSubview:imageView];
    [imageView release];
    _activeRecognizers = [[NSMutableSet alloc] init];
}

-(void)requestStixFromKumulos:(NSString *)stixStringID forStix:(UIImageView *)auxStix inStixView:(StixView *)stixView{ // andDelegate:(NSObject<StixViewDelegate> *)_delegate {

    NSLog(@"StixView %d requestStixFromKumulos requesting %@", stixViewID, stixStringID);
    
    // add stix to own list
    NSMutableArray * stixArray = [stixViewsMissing objectForKey:stixStringID];
    if (stixArray == nil) {
        stixArray = [[NSMutableArray alloc] init];
    }
    [stixArray addObject:auxStix];
    [stixViewsMissing setObject:stixArray forKey:stixStringID];
    
    if (requestDictionaryForStix == nil) {
        requestDictionaryForStix = [[NSMutableDictionary alloc] init];
        //requestDictionaryForSuperViews = [[NSMutableDictionary alloc] init];
        ///requestDictionaryForDelegates = [[NSMutableDictionary alloc] init];
        //requestDictionaryForKOps = [[NSMutableDictionary alloc] init];
    }
    KSAPIOperation * kOp = [k getStixDataByStixStringIDWithStixStringID:stixStringID];

    // stixView refers to the StixView class that displays all the stix
    NSMutableArray * viewsThatNeedThisStix = [requestDictionaryForStix objectForKey:stixStringID];
    //NSMutableArray * superViewsThatNeedThisStix = [requestDictionaryForSuperViews objectForKey:stixStringID];
    //NSMutableArray * delegatesThatNeedThisStix = [requestDictionaryForDelegates objectForKey:stixStringID];
    //NSMutableArray * kOpsThatNeedThisStix = [requestDictionaryForDelegates objectForKey:stixStringID];
    //NSLog(@"StixView requesting stix data: arrays for %@: in 0x%x there are %d views,%d delegates, and in 0x%x there are %d kOps", stixStringID, viewsThatNeedThisStix,
   //       [viewsThatNeedThisStix count], [delegatesThatNeedThisStix count], kOpsThatNeedThisStix, [kOpsThatNeedThisStix count]);

    if (!viewsThatNeedThisStix)  {
        NSLog(@"Creating new queues for %@", stixStringID);
        viewsThatNeedThisStix = [[NSMutableArray alloc] init];
        //superViewsThatNeedThisStix = [[NSMutableArray alloc] init];
        //delegatesThatNeedThisStix = [[NSMutableArray alloc] init];
        //kOpsThatNeedThisStix = [[NSMutableArray alloc] init];

        [viewsThatNeedThisStix addObject:stixView];
        //[superViewsThatNeedThisStix addObject:superView];
        //[delegatesThatNeedThisStix addObject:_delegate];
        
        // make a list of KSAPIOperations so that once one finishes, cancel the others
        //NSLog(@"kOpsThatNeedThisStix 0x%x adding kOp 0x%x", kOpsThatNeedThisStix, kOp);
        //[kOpsThatNeedThisStix addObject:kOp];
    }
    [requestDictionaryForStix setObject:viewsThatNeedThisStix forKey:stixStringID];
        //[requestDictionaryForSuperViews setObject:superViewsThatNeedThisStix forKey:stixStringID];
        //[requestDictionaryForDelegates setObject:delegatesThatNeedThisStix forKey:stixStringID];
        //[requestDictionaryForKOps setObject:kOpsThatNeedThisStix forKey:stixStringID];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
    
    if ([theResults count] == 0) {
        NSLog(@"StixView: GetStixDataByStixString returned no stix!");
        return;        
    }
    
    // populate all stix
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSString * stixStringID = [d objectForKey:@"stixStringID"];
    NSString * descriptor = [d valueForKey:@"stixDescriptor"];
    NSData * dataPNG = [d valueForKey:@"dataPNG"];
    UIImage * img = [[UIImage alloc] initWithData:dataPNG];
    
    NSMutableArray * viewsThatNeedThisStix = [requestDictionaryForStix objectForKey:stixStringID];
    //NSMutableArray * superViewsThatNeedThisStix = [requestDictionaryForSuperViews objectForKey:stixStringID];
    //NSMutableArray * delegatesThatNeedThisStix = [requestDictionaryForDelegates objectForKey:stixStringID];
    //NSMutableArray * kOpsThatNeedThisStix = [requestDictionaryForKOps objectForKey:stixStringID];

    NSLog(@"StixView %d: GetStixDataByStixString for %@ = %@ returned", stixViewID, descriptor, stixStringID);
    UIImageView * stixExists = [BadgeView getBadgeWithStixStringID:stixStringID];
    if (stixExists.alpha == 0) {
        [BadgeView AddStixView:theResults];
        
        for (int i=0; i<[viewsThatNeedThisStix count]; i++) {
            StixView * stixView = [viewsThatNeedThisStix objectAtIndex:i];
            //UIView * superView = [superViewsThatNeedThisStix objectAtIndex:i];
            //NSObject<StixViewDelegate>*thisDelegate = [delegatesThatNeedThisStix objectAtIndex:i];
            //[stixView setImage:img];
            //[stixView removeFromSuperview];
            //[superView addSubview:stixView];
            NSLog(@"StixView %d is telling stixView %d to reload requested stix %@ = %@", stixViewID, stixView.stixViewID, descriptor, stixStringID);
            //if ([thisDelegate respondsToSelector:@selector(didReceiveRequestedStixViewFromKumulos:)])
            //    [thisDelegate didReceiveRequestedStixViewFromKumulos:theResults]; 
            //else {
            //    NSLog(@"StixView delegate cannot call didReceiveRequestedStixView!");
            //}
            [stixView didReceiveRequestedStix:stixStringID withResults:theResults fromStixView:stixViewID];
        }
        // clear list
        //NSLog(@"StixView: GetStixDataByStixString for %@ = %@ filled %d missing views and cancelled %d identical kOps", descriptor, stixStringID, [viewsThatNeedThisStix count], [kOpsThatNeedThisStix count]-1);
    }
    else {
        NSLog(@"StixView %d: GetStixDataByStixString for %@ = %@ previously finished!", stixViewID, descriptor, stixStringID);
        
        // hack: only remove from own
        NSMutableArray * stixArray = [stixViewsMissing objectForKey:stixStringID];
        if (stixArray) {
            [stixViewsMissing removeObjectForKey:stixStringID];
            NSLog(@"Previously finished stixView still exists in stixViewsMissing");
        } else {
            NSLog(@"Previously finished stixView already removed by sender");
        }
        
        if ([stixViewsMissing count] == 0) {
            NSLog(@"Previously finished StixView %d finished loading all missing stix views!", stixViewID);
            [delegate didReceiveAllRequestedStixViews];
        }
    }
    /*
    for (KSAPIOperation * kOp in kOpsThatNeedThisStix) {
        NSLog(@"--cancelling kOp 0x%x", kOp);
        if (operation != kOp) {
            [kOp cancel];
            NSLog(@"Cancelling kOp");
        }
    }
     */
    //[viewsThatNeedThisStix removeAllObjects];
    //[superViewsThatNeedThisStix removeAllObjects];
    //[delegatesThatNeedThisStix removeAllObjects];
    //[kOpsThatNeedThisStix removeAllObjects];
}

-(void)didReceiveRequestedStix:(NSString *)stixStringID withResults:(NSArray*)theResults fromStixView:(int)senderID{
    NSLog(@"StixView %d received stix %@ sent by stixView %d", stixViewID, stixStringID, senderID);
    
    // remove auxStix from stixViewsMissing list
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
    NSMutableArray * stixArray = [stixViewsMissing objectForKey:stixStringID];
    if (stixArray) {
        [stixViewsMissing removeObjectForKey:stixStringID];
        NSLog(@"Filling in %d previously missing stix. Stix types still outstanding: %d", [stixArray count], [stixViewsMissing count]);
    }

    if ([stixViewsMissing count] == 0) {
        NSLog(@"StixView %d finished loading all missing stix views!", stixViewID);
        [delegate didReceiveAllRequestedStixViews];
    }
}

// originally initializeWithImage: withStix:
// this function creates a temporary stix object that can be manipulated
-(void)populateWithStixForManipulation:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y /*andScale:(float)scale andRotation:(float)rotation */{
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    referenceTransform = CGAffineTransformIdentity;
    
    [self setSelectStixStringID:stixStringID];
    stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
    if (stix.alpha == 0) { // alpha is set to 0 by [BadgeView getBadgeForStixStringId]
        NSLog(@"Should not get here!");
        //[self requestStixFromKumulos:stixStringID forStixView:stix inSuperView:self andDelegate:delegate];
    }
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = x;
    float centerY = y;
    NSLog(@"StixView creating %@ stix to %d %d in image of size %f %f", stixStringID, x, y, self.frame.size.width, self.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = originalImageSize;
	CGSize targetSize = self.frame.size;
	
    imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.size.width *= imageScale;// * stixScale;
	stixFrameScaled.size.height *= imageScale;// * stixScale;
    centerX *= imageScale;
    centerY *= imageScale;
    //NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, imageView.frame.size.width, imageView.frame.size.height); 
    [stix setFrame:stixFrameScaled];
    [stix setCenter:CGPointMake(centerX, centerY)];
    [self addSubview:stix];
        
    // add pinch gesture recognizer
    // add gesture recognizer
    UIPinchGestureRecognizer * myPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchGestureHandler:)];
    [myPinchRecognizer setDelegate:self];
    
    
    UIRotationGestureRecognizer *myRotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchRotateHandler:)];
    [myRotateRecognizer setDelegate:self];
    
#if 0
    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:2];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];

    if (isPeelable)
        [self addGestureRecognizer:myTapRecognizer];
#endif
    
    if (interactionAllowed) {
        [self addGestureRecognizer:myPinchRecognizer];
        [self addGestureRecognizer:myRotateRecognizer];    
    }

    // display transform box 
    showTransformCanvas = YES;
    transformCanvas = nil;
    [self transformBoxShowAtFrame:stix.frame];
}

-(void)updateStixForManipulation:(NSString*)stixStringID {
    CGPoint center = stix.center;
    CGAffineTransform transform = stix.transform;
    [stix removeFromSuperview];
    [stix release];
    stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
    [stix setCenter:center];
    [stix setTransform:transform];
    [self addSubview:stix];
    [self setSelectStixStringID:stixStringID];
}

-(int)populateWithAuxStixFromTag:(Tag *)tag {
    int allStixViewsExist = 1; // returns 1 if populated, 0 if missing stix
    auxStixStringIDs = tag.auxStixStringIDs;
    NSMutableArray * auxLocations = tag.auxLocations;
    NSMutableArray * auxTransforms = tag.auxTransforms;
    auxPeelableByUser = [[NSMutableArray alloc] init]; // = tag.auxPeelable;
    auxStixViews = [[NSMutableArray alloc] init];
    tagID = tag.tagID;
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        CGAffineTransform auxTransform;
        NSString * transformString = [auxTransforms objectAtIndex:i];
        auxTransform = CGAffineTransformFromString(transformString); // if fails, returns identity
        UIImageView * auxStix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
        // hack: call update
        if (auxStix.alpha == 0) {
            [self requestStixFromKumulos:stixStringID forStix:auxStix inStixView:self];
            allStixViewsExist = 0;
        }
        
        // shortcircuit populateWithAuxStixFromTag because if any stix doesn't exist
        // this whole StixView will have to be repopulated once we receive all stix
        // requests. but we do have to run through all stix to initiate the requests
        if (!allStixViewsExist)
            continue;
        
        //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
        float centerX = location.x;
        float centerY = location.y;
        
        // scale stix and label down to 270x270 which is the size of the feedViewItem
        CGSize originalSize = originalImageSize;
        CGSize targetSize = self.frame.size;
        imageScale = targetSize.width / originalSize.width;

        CGRect stixFrameScaled = auxStix.frame;
        stixFrameScaled.size.width *= imageScale;// * auxScale;
        stixFrameScaled.size.height *= imageScale;// * auxScale;
        centerX *= imageScale;
        centerY *= imageScale;
        //NSLog(@"StixView: Scaling badge of %f %f at %f %f in image %f %f down to %f %f at %f %f in image %f %f", auxStix.frame.size.width, auxStix.frame.size.height, location.x, location.y, originalImageSize.width, originalImageSize.height, stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, targetSize.width, targetSize.height); 
        [auxStix setFrame:stixFrameScaled];
        [auxStix setCenter:CGPointMake(centerX, centerY)];
        auxStix.transform = auxTransform;
        
        bool isPeelableByUser = NO;
        if (isPeelable) {
            BOOL stixIsPeelable = [[tag.auxPeelable objectAtIndex:i] boolValue];
            NSString * tagUsername = tag.username;
            NSString * delegateUsername = [self.delegate getUsername];
            if (stixIsPeelable == YES && [tagUsername isEqualToString:delegateUsername]) {

                isPeelableByUser = YES;
                // turn this stix into an animated one
                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                UIImage * img1 = [[auxStix image] copy];
                UIImage * img2 = [UIImage imageNamed:@"120_blank.png"];
                crossFade.duration = 1.0;
                crossFade.fromValue = (id)(img1.CGImage);
                crossFade.toValue = (id)(img2.CGImage);
                crossFade.autoreverses = YES;
                crossFade.repeatCount = HUGE_VALF;
                [auxStix.layer addAnimation:crossFade forKey:@"crossFade"];
                [img1 release];
            } 
            else {
                isPeelableByUser = NO;
            }
        }
        [self addSubview:auxStix];
        //NSLog(@"StixView: adding %@ auxStix %@ at center %f %f\n", isPeelableByUser?@"peelable":@"attached", stixStringID, centerX, centerY);
        
        [auxStixViews addObject:auxStix];
        [auxStix release];
        //[auxScales addObject:[NSNumber numberWithFloat:auxScale]];
        [auxPeelableByUser addObject:[NSNumber numberWithBool:isPeelableByUser]];
    }
    return allStixViewsExist;
}

-(void)doPeelAnimationForStix:(int)index {
    UIImageView * auxStix = [auxStixViews objectAtIndex:index];
    [auxStix.layer removeAllAnimations];
    CGRect frameLift = auxStix.frame;
    CGPoint center = auxStix.center;
    frameLift.size.width *= 2;
    frameLift.size.height *= 2;
    frameLift.origin.x = center.x - frameLift.size.width / 2;
    frameLift.origin.y = center.y - frameLift.size.height / 2;
    [UIView transitionWithView:auxStix 
                      duration:.5
                       options:UIViewAnimationTransitionNone 
                    animations: ^ { auxStix.frame = frameLift; } 
                    completion: nil
     ];
    CGRect frameDisappear = CGRectMake(160, 300, 5, 5);
    [UIView transitionWithView:auxStix 
                      duration:.5
                       options:UIViewAnimationTransitionNone 
                    animations: ^ { auxStix.frame = frameDisappear; } 
                    completion:^(BOOL finished) { 
                        [auxStix removeFromSuperview]; 
                        if ([self.delegate respondsToSelector:@selector(peelAnimationDidCompleteForStix:)])
                            [self.delegate peelAnimationDidCompleteForStix:index]; 
                    }
     ];
}

-(void)transformBoxShowAtFrame:(CGRect)frame {
    int canvasOffset = 5;
    CGRect frameCanvas = frame;
    frameCanvas.origin.x -= canvasOffset;
    frameCanvas.origin.y -= canvasOffset;
    frameCanvas.size.width += 2*canvasOffset;
    frameCanvas.size.height += 2*canvasOffset;
    transformCanvas = [[UIView alloc] initWithFrame:frameCanvas];
    [transformCanvas setAutoresizesSubviews:YES];
    frame.origin.x = canvasOffset;
    frame.origin.y = canvasOffset;
    CGRect frameInside = frame;
    frameInside.origin.x +=1;
    frameInside.origin.y +=1;
    frameInside.size.width -= 2;
    frameInside.size.height -=2;
    UIImageView * transformBox = [[UIImageView alloc] initWithFrame:frameInside];
    transformBox.backgroundColor = [UIColor clearColor];
    transformBox.layer.borderColor = [[UIColor whiteColor] CGColor];
    transformBox.layer.borderWidth = 2.0;
    
    UIImageView * transformBoxShadow = [[UIImageView alloc] initWithFrame:frame];
    transformBoxShadow.backgroundColor = [UIColor clearColor];
    transformBoxShadow.layer.borderColor = [[UIColor blackColor] CGColor];
    transformBoxShadow.layer.borderWidth = 4.0;
    
    [transformCanvas addSubview:transformBoxShadow];
    [transformCanvas addSubview:transformBox];
    UIImage * corners = [UIImage imageNamed:@"dot_boundingbox.png"];
    
    UIImageView * dot1 = [[UIImageView alloc] initWithImage:corners];
    UIImageView * dot2 = [[UIImageView alloc] initWithImage:corners];
    UIImageView * dot3 = [[UIImageView alloc] initWithImage:corners];
    UIImageView * dot4 = [[UIImageView alloc] initWithImage:corners];
    
    [transformCanvas addSubview:dot1];
    [transformCanvas addSubview:dot2];
    [transformCanvas addSubview:dot3];
    [transformCanvas addSubview:dot4];
    float width = frame.size.width / 5;
    float height = frame.size.height / 5;
    [dot1 setFrame:CGRectMake(0, 0, width, height)];
    [dot2 setFrame:CGRectMake(0, 0, width, height)];
    [dot3 setFrame:CGRectMake(0, 0, width, height)];
    [dot4 setFrame:CGRectMake(0, 0, width, height)];
    [dot1 setCenter:CGPointMake(frame.origin.x, frame.origin.y)];
    [dot2 setCenter:CGPointMake(frame.origin.x, frame.origin.y + frame.size.height)];
    [dot3 setCenter:CGPointMake(frame.origin.x+frame.size.width, frame.origin.y)];
    [dot4 setCenter:CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)];
    
    [self addSubview:transformCanvas];
    
    [transformBox release];
    [transformBoxShadow release];
    [dot1 release];
    [dot2 release];
    [dot3 release];
    [dot4 release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) { // skips interaction with stix for dragging
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    isTouch = 1;
    if (isDragging) // will come here if a second finger touches
        return;
    
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];
	isDragging = 0;
    CGRect frame = stix.frame;
    // add an allowance of touch
    int border = frame.size.width / 2;
    frame.origin.x -= border;
    frame.origin.y -= border;
    frame.size.width *= 2;
    frame.size.height *= 2;
    if (CGRectContainsPoint(frame, location))
    {
        isTap = 1;
    }
    
    // point where finger clicked badge
    offset_x = (location.x - stix.center.x);
    offset_y = (location.y - stix.center.y);
    
    //NSLog(@"Touches began: center %f %f touch location %f %f", stix.center.x, stix.center.y, location.x, location.y);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
     if (interactionAllowed == NO) {
        [super touchesMoved:touches withEvent:event];
        return;
    }

    isTouch = 0;
	if (isTap == 1 || isDragging == 1)
	{
        isDragging = 1;
        isTap = 0;
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self];
		// update frame of dragged badge, also scale
		//float scale = 1; // do not change scale while dragging
        
		float centerX = location.x - offset_x;
		float centerY = location.y - offset_y;
        
        // filter out rogue touches, usually when people are using a pinch
        if (abs(centerX - stix.center.x) > 50 || abs(centerY - stix.center.y) > 50) 
            return;
        if (centerX < 0 || centerX > self.frame.size.width || centerY < 0 || centerY > self.frame.size.height)
            return;
        
        stix.center = CGPointMake(centerX, centerY);
        if (stixCount != nil)
            stixCount.center = CGPointMake(centerX - [BadgeView getOutlineOffsetX:0], centerY - [BadgeView getOutlineOffsetX:0]);
        if (transformCanvas) {
            [transformCanvas setCenter:stix.center];
        }
        //NSLog(@"Touches moved: new center %f %f", stix.center.x, stix.center.y);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    //NSLog(@"Touches ended: new center %f %f", stix.center.x, stix.center.y);

	if (isDragging == 1)
	{
        isDragging = 0;
        isTap = 0;
	}
    else if (isTap == 1 || isTouch == 1) {
        isTap = 0;
        isDragging = 0;
        isTouch = 0;
        
        if ([self.delegate respondsToSelector:@selector(didTouchInStixView:)])
            [self.delegate didTouchInStixView:self];
#if 0
        if (stix) {
            if (showTransformCanvas) {
                // hide transform canvas
                showTransformCanvas = NO;
                [transformCanvas setHidden:YES];
            }
            else
            {
                if (transformCanvas != nil) {
                    showTransformCanvas = YES;
                    [transformCanvas setHidden:NO];
                }
                else {
                    [self transformBoxShowAtFrame:stix.frame];
                }
            }
        }
#endif
    }
}

/*** Gesture handlers ***/

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // enables recognizing two gestures at the same time
    return YES;
}

- (CGAffineTransform)applyRecognizer:(UIGestureRecognizer *)recognizer toTransform:(CGAffineTransform)transform
{
    if ([recognizer respondsToSelector:@selector(rotation)])
        return CGAffineTransformRotate(transform, [(UIRotationGestureRecognizer *)recognizer rotation]);
    else if ([recognizer respondsToSelector:@selector(scale)]) {
        CGFloat newscale = [(UIPinchGestureRecognizer *)recognizer scale];
        //if ((auxScale * newscale) > 3)
        //    newscale = 1;
        //auxScale = auxScale * newscale;
        return CGAffineTransformScale(transform, newscale, newscale);
    }
    else
        return transform;
}


-(void)doubleTapGestureHandler:(UITapGestureRecognizer*) gesture {
    // do nothing
}

//-(void)pinchGestureHandler:(UIPinchGestureRecognizer*) gesture {
- (IBAction)handleGesture:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([recognizer respondsToSelector:@selector(scale)]) {
                // scaling transform
                //NSLog(@"AuxView: Pinch motion started! scale %f velocity %f", [(UIPinchGestureRecognizer*)recognizer scale], [(UIPinchGestureRecognizer*)recognizer velocity]);
            }
            if (_activeRecognizers.count == 0)
                referenceTransform = stix.transform;
            [_activeRecognizers addObject:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            referenceTransform = [self applyRecognizer:recognizer toTransform:referenceTransform];
            [_activeRecognizers removeObject:recognizer];
            
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGAffineTransform transform = referenceTransform;
            for (UIGestureRecognizer *recognizer in _activeRecognizers)
                transform = [self applyRecognizer:recognizer toTransform:transform];
            stix.transform = transform;
            
            if (transformCanvas)
            {
                transformCanvas.transform = transform;
            }
            break;
        }
            
        default:
            break;
    }
}

-(bool)isStixPeelable:(int)index {
    bool canBePeeled = [[auxPeelableByUser objectAtIndex:index] boolValue];
    return canBePeeled;
}

-(bool)isForeground:(CGPoint)point inStix:(UIImageView*)selectedStix {
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel, 
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    UIImage * im = selectedStix.image;
    [im drawAtPoint:CGPointMake(-point.x, -point.y)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0;
    BOOL transparent = alpha < 0.9; //0.01;
    NSLog(@"Foreground test: x y %f %f, alpha %f", point.x, point.y, alpha);
    return !transparent;
}

// sent through delegate functions for clicks on scrollView; after interaction with main stix is disabled, the touch filters out of StixView but then comes back through its delegates
-(int)findPeelableStixAtLocation:(CGPoint)location {
    if ([self isPeelable]) {

        NSLog(@"Tap detected in stix view at %f %f", location.x, location.y);
        int lastStixView = -1;
        for (int i=0; i<[self.auxStixViews count]; i++) {
            CGRect frame = [[auxStixViews objectAtIndex:i] frame];
            NSLog(@"Stix %d at %f %f %f %f", i, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            if (CGRectContainsPoint(frame, location) && [self isStixPeelable:i]) {
                // also check to see if point has color data or is part of the clear background
                CGPoint locationInFrame = location;
                locationInFrame.x -= frame.origin.x;
                locationInFrame.y -= frame.origin.y;
                // UIImage is always 120x120, so we have to scale the touch from within the current frame to a 120x120 frame
                float scale = 120 / frame.size.width;
                locationInFrame.x *= scale;
                locationInFrame.y *= scale;
                NSLog(@"Tapped in frame <%f %f %f %f> of stix %d of type %@ at %f %f scale %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height, i, [auxStixStringIDs objectAtIndex:i], location.x, location.y, scale);
                if ([self isForeground:locationInFrame inStix:[auxStixViews objectAtIndex:i]]) {
                    lastStixView = i;
                }
            }
        }
        if (lastStixView == -1)
            return -1;
        
        // display action sheet
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:lastStixView];
        NSString * stixDesc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        NSString * title = [NSString stringWithFormat:@"What do you want to do with your %@", stixDesc];
        stixPeelSelected = lastStixView;
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Peel", @"Stick", /*@"Move", */nil];
        [actionSheet showInView:self];
        [actionSheet release];
        return lastStixView;
    }
    return -1;
}

//-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
//}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // button index: 0 = "Peel", 1 = "Stick", 2 = "Move", 3 = "Cancel"
    NSLog(@"Button index: %d stixPeelSelected: %d", buttonIndex, stixPeelSelected);
    switch (buttonIndex) {
        case 0: // Peel
            // performing a peel action causes this StixView and its delegate FeedItemView to eventually be deleted/removed. Until that happens and the user interface is correctly populated, do not allow interaction anymore.
            self.isPeelable = NO;
            // remove from delegate's tag structure
            if ([self.delegate respondsToSelector:@selector(didPeelStix:)])
                [self.delegate didPeelStix:stixPeelSelected];
            break;
        case 1: // Stick
            self.isPeelable = NO;
            if ([self.delegate respondsToSelector:@selector(didAttachStix:)])
                [self.delegate didAttachStix:stixPeelSelected]; // will cause new StixView to be created
            break;
        case 2: // Cancel
            return;
            break;
        default:
            return;
            break;
    }
}


@end
