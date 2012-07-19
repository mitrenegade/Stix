//
//  StixEditorViewController.m
//  Stixx
//
//  Created by Bobby Ren on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StixEditorViewController.h"

@implementation StixEditorViewController

@synthesize imageView;
@synthesize buttonSave, buttonClear, buttonClose, buttonDelete, buttonAddstix;
@synthesize stixPanel;
@synthesize delegate;
@synthesize stixView;
@synthesize remixTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#if 1
    [self configureStixPanel];
    stixView = [[StixView alloc] initWithFrame:imageView.frame];
#endif
}

-(void)configureStixPanel {
    if ([StixPanelView sharedStixPanelView])
        [[StixPanelView sharedStixPanelView] removeFromSuperview];
    
    [self setStixPanel:[StixPanelView sharedStixPanelView]];
    [stixPanel setDelegate:self];
    [stixPanel setDismissedTabY:460-STATUS_BAR_SHIFT];
    [stixPanel setExpandedTabY:50-STATUS_BAR_SHIFT+SHELF_LOWER_FROM_TOP];
    [stixPanel carouselTabDismiss:NO];
    [self.view addSubview:stixPanel];
}

-(void)viewWillAppear:(BOOL)animated {
    // because there are two instances of the stixEditor and only one shared stixPanel
    [super viewWillAppear:animated];
    [self configureStixPanel];
}

/*
 // trying to find the delay...cannot find
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"***** VIEW WILL APPEAR *****");
    NSLog(@"***** VIEW WILL APPEAR added stixpanel *****");
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"***** view did appear ****");
}
 */

-(void)initializeWithTag:(Tag*)tag remixMode:(int)_remixMode {
    // remix mode:
    // REMIX_MODE_NEWPIC, // adding stix to the original pix
    // REMIX_MODE_USEORIGINAL, // adding stix using a blank slate - remixing from blank
    // REMIX_MODE_ADDSTIX // adding stix on top of existing stix - the real remix
    
    [self disableButtonDelete];
    [self disableButtonClear];

    remixMode = _remixMode;
    // tag is newTag
//    if (remixMode == REMIX_MODE_NEWPIC)
        [self setRemixTag:tag];
    NSLog(@"Remixing tag by %@ originally %@", tag.username, tag.originalUsername);
//    else {
//        [self setRemixTag:tag.copy];  // create copy so original is not changed
//        NSLog(@"Remixing tag from original tag: %@", tag.tagID);
//    }
    NSLog(@"Initializing editor for tagID %@, pendingID %d with remix mode: %d", tag.tagID, tag.pendingID, remixMode);
    isLoadingPixSource = YES;
    [imageView setImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
    [stixView setAlpha:0];
    [buttonClose setAlpha:0];
    [stixPanel carouselTabDismiss:NO];
    [stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView

    if (remixMode == REMIX_MODE_NEWPIC) {
        //[imageView setImage:tag.image];
        
        [stixView initializeWithImage:tag.image];
        [stixView multiStixInitializeWithTag:tag useStixLayer:NO];
        [self.view insertSubview:stixView aboveSubview:imageView];
        [stixView setAlpha:1];
        [buttonClose setAlpha:1];
        isLoadingPixSource = NO;
    }
    else if (remixMode == REMIX_MODE_ADDSTIX) {
        // use original image and bake in stixLayer
        [stixView initializeWithImage:tag.image];
        [stixView multiStixInitializeWithTag:tag useStixLayer:YES];
        [self.view insertSubview:stixView aboveSubview:imageView];
        [stixView setAlpha:1];
        [buttonClose setAlpha:1];
        isLoadingPixSource = NO;
    }
    else { // remixMode == REMIX_MODE_USEORIGINAL
#if 1
        // use original image without baking in stixLayer
        if (stixView)
            [stixView removeFromSuperview];
        [stixView initializeWithImage:tag.image];
        [stixView multiStixInitializeWithTag:tag useStixLayer:NO];
        [self.view insertSubview:stixView aboveSubview:imageView];
        [stixView setAlpha:1];
        [buttonClose setAlpha:1];
        isLoadingPixSource = NO;
#else
        if (tag.highResImage != nil) {
            NSLog(@"StixEditor using existing high res image from tag");
            UIImage * newImage = [tag.highResImage resizedImage:stixView.frame.size interpolationQuality:kCGInterpolationHigh];
            [stixView initializeWithImage:newImage];
            //[stixView multiStixInitializeWithTag:tag];
            [self.view insertSubview:stixView aboveSubview:imageView];
            [stixView setAlpha:1]; // todo: fade in
            [buttonClose setAlpha:1];
            isLoadingPixSource = NO;
        } 
        else {
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            [self startActivityIndicator];
            if (tag.highResImageID != nil) {
                NSLog(@"StixEditor requesting high res image by highResImageID %@", tag.highResImageID);
                // uses tag's highResImageID which is not tagID
                NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag, nil];
                [kh execute:@"getHighResImage" withParams:params withCallback:@selector(khCallback_didGetHighResImage:) withDelegate:self];        
            }
            else {
                NSLog(@"StixEditor requesting high res image by tagID %@", tag.tagID);
                // uses tagID to search for highresImage - usually for the original pic
                NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag, nil];
                [kh execute:@"getHighResImageForTagID" withParams:params withCallback:@selector(khCallback_didGetHighResImage:) withDelegate:self];        
            }
        }
#endif
    }
    
    [stixPanel carouselTabExpand:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)didClickButtonDelete:(id)sender {
    NSLog(@"Did click delete stix");
    // delete currently selected stix
    if (isLoadingPixSource)
        return;
    int stixLeft = [stixView multiStixDeleteCurrentStix];
    if (stixLeft < 1) {
        [self disableButtonDelete];
        [self disableButtonClear];
    }
}
-(IBAction)didClickButtonClear:(id)sender {
    NSLog(@"Did click clear stix");
    if (isLoadingPixSource)
        return;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Clear all Stix"
                                                    message:@"Are you sure you want to remove all Stix?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];    
    
    [alert show];
}

-(void)disableButtonClear {
    [buttonClear setAlpha:.35];
    [buttonClear setEnabled:NO];
}
-(void)disableButtonDelete {
    [buttonDelete setAlpha:.35];
    [buttonDelete setEnabled:NO];
}
-(void)enableButtonClear {
    [buttonClear setAlpha:1];
    [buttonClear setEnabled:YES];
}
-(void)enableButtonDelete {
    [buttonDelete setAlpha:1];
    [buttonDelete setEnabled:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index: %d", buttonIndex);    
    // 0 = cancel = NO
    // 1 = other = YES
    
    if (buttonIndex == 1) {
        [stixView multiStixClearAllStix];
        [self disableButtonDelete];
        [self disableButtonClear];
    }
}

-(IBAction)didClickButtonAddStix:(id)sender {
    NSLog(@"Did click add stix");
    if (isLoadingPixSource)
        return;
    [stixPanel carouselTabExpand:YES];
}
-(IBAction)didClickButtonSave:(id)sender {
    NSLog(@"Did click save stix");
    if (isLoadingPixSource)
        return;
    [self saveRemixedPix];
    
#if USING_FLURRY
    if (!IS_ADMIN_USER([delegate getUsername]))
        [FlurryAnalytics logEvent:@"CloseStixEditor" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Saved Edits", @"Method Of Quitting", nil]];
#endif
}
-(IBAction)didClickButtonClose:(id)sender {
    NSLog(@"Did click close stix editor");
    if (isLoadingPixSource)
        return;
    [delegate didCloseEditor];
#if USING_FLURRY
    if (!IS_ADMIN_USER([delegate getUsername]))
        [FlurryAnalytics logEvent:@"CloseStixEditor" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Cancelled Edits", @"Method Of Quitting", nil]];
#endif
}

-(void)startActivityIndicator {
    if (!activityIndicator) {
        activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
        [activityIndicator setCenter:stixView.center];
        [self.view addSubview:activityIndicator];
    }
    [activityIndicator setHidden:NO];
    [activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [activityIndicator stopCompleteAnimation];
    [activityIndicator setHidden:YES];
}

#pragma mark StixPanel delegate

-(void)didTapStixOfType:(NSString *)stixStringID {
    [stixPanel carouselTabDismiss:YES];
    CGPoint center = imageView.center;
    // location is in TagDescriptorController's view
    center.x -= imageView.frame.origin.x;
    center.y -= imageView.frame.origin.y;

    [stixView setInteractionAllowed:YES];
    //[stixView populateWithStixForManipulation:stixStringID withCount:1 atLocationX:center.x andLocationY:center.y];
    [stixView multiStixAddStix:stixStringID atLocationX:center.x andLocationY:center.y];
    
    [self enableButtonDelete];
    [self enableButtonClear];
}

#pragma mark KumuloHelper delegate
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

-(void)khCallback_didGetHighResImage:(NSArray*)returnParams {
    // this is the callback for both getHighResImage calls
#if 0
    // do nothing: we are not loading high res image for remixing
    [self stopActivityIndicator];
    Tag * tag = [returnParams objectAtIndex:0];
    UIImage * newImage;
    UIImage * highResImage;
    NSArray * theResults = [returnParams objectAtIndex:1];
    if ([theResults count] == 0) { 
        NSLog(@"StixEditor: getHighResImage for tagID %d didn't have one!", [tag.tagID intValue]);
        // high res or original picture does not exist, use tag image
        newImage = tag.image;
        highResImage = tag.image;
    }
    else {
        NSLog(@"StixEditor: getHighResImage for tagID %d returned with a high res image", [tag.tagID intValue]);
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        NSData * dataPNG = [d objectForKey:@"dataPNG"];
        highResImage = [UIImage imageWithData:dataPNG];
        newImage = [highResImage resizedImage:stixView.frame.size interpolationQuality:kCGInterpolationHigh];
    }
    
    // saves to tag if it doesnt already have it - for optimization
    if ([delegate respondsToSelector:@selector(didGetHighResImage:forTagID:)])
        [delegate didGetHighResImage:highResImage forTagID:tag.tagID];
    
    [stixView initializeWithImage:newImage];
    [tag.auxStixStringIDs removeAllObjects]; // force no stix
    [stixView multiStixInitializeWithTag:tag:NO];
    [self.view insertSubview:stixView aboveSubview:imageView];
    [stixView setAlpha:1];
    [buttonClose setAlpha:1];
    isLoadingPixSource = NO;
#endif
}

-(void)saveRemixedPix {
    NSLog(@"Finishing editor with remix mode: %d", remixMode);

    // clear existing auxStixStringIDs
    [delegate didCloseEditor]; // delegate is always app delegate
    
    [remixTag setAuxStixStringIDs:nil];
    
    NSMutableArray * auxStixStringIDs = [stixView auxStixStringIDs];
    NSMutableArray * auxStixViews = [stixView auxStixViews];
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        UIImageView * auxStix = [auxStixViews objectAtIndex:i];
        if (stixStringID != nil) {
            [remixTag addStix:stixStringID withLocation:auxStix.center withTransform:auxStix.transform withPeelable:NO];
        }
    }
    
    // bake stix into stixLayer
    BOOL retainStixLayer = YES;
    if (remixMode == REMIX_MODE_USEORIGINAL)
        retainStixLayer = NO;
    else if (remixMode == REMIX_MODE_ADDSTIX)
        retainStixLayer = YES;

    UIImage * stixLayer = [remixTag tagToUIImageUsingBase:NO retainStixLayer:retainStixLayer useHighRes:NO];
    [remixTag setStixLayer:stixLayer];
    
    // now remove all auxstix - no longer saved after baking into stixlayer
    //[auxStixStringIDs removeAllObjects];
    //[auxStixViews removeAllObjects];
    [remixTag.auxStixStringIDs removeAllObjects];
    [delegate didRemixNewPix:remixTag remixMode:remixMode];
}
@end
