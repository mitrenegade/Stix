//
//  StixView.m
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StixView.h"
#import <QuartzCore/QuartzCore.h>
#define USE_STIXPANEL_VIEW 0

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
@synthesize isShowingPlaceholder;
@synthesize bMultiStixMode;

static NSMutableDictionary * requestDictionaryForStix;
//static NSMutableSet * retainedDelegates;

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
-(void)initializeWithImage:(UIImage *)imageData {
    [self initializeWithImage:imageData andStixLayer:nil];
}
-(void)initializeWithImage:(UIImage*)imageData andStixLayer:(UIImage*)stixLayer {
    originalImageSize = imageData.size;
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIImageView * imageView;
    if (stixLayer) {
        CGSize newSize = self.frame.size;
        UIGraphicsBeginImageContext(newSize);
        [imageData drawInRect:frame];	
        [stixLayer drawInRect:frame];
        UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        imageView = [[UIImageView alloc] initWithImage:result];
    }
    else {
        imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView setImage:imageData];
    }
    [self addSubview:imageView];
    _activeRecognizers = [[NSMutableSet alloc] init];
    isStillPeeling = NO;
}

-(void)requestStixFromKumulos:(NSString *)stixStringID forStix:(UIImageView *)auxStix inStixView:(StixView *)stixView{ // andDelegate:(NSObject<StixViewDelegate> *)_delegate {

    //NSLog(@"StixView %d requestStixFromKumulos requesting %@", stixViewID, stixStringID);
    
    // add stix to own list
    if ([stixViewsMissing objectForKey:stixStringID] == nil) {
        NSMutableArray * stixArray = [[NSMutableArray alloc] init];
        [stixViewsMissing setObject:stixArray forKey:stixStringID];
    }
    NSMutableArray * stixArray = [stixViewsMissing objectForKey:stixStringID];
    [stixArray addObject:auxStix];
    
    if (requestDictionaryForStix == nil) {
        requestDictionaryForStix = [[NSMutableDictionary alloc] init];
    }
    [k getStixDataByStixStringIDWithStixStringID:stixStringID];

    // stixView refers to the StixView class that displays all the stix
    if ([requestDictionaryForStix objectForKey:stixStringID] == nil)  {
        NSLog(@"Creating new queues for %@", stixStringID);
        NSMutableArray * viewsThatNeedThisStix = [[NSMutableArray alloc] init];

        [requestDictionaryForStix setObject:viewsThatNeedThisStix forKey:stixStringID];
    }
    NSMutableArray * viewsThatNeedThisStix = [requestDictionaryForStix objectForKey:stixStringID];
    [viewsThatNeedThisStix addObject:stixView];
    
    // hack: force delegate to stick around
    /*
    if (!retainedDelegates)
        retainedDelegates = [[NSMutableSet alloc] init];
    [retainedDelegates addObject:delegate];
     */
    if ([delegate respondsToSelector:@selector(needsRetainForDelegateCall)])
        [delegate needsRetainForDelegateCall];
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
    //NSData * dataPNG = [d valueForKey:@"dataPNG"];
    //UIImage * img = [[UIImage alloc] initWithData:dataPNG];
    
    NSMutableArray * viewsThatNeedThisStix = [requestDictionaryForStix objectForKey:stixStringID];
    //NSLog(@"StixView %d: GetStixDataByStixString for %@ = %@ returned", stixViewID, descriptor, stixStringID);
#if USE_STIXPANEL_VIEW
    UIImageView * stixExists = [[StixPanelView sharedStixPanelView]getStixWithStixStringID:stixStringID];
#else
    UIImageView * stixExists = [BadgeView getBadgeWithStixStringID:stixStringID];
#endif
    if (stixExists.alpha == 0) {
        [BadgeView AddStixView:theResults];
        
        for (int i=0; i<[viewsThatNeedThisStix count]; i++) {
            StixView * stixView = [viewsThatNeedThisStix objectAtIndex:i];
            NSLog(@"StixView %d is telling stixView %d to reload requested stix %@ = %@", stixViewID, stixView.stixViewID, descriptor, stixStringID);
            [stixView didReceiveRequestedStix:stixStringID withResults:theResults fromStixView:stixViewID];
        }
        // clear list
        //NSLog(@"StixView: GetStixDataByStixString for %@ = %@ filled %d missing views and cancelled %d identical kOps", descriptor, stixStringID, [viewsThatNeedThisStix count], [kOpsThatNeedThisStix count]-1);
    }
    else {
        //NSLog(@"StixView %d: GetStixDataByStixString for %@ = %@ previously finished!", stixViewID, descriptor, stixStringID);
        
        // hack: only remove from own
        NSMutableArray * stixArray = [stixViewsMissing objectForKey:stixStringID];
        if (stixArray) {
            [stixViewsMissing removeObjectForKey:stixStringID];
            //NSLog(@"Previously finished stixView still exists in stixViewsMissing");
        } else {
            //NSLog(@"Previously finished stixView already removed by sender");
        }
        
        if ([stixViewsMissing count] == 0) {
            //NSLog(@"Previously finished StixView %d finished loading all missing stix views!", stixViewID);
            [delegate didReceiveAllRequestedMissingStix:self];
            
            // hack: tell delegate to remove retained detailView
            if ([delegate respondsToSelector:@selector(doneWithAsynchronousDelegateCall)])
                [delegate doneWithAsynchronousDelegateCall];
        }
    }
}

-(void)didReceiveRequestedStix:(NSString *)stixStringID withResults:(NSArray*)theResults fromStixView:(int)senderID{
    //NSLog(@"StixView %d received stix %@ sent by stixView %d", stixViewID, stixStringID, senderID);
    
    // remove auxStix from stixViewsMissing list
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
    NSMutableArray * stixArray = [stixViewsMissing objectForKey:stixStringID];
    if (stixArray) {
        [stixViewsMissing removeObjectForKey:stixStringID];
        //NSLog(@"Filling in %d previously missing stix. Stix types still outstanding: %d", [stixArray count], [stixViewsMissing count]);
    }

    if ([stixViewsMissing count] == 0) {
        //NSLog(@"StixView %d finished loading all missing stix views!", stixViewID);
        if ([delegate respondsToSelector:@selector(didReceiveAllRequestedMissingStix:)])
            [delegate didReceiveAllRequestedMissingStix:self];
//        [retainedDelegates removeObject:delegate];
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
#if USE_STIXPANEL_VIEW
    stix = [[StixPanelView sharedStixPanelView] getStixWithStixStringID:stixStringID];
#else
    stix = [BadgeView getBadgeWithStixStringID:stixStringID];
#endif
    if (stix.alpha == 0) { // alpha is set to 0 by [BadgeView getBadgeForStixStringId]
        NSLog(@"Should not get here!");
        //[self requestStixFromKumulos:stixStringID forStixView:stix inSuperView:self andDelegate:delegate];
    }
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = x;
    float centerY = y;
    //NSLog(@"StixView creating %@ stix to %d %d in image of size %f %f", stixStringID, x, y, self.frame.size.width, self.frame.size.height);
    
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
    //[stix release];
        
    // add pinch gesture recognizer
    // add gesture recognizer
    UIPinchGestureRecognizer * myPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchGestureHandler:)];
    [myPinchRecognizer setDelegate:self];
    
    
    UIRotationGestureRecognizer *myRotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchRotateHandler:)];
    [myRotateRecognizer setDelegate:self];
        
    if (interactionAllowed) {
        [self addGestureRecognizer:myPinchRecognizer];
        [self addGestureRecognizer:myRotateRecognizer];    

#if 0
        UITapGestureRecognizer * myDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
        [myDoubleTapRecognizer setNumberOfTapsRequired:2];
        [myDoubleTapRecognizer setNumberOfTouchesRequired:1];
        [myDoubleTapRecognizer setDelegate:self];
        
        //if (isPeelable)
        [self addGestureRecognizer:myDoubleTapRecognizer];
#endif
    }

    // display transform box 
    showTransformCanvas = YES;
    [self transformBoxShowAtFrame:stix.frame];
}

-(void)updateStixForManipulation:(NSString*)stixStringID {
    CGPoint center = stix.center;
    CGAffineTransform transform = stix.transform;
    [stix removeFromSuperview];
#if USE_STIXPANEL_VIEW
    stix = [[StixPanelView sharedStixPanelView] getStixWithStixStringID:stixStringID];
#else
    stix = [BadgeView getBadgeWithStixStringID:stixStringID];
#endif
    if (transform.a==0 && transform.b==0 && transform.c == 0 && transform.d == 0 && transform.tx == 0 && transform.ty == 0) {
        NSLog(@"Invalid transform! Why is the stix blank?");
        transform = CGAffineTransformIdentity;
        center = self.center;
    }
    [stix setCenter:center];
    [stix setTransform:transform];
    [self addSubview:stix];
    [self setSelectStixStringID:stixStringID];
    //[stix release]; // MRC -> causing zombie
}

-(int)populateWithAuxStixFromTag:(Tag *)tag {
    // clear all existing stix in the stixview
    for (int i=0; i<[auxStixViews count]; i++) {
        UIView * subview = [auxStixViews objectAtIndex:i];
        [subview removeFromSuperview];
    }
    [auxStixViews removeAllObjects];
    
    tagUsername = [[tag username] copy];
    tagID = tag.tagID;
    int allStixViewsExist = 1; // returns 1 if populated, 0 if missing stix
    auxStixStringIDs = tag.auxStixStringIDs;
    NSMutableArray * auxLocations = tag.auxLocations;
    NSMutableArray * auxTransforms = tag.auxTransforms;
    auxPeelableByUser = [[NSMutableArray alloc] init]; // = tag.auxPeelable;
    auxStixViews = [[NSMutableArray alloc] init];
    //NSLog(@"Adding %d auxstix to tagID %d", [auxStixStringIDs count], [tag.tagID intValue]);
    
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        CGAffineTransform auxTransform;
        NSString * transformString = [auxTransforms objectAtIndex:i];
        auxTransform = CGAffineTransformFromString(transformString); // if fails, returns identity
#if USE_STIXPANEL_VIEW
        UIImageView * auxStix = [[StixPanelView sharedStixPanelView] getStixWithStixStringID:stixStringID];
#else
        UIImageView * auxStix = [BadgeView getBadgeWithStixStringID:stixStringID];
#endif
        // hack: call update
        if (auxStix.alpha == 0) {
            [self requestStixFromKumulos:stixStringID forStix:auxStix inStixView:self];
            allStixViewsExist = 0;
        }
        
        // shortcircuit populateWithAuxStixFromTag because if any stix doesn't exist
        // this whole StixView will have to be repopulated once we receive all stix
        // requests. but we do have to run through all stix to initiate the requests
        if (!allStixViewsExist) {
            continue;
        }
        
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
        //[auxStix setBackgroundColor:[UIColor blackColor]];
        
        bool isPeelableByUser = NO; // now setting this to YES means it has been tapped to display the peel menu if it was already stuck
        if (isPeelable) {
            BOOL stixIsPeelable = [[tag.auxPeelable objectAtIndex:i] boolValue];
            NSString * tagname = tag.username;
            NSString * delegateUsername = [delegate getUsernameOfApp];
            if (stixIsPeelable == YES && [tagname isEqualToString:delegateUsername]) {

                isPeelableByUser = YES;
                // turn this stix into an animated one
#if 0
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
#else
//                [self addPeelableAnimationToStix:auxStix];
#endif
            } 
            else {
                isPeelableByUser = NO;
            }
        }
        [self addSubview:auxStix];
        //NSLog(@"StixView: adding %@ auxStix %@ at center %f %f\n", isPeelableByUser?@"peelable":@"attached", stixStringID, centerX, centerY);
        
        [auxStixViews addObject:auxStix];
        //[auxScales addObject:[NSNumber numberWithFloat:auxScale]];
        [auxPeelableByUser addObject:[NSNumber numberWithBool:isPeelableByUser]];
    }
    return allStixViewsExist;
}

-(void)doPeelAnimationForStix {
    
    int stixID = -1;
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        UIImageView * peelStix = [auxStixViews objectAtIndex:i];
        CGPoint center = peelStix.center;
        if ([[auxStixStringIDs objectAtIndex:i] isEqualToString:stixPeelSelected] &&
            center.x == stixPeelSelectedCenter.x && center.y == stixPeelSelectedCenter.y) {
            stixID = i;
            break;
        }
    }
    if (stixID == -1)
        return;
    
    UIImageView * auxStix = [auxStixViews objectAtIndex:stixID];
    NSString * stixStringID = [auxStixStringIDs objectAtIndex:stixID];
    CGPoint center = [auxStix center];
    NSLog(@"Do peel animation: Stix %@ index %d frame %f %f", stixStringID, stixID, center.x, center.y);
    [auxStix setBackgroundColor:[UIColor clearColor]];
    [auxStix.layer removeAllAnimations];
    CGRect frameLift = auxStix.frame;
    frameLift.origin.x = center.x - frameLift.size.width / 2;
    frameLift.origin.y = center.y - frameLift.size.height / 2;
    
    CGAffineTransform transformLift = CGAffineTransformConcat(auxStix.transform, CGAffineTransformMakeScale(2.0, 2.0));
    [UIView transitionWithView:auxStix 
                      duration:.5
                       options:UIViewAnimationTransitionNone 
                    animations: ^ { 
#if 0
                        auxStix.frame = frameLift;
#else
                        [auxStix setTransform:transformLift];
#endif
                        
                        
                    } 
                    completion: ^ (BOOL finished) { 
                        CGRect frameDisappear = CGRectMake(160, 300, 5, 5);
                        [UIView transitionWithView:auxStix 
                                          duration:.25
                                           options:UIViewAnimationTransitionNone 
                                        animations: ^ { auxStix.frame = frameDisappear; } 
                                        completion:^(BOOL finished) { 
                                            [auxStix removeFromSuperview]; 
                                            isStillPeeling = NO;
                                            if ([delegate respondsToSelector:@selector(peelAnimationDidCompleteForStix:)])
                                                [delegate peelAnimationDidCompleteForStix:stixID]; 
                                        }
                         ];
                    }
     ];
}

-(void)transformBoxShowAtFrame:(CGRect)frame {
    [self transformBoxShowAtFrame:frame withTransform:CGAffineTransformIdentity];
}

-(void)transformBoxShowAtFrame:(CGRect)frame withTransform:(CGAffineTransform)t {
    if (transformCanvas) {
        [transformCanvas removeFromSuperview];
        transformCanvas = nil;
    }
    int canvasOffset = 5;
    if (!CGAffineTransformIsIdentity(t)) {
        CGPoint center; 
        center.x = frame.origin.x + frame.size.width / 2;
        center.y = frame.origin.y + frame.size.height / 2;
#if USE_STIXPANEL_VIEW
        UIImageView * basicStix = [[StixPanelView sharedStixPanelView] getStixWithStixStringID:selectStixStringID];
#else
        UIImageView * basicStix = [BadgeView getBadgeWithStixStringID:selectStixStringID];
#endif
        [basicStix setCenter:center];
        frame = basicStix.frame;
    }    
    CGRect frameCanvas = frame;
    NSLog(@"frameCanvas: %f %f", frameCanvas.size.width, frameCanvas.size.height);
    frameCanvas.origin.x -= canvasOffset;
    frameCanvas.origin.y -= canvasOffset;
    frameCanvas.size.width += 2*canvasOffset;
    frameCanvas.size.height += 2*canvasOffset;
    transformCanvas = [[UIView alloc] initWithFrame:frameCanvas];
    [transformCanvas setAutoresizesSubviews:YES];
    frame.origin.x = canvasOffset;
    frame.origin.y = canvasOffset;
    CGRect frameInside = frame;
    NSLog(@"frameInside: %f %f", frameInside.size.width, frameInside.size.height);
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
    /*
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
     */

    if (!CGAffineTransformIsIdentity(t))
        [transformCanvas setTransform:t];
    [self addSubview:transformCanvas];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch!");
    if (interactionAllowed == NO) { // skips interaction with stix for dragging
        NSLog(@"interaction not allowed!");
        [super touchesBegan:touches withEvent:event];
        return;
    }
    NSLog(@"Touch allowed!");
    
    isTouch = 1;
    if (isDragging) // will come here if a second finger touches
        return;
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];
    
    /* TODO: enabling this seems to prevent touchesmoved
    if (bMultiStixMode) {
        // change current stix
        for (int i=0; i<[auxStixViews count]; i++) {
            UIImageView * currStix = [auxStixViews objectAtIndex:i];
            CGRect frame = currStix.frame;
            if (CGRectContainsPoint(frame, location)) {
                [self multiStixSelectCurrent:i];
                isTap = 1;
                // point where finger clicked badge
                offset_x = (location.x - stix.center.x);
                offset_y = (location.y - stix.center.y);
                
                break;
            }
        }
    }
     */
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
        // point where finger clicked badge
        offset_x = (location.x - stix.center.x);
        offset_y = (location.y - stix.center.y);
        
    }
    
    NSLog(@"Touches began: center %f %f touch location %f %f", stix.center.x, stix.center.y, location.x, location.y);
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
            stixCount.center = CGPointMake(centerX + 3, centerY - 9); //[BadgeView getOutlineOffsetX:0], centerY - [BadgeView getOutlineOffsetX:0]);
        if (transformCanvas) {
            [transformCanvas setCenter:stix.center];
        }
	}
    NSLog(@"Touches moved: new center %f %f", stix.center.x, stix.center.y);
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
        
        if (bMultiStixMode) {
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint location = [touch locationInView:self];

            // change current stix
            for (int i=0; i<[auxStixViews count]; i++) {
                UIImageView * currStix = [auxStixViews objectAtIndex:i];
                CGRect frame = currStix.frame;
                if (CGRectContainsPoint(frame, location)) {
                    [self multiStixSelectCurrent:i];
                    break;
                }
            }
        }
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
    NSLog(@"Double tap!");
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
    BOOL isForeground = NO;
    int dx=0;
    int dy=0;
    //for (int dx = -3; dx < 3; dx++) {
    //    for (int dy = -3; dy < 3; dy++) {
    
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel, 
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    UIImage * im = selectedStix.image;
    // convert - the point coordinates goes from 0-78 - convert point to view uses original stix UIImageView frame
    // the image size varies - size of im could be 120x120, 240x240, etc
    CGSize size = im.size;
    float scale = size.width / (120 * .65);
    point.x *= scale; // convert to the UIImage size
    point.y *= scale; 
    [im drawAtPoint:CGPointMake(-point.x + dx, -point.y + dy)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0;
    BOOL thisTransparent = alpha < 0.1;
    if (!thisTransparent) {
        isForeground = YES;
    }
    NSLog(@"Foreground test: x y %f %f, pixel %d alpha %f foreGround %d", point.x + dx, point.y + dy, pixel[0], alpha, isForeground);
    //    }
    // }
    return isForeground;
}

-(void)addPeelableAnimationToStix:(UIImageView*)canvas {
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doPulse:canvas forTime:1 repeatCount:-1 withCompletion:^(BOOL finished) {
 //       [self addPeelableAnimation:canvas];
    }];
}
// sent through delegate functions for clicks on scrollView; after interaction with main stix is disabled, the touch filters out of StixView but then comes back through its delegates
-(int)findPeelableStixAtLocation:(CGPoint)location {
    if (isStillPeeling) {
        NSLog(@"Still peeling stix!");
        return -1;
    }
    if ([self isPeelable]) {
        
        NSString * appUsername = [delegate getUsernameOfApp];
        if (![tagUsername isEqualToString:appUsername])
            return -1;
        
        int topStixIndex = -1;
        BOOL topStixIsPeelable = NO;
        NSLog(@"Tap detected in stix view at %f %f", location.x, location.y);
        int lastStixView = -1;
        for (int i=0; i<[self.auxStixViews count]; i++) {
            UIImageView * currStix = [auxStixViews objectAtIndex:i];
            CGRect frame = [currStix frame];
            NSLog(@"Stix %d at %f %f %f %f", i, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            CGPoint pointInside = [self convertPoint:location toView:currStix];
            NSLog(@"Changing point %f %f to %f %f", location.x, location.y, pointInside.x, pointInside.y);
            
            // if click is on top of a stix
            if ([currStix pointInside:pointInside withEvent:nil] && [self isForeground:pointInside inStix:currStix]) {
                if (1) { //[self isStixPeelable:i]) {
                    topStixIndex = i;
                    topStixIsPeelable = YES;
                }
            }
        }
        //if (lastStixView == -1)
        //    return -1;
        if (topStixIsPeelable == NO) 
            return -1;
        else {
            lastStixView = topStixIndex;
            
            // display action sheet
            NSString * stixStringID = [auxStixStringIDs objectAtIndex:lastStixView];
#if USE_STIXPANEL_VIEW
            NSString * stixDesc = [[StixPanelView sharedStixPanelView] getStixDescriptorForStixStringID:stixStringID];
#else
            NSString * stixDesc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
#endif
            NSString * title = [NSString stringWithFormat:@"What do you want to do with your %@", stixDesc];
            //stixPeelSelected = lastStixView;
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Peel", /*@"Stick", @"Move", */nil];
            [actionSheet showInView:self];

            UIImageView * currStix = [auxStixViews objectAtIndex:lastStixView];
            CGPoint center = currStix.center;
            NSLog(@"Presenting peelable actionsheet for %@ lastStixView %d at center %f %f", stixStringID, lastStixView, center.x, center.y);
            
            // save stixStringID and center to find the correct stix to remove later, in case the stix gets reloaded and stixStrings get out of order
            stixPeelSelected = [stixStringID copy];
            stixPeelSelectedCenter = center;
            
            return lastStixView;
        }
    }
    return -1;
}

//-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
//}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // button index: 0 = "Peel", 1 = "Stick", 2 = "Move", 3 = "Cancel"
    //NSLog(@"Button index: %d stixPeelSelected: %d", buttonIndex, stixPeelSelected);
    switch (buttonIndex) {
        case 0: // Peel
            // performing a peel action causes this StixView and its delegate FeedItemView to eventually be deleted/removed. Until that happens and the user interface is correctly populated, do not allow interaction anymore.
            //self.isPeelable = NO;
            
            isStillPeeling = YES;
            // remove from delegate's tag structure
            //if ([self.delegate respondsToSelector:@selector(didPeelStix:)])
                //[self.delegate didPeelStix:stixPeelSelected];
            [self doPeelAnimationForStix];    
            break;
        case 1: // Stick
            /*
            //self.isPeelable = NO;
            if ([self.delegate respondsToSelector:@selector(didAttachStix:)])
                [self.delegate didAttachStix:stixPeelSelected]; // will cause new StixView to be created
             */
            break;
        case 2: // Cancel
            return;
            break;
        default:
            return;
            break;
    }
}

#pragma mark Multi stix mode

-(int)multiStixInitializeWithTag:(Tag *)tag useStixLayer:(BOOL)useStixLayer {
    // clear all existing stix in the stixview
    for (int i=0; i<[auxStixViews count]; i++) {
        UIView * subview = [auxStixViews objectAtIndex:i];
        [subview removeFromSuperview];
    }
    if (transformCanvas) {
        [transformCanvas removeFromSuperview];
        transformCanvas = nil;
    }
    [auxStixViews removeAllObjects];
    [auxStixStringIDs removeAllObjects];
    
    tagUsername = [[tag username] copy];
    tagID = tag.tagID;

    auxStixViews = [[NSMutableArray alloc] init];
    auxStixStringIDs = [[NSMutableArray alloc] init];
    
#if 0
    [auxStixStringIDs addObjectsFromArray:tag.auxStixStringIDs];
    NSMutableArray * auxLocations = tag.auxLocations;
    NSMutableArray * auxTransforms = tag.auxTransforms;
    
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        CGAffineTransform auxTransform;
        NSString * transformString = [auxTransforms objectAtIndex:i];
        auxTransform = CGAffineTransformFromString(transformString); // if fails, returns identity
#if USE_STIXPANEL_VIEW
        UIImageView * auxStix = [[StixPanelView sharedStixPanel] getStixWithStixStringID:stixStringID];
#else
        UIImageView * auxStix = [BadgeView getBadgeWithStixStringID:stixStringID];
#endif
        // hack: call update

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

        [auxStix setFrame:stixFrameScaled];
        [auxStix setCenter:CGPointMake(centerX, centerY)];
        auxStix.transform = auxTransform;
        //[auxStix setBackgroundColor:[UIColor blackColor]];
        
        [self addSubview:auxStix];
        
        [auxStixViews addObject:auxStix];
    }
#else
    if (useStixLayer) {
        // add stix layer
        CGSize newSize = self.frame.size;
        UIGraphicsBeginImageContext(newSize);
        CGRect fullFrame = CGRectMake(0, 0, newSize.width, newSize.height);
        [tag.image drawInRect:fullFrame];	
        [tag.stixLayer drawInRect:fullFrame];
        UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        
        UIImageView * srcImageView = [[UIImageView alloc] initWithImage:result];
        [self addSubview:srcImageView];
    }
#endif
    
    // add pinch and rotate gesture recognizer
    UIPinchGestureRecognizer * myPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchGestureHandler:)];
    [myPinchRecognizer setDelegate:self];
    
    UIRotationGestureRecognizer *myRotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchRotateHandler:)];
    [myRotateRecognizer setDelegate:self];
    
    [self addGestureRecognizer:myPinchRecognizer];
    [self addGestureRecognizer:myRotateRecognizer];   
    
    bMultiStixMode = YES;
    multiStixCurrent = -1;
    interactionAllowed = YES;
    
    NSLog(@"MultiStix initialize with tag with %d auxStix", [auxStixViews count]);
    
    return YES;
}

// this function creates a temporary stix object that can be manipulated
-(void)multiStixAddStix:(NSString*)stixStringID atLocationX:(int)x andLocationY:(int)y /*andScale:(float)scale andRotation:(float)rotation */{
    NSLog(@"Adding stix %@ to %d %d", stixStringID, x, y);
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    referenceTransform = CGAffineTransformIdentity;
    
    [self setSelectStixStringID:stixStringID];
#if USE_STIXPANEL_VIEW
    stix = [[StixPanelView sharedStixPanelView] getStixWithStixStringID:stixStringID];
#else
    stix = [BadgeView getBadgeWithStixStringID:stixStringID];
#endif
    float centerX = x;
    float centerY = y;
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = originalImageSize;
	CGSize targetSize = self.frame.size;
	
    imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.size.width *= imageScale;// * stixScale;
	stixFrameScaled.size.height *= imageScale;// * stixScale;
    centerX *= imageScale;
    centerY *= imageScale;

    [stix setFrame:stixFrameScaled];
    [stix setCenter:CGPointMake(centerX, centerY)];
#if 0
    [self addSubview:stix];
    //[stix release];
    // display transform box 
    showTransformCanvas = YES;
    [self transformBoxShowAtFrame:stix.frame];
    
    //multiStixCurrent = [auxStixViews count];
    [self multiStixSelectCurrent:[auxStixViews count]];
#else
    [stix setAlpha:0];
    [self addSubview:stix];
    StixAnimation * animation = [[StixAnimation alloc] init];
    //[animation doFade:stix inView:self toAlpha:1 forTime:.25];
    [animation doFadeIn:stix forTime:1 withCompletion:^(BOOL finished) {
        showTransformCanvas = YES;
        [self transformBoxShowAtFrame:stix.frame];
        
        //multiStixCurrent = [auxStixViews count];
        [self multiStixSelectCurrent:[auxStixViews count]];
    }];
#endif
}

-(void)multiStixSelectCurrent:(int)stixIndex {
    NSLog(@"MultiStixSelectCurrent: currently editing %d, changing to index %d, total existing %d auxStix", multiStixCurrent, stixIndex, [auxStixViews count]);
    if (stixIndex == -1)
        return;
    
    // if a stix is already being manipulated, make sure to sync it with auxStix
    if (multiStixCurrent == -1) {
        // currently selected stix was a new stix; needs to be added to auxStix
        if (selectStixStringID) {      
            // only if a stix was actually added
            [auxStixViews addObject:stix];
            [auxStixStringIDs addObject:selectStixStringID];
        }
    }
    else {
        if (stix) {
            // currently selected stix is an existing stix; sync
            if (stixIndex < [auxStixViews count]) {
                // replace
                [auxStixViews replaceObjectAtIndex:multiStixCurrent withObject:stix];            
            }
            else if (stixIndex == [auxStixViews count]) {
                // add
                [auxStixViews addObject:stix];
                [auxStixStringIDs addObject:selectStixStringID];
            }
        }
    }
    
    stix = [auxStixViews objectAtIndex:stixIndex];
    selectStixStringID = [auxStixStringIDs objectAtIndex:stixIndex];
    multiStixCurrent = stixIndex;
    //referenceTransform = stix.transform;
    
    NSLog(@"Switching to stix at index %d with frame %f %f %f %f and transform %@", stixIndex, stix.frame.origin.x, stix.frame.origin.y, stix.frame.size.width, stix.frame.size.height, NSStringFromCGAffineTransform( stix.transform ) );
    
    [self transformBoxShowAtFrame:stix.frame withTransform:stix.transform];
}

-(int) multiStixDeleteCurrentStix {
    if (transformCanvas) {
        [transformCanvas removeFromSuperview];
        transformCanvas = nil;
    }
    if (multiStixCurrent != -1) {
        stix = nil;
        selectStixStringID = nil;
        if (multiStixCurrent < [auxStixViews count]) {
            [[auxStixViews objectAtIndex:multiStixCurrent] removeFromSuperview];
            [auxStixViews removeObjectAtIndex:multiStixCurrent];
            [auxStixStringIDs removeObjectAtIndex:multiStixCurrent];
        }
        //multiStixCurrent = -1;
        [self multiStixSelectCurrent:[auxStixViews count]-1];
    } else {
        if (stix) {
            [stix removeFromSuperview];
            stix = nil;
            selectStixStringID = nil;
        }
    }
    return [auxStixStringIDs count];
}

-(void) multiStixClearAllStix {
    if ([auxStixViews count] > 0) {
        for (int i=0; i<[auxStixViews count]; i++) {
            stix = [auxStixViews objectAtIndex:i];
            [stix removeFromSuperview];
        }
        [auxStixViews removeAllObjects];
        [auxStixStringIDs removeAllObjects];
    }
    if (stix) {
        [stix removeFromSuperview];
        stix = nil;
        selectStixStringID = nil;
    }
    if (transformCanvas) {
        [transformCanvas removeFromSuperview];
        transformCanvas = nil;
    }
}
@end
