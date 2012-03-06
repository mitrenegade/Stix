//
//  AuxStixViewController.m
//  Stixx
//
//  Created by Bobby Ren on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AuxStixViewController.h"

@implementation AuxStixViewController

@synthesize imageView;
@synthesize commentField;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;
@synthesize badgeFrame;
@synthesize stixStringID;
@synthesize stix;
@synthesize buttonInstructions;
@synthesize stixView;

-(id)init
{
	// call superclass's initializer
	self = [super initWithNibName:@"AuxStixViewController" bundle:nil];
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // add gesture recognizer
    UIPinchGestureRecognizer * myPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchGestureHandler:)];
    [myPinchRecognizer setDelegate:self];
    
    
    UIRotationGestureRecognizer *myRotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]; //(pinchRotateHandler:)];
    [myRotateRecognizer setDelegate:self];
    
    [self.view addGestureRecognizer:myPinchRecognizer];
    [self.view addGestureRecognizer:myRotateRecognizer];
    //transformBox = nil;
    //transformBoxShadow = nil;

    _activeRecognizers = [[NSMutableSet alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initStixView:(Tag*)tag {
    UIImage * imageData = tag.image;
    
    // for the tag's primary stix
    //NSLog(@"AuxStix: Creating stix view of size %f %f", imageData.size.width, imageData.size.height);

    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView
    [stixView initializeWithImage:imageData];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view addSubview:stixView];

}

-(void)addNewAuxStix:(UIImageView *)newStix ofType:(NSString *)newStixStringID atLocation:(CGPoint)location {
    badgeFrame = newStix.frame;
    // save frame of badge relative to cropped image
    // stix frame coming in relative to a full size 300x275 view at origin 0,0
	float imageScale = 1;// stixView.frame.size.width / 300;
    NSLog(@"AuxStix: badge of frame %f %f %f %f at location %f %f in view %f %f changed to frame %f %f %f %f at location %f %f in view %f %f\n", badgeFrame.origin.x, badgeFrame.origin.y, badgeFrame.size.width, badgeFrame.size.height, location.x, location.y, 300.0, 300.0, badgeFrame.origin.x * imageScale, badgeFrame.origin.y * imageScale, badgeFrame.size.width * imageScale, badgeFrame.size.height * imageScale, location.x * imageScale, location.y * imageScale, stixView.frame.size.width, stixView.frame.size.height);
    location.x *= imageScale; // scale to fit in stixView
    location.y *= imageScale;
    // location of stix should be in auxStix's frame, not stixView's frame
    //location.x += stixView.frame.origin.x; // move center into stixView in this view's reference
    //location.y += stixView.frame.origin.y;
    badgeFrame.size.width *= imageScale;
    badgeFrame.size.height *= imageScale;
    //auxScale = 1;
    //auxRotation = 0;
    
    // location is already the point inside stixFrame
    stixStringID = newStixStringID;
    stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
    [stix setFrame:badgeFrame];
    [stix setCenter:location];
    [self.view addSubview:stix];

    // display transform box 
    showTransformCanvas = YES;
    transformCanvas = nil;
    [self transformBoxShowAtFrame:stix.frame];
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

    [self.view addSubview:transformCanvas];
    
    [transformBox release];
    [transformBoxShadow release];
    [dot1 release];
    [dot2 release];
    [dot3 release];
    [dot4 release];
}
/*** dragging and resizing badge ***/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self.view];
	drag = 0;
    tap = 0;
    
    [self closeInstructions:nil];
    
    if (CGRectContainsPoint(stix.frame, location))
    {
        tap = 1;
    }
    
    // point where finger clicked badge
    offset_x = (location.x - stix.center.x);
    offset_y = (location.y - stix.center.y);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (tap == 1 || drag == 1)
	{
        drag = 1;
        tap = 0;
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self.view];
		// update frame of dragged badge, also scale
		//float scale = 1; // do not change scale while dragging
		if (!drag)
			return;
       
        float centerX = location.x - offset_x;
		float centerY = location.y - offset_y;
        
        // filter out rogue touches, usually when people are using a pinch
        if (abs(centerX - stix.center.x) > 50 || abs(centerY - stix.center.y) > 50) 
            return;
        
		stix.center = CGPointMake(centerX, centerY);
        
        if (transformCanvas) {
            [transformCanvas setCenter:stix.center];
        }
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
        tap = 0;
        drag = 0;
	}
    else if (tap == 1)
    {
        drag = 0;
        tap = 0;
#if 0
        // auxStix being added is handled here, not in StixView.touchesEnded
        // single tap - should display scale/rotate box
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
#else
        // single tap is equivalent to done
        [self buttonOKPressed:self];
#endif
    }
}

-(IBAction)buttonOKPressed:(id)sender
{
    // scale stix frame back
	float imageScale = 1; // 300 / imageView.frame.size.width;
    
	CGRect stixFrameScaled = stix.frame;
    float centerX = stix.center.x - stixView.frame.origin.x;
    float centerY = stix.center.y - stixView.frame.origin.y;
    centerX *= imageScale;
    centerY *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    NSLog(@"AuxStix: set aux stix of size %f %f at %f %f in image size %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width * imageScale, imageView.frame.size.height * imageScale);
    
    // hack: debug to test display
    //auxRotation = 0; //3.1415/4;
    
    [delegate didAddAuxStixWithStixStringID:stixStringID withLocation:CGPointMake(centerX, centerY) /*withScale:auxScale withRotation:auxRotation */withTransform:stix.transform withComment:[commentField text]];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	//[self.delegate didAddDescriptor:nil];
    //[self dismissModalViewControllerAnimated:YES];
    [self.delegate didCancelAuxStix];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}

/*** Gesture recognizers ***/

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

CGAffineTransform referenceTransform;
//-(void)pinchGestureHandler:(UIPinchGestureRecognizer*) gesture {
- (IBAction)handleGesture:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([recognizer respondsToSelector:@selector(scale)]) {
                // scaling transform
                //NSLog(@"AuxView: Pinch motion started! scale %f velocity %f", [(UIPinchGestureRecognizer*)recognizer scale], [(UIPinchGestureRecognizer*)recognizer velocity]);
                //frameBeforeScale = stix.frame;                
            }
            if (_activeRecognizers.count == 0)
                referenceTransform = stix.transform;
            [_activeRecognizers addObject:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            if ([recognizer respondsToSelector:@selector(scale)]) {
                // scaling transform
                //NSLog(@"Frame scale changed by %f: overall scale %f", [(UIPinchGestureRecognizer*)recognizer scale], auxScale);
            }
            referenceTransform = [self applyRecognizer:recognizer toTransform:referenceTransform];
            [_activeRecognizers removeObject:recognizer];

            break;
            
        case UIGestureRecognizerStateChanged: {
            CGAffineTransform transform = referenceTransform;
            for (UIGestureRecognizer *recognizer in _activeRecognizers)
                transform = [self applyRecognizer:recognizer toTransform:transform];
            stix.transform = transform;
            
            /*
            CGPoint center = stix.center;
            //NSLog(@"Old center: %f %f", center.x, center.y);
            CGRect stixFrameScaled = frameBeforeScale;
            stixFrameScaled.size.width *= newscale;
            stixFrameScaled.size.height *= newscale;
            stix.frame = stixFrameScaled;
            stix.center = center;
             */
            //NSLog(@"New center: %f %f", center.x, center.y);
            if (transformCanvas)
            {
                transformCanvas.transform = transform;
                //[self transformBoxSetFrame:stix.frame];
            }
            break;
        }
            
        default:
            break;
    }
}

@end
