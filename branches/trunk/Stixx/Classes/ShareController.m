//
//  ShareController.m
//  Stixx
//
//  Created by Bobby Ren on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShareController.h"
#import <QuartzCore/QuartzCore.h>
#import "SHKTwitter.h"
#import "SHKConfiguration.h"

#define ROW_HEIGHT 44
#define NUM_SERVICES 2

static ShareController *sharedShareController;

@implementation ShareController

@synthesize caption;
@synthesize backButton, doneButton;
@synthesize tableView;
@synthesize delegate;
@synthesize shareURL, shareImageURL, shareCaption;
@synthesize tag, PNG, image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        serviceIsConnected = [[NSMutableDictionary alloc] init];
        serviceIsSharing = [[NSMutableDictionary alloc] init];
        k = [[Kumulos alloc] init]; // no need for delegate

        // create buttons and arrays
        [self initializeServices];
    }
    return self;
}
+(ShareController*)sharedShareController 
{
	if (!sharedShareController){
		sharedShareController = [[ShareController alloc] init];
	}
	return sharedShareController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [tableView setFrame:CGRectMake(20, 180, 280, ROW_HEIGHT * NUM_SERVICES - 20)];
    [tableView.layer setCornerRadius:10];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [caption setText:@""];
 
    // make sure first time instructions arrow is not showing
    [delegate hideFirstTimeArrowForShareController];
}

-(void)reloadConnections {
    [self didConnectService:@"Twitter"]; // force reload of table
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initializeServices {
    
    // configuring sharekit
    DefaultSHKConfigurator *configurator = [[MySHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    //[[SHK currentHelper] setCurrentView:self]; // dont do this or auth screen won't work
    
    names = [[NSMutableArray alloc] initWithObjects:@"Facebook", @"Twitter", @"Instagram", @"Tumblr", @"Pinterest", nil];
    NSMutableArray * imageNames = [[NSMutableArray alloc] initWithObjects:@"icon_share_facebook@2x.png", @"icon_share_twitter@2x.png", @"icon_share_instagram@2x.png", @"icon_share_tumblr@2x.png", @"icon_share_pinterest@2x.png", nil];
    //names = [[NSMutableArray alloc] initWithObjects:@"Facebook", @"Twitter", nil];
    //NSMutableArray * imageNames = [[NSMutableArray alloc] initWithObjects:@"icon_share_facebook@2x.png", @"icon_share_twitter@2x.png", nil];
    
    icons = [[NSMutableDictionary alloc] init];
    connectButtons = [[NSMutableDictionary alloc] init];
    toggles = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[self numberOfServices]; i++) {
        NSString * name = [names objectAtIndex:i];
        
        UIImage * img = [UIImage imageNamed:[imageNames objectAtIndex:i]];
        CGSize newSize = CGSizeMake(32, 32);
        UIGraphicsBeginImageContext(newSize);
        [img drawInRect:CGRectMake(1, 1, 30, 30)];	
        
        UIImage* imageView = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        [icons setObject:imageView forKey:name];

        UIButton * connect = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 79,29)];
        [connect.titleLabel setText:name];
        [connect.titleLabel setHidden:YES];
        [connect addTarget:self action:@selector(didClickConnectButton:) forControlEvents:UIControlEventTouchUpInside];
        [connect setImage:[UIImage imageNamed:@"btn_share_connect@2x.png"] forState:UIControlStateNormal];
        [connectButtons setObject:connect forKey:name];
        
        UIButton * toggle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 79, 29)];
        [toggle.titleLabel setText:name];
        [toggle.titleLabel setHidden:YES];
        [toggle addTarget:self action:@selector(didClickToggleButton:) forControlEvents:UIControlEventTouchUpInside];
        int state = [self shareServiceIsSharing:name]; //button.tag;
        if (state == 0) {
            [toggle setImage:[UIImage imageNamed:@"btn_share_switch_off@2x.png"] forState:UIControlStateNormal];
        } else {
            [toggle setImage:[UIImage imageNamed:@"btn_share_switch_on@2x.png"] forState:UIControlStateNormal];
        }
        //[toggle setTag:1]; // toggle tag is the state of the toggle
        [toggles setObject:toggle forKey:name];
    }
}

-(int)numberOfServices {
    // returns the number of sharing/social network services
    return NUM_SERVICES;
}

#pragma mark - Table view data source

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    // Configure the cell...
    int index = [indexPath row];
    NSString * service = [names objectAtIndex:index];
    [cell.textLabel setText:service];
    [cell.imageView setImage:[icons objectForKey:service]];
    [cell.imageView setFrame:CGRectMake(3, 3, 25, 25)];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([self shareServiceIsConnected:service]) {
        cell.accessoryView = [toggles objectForKey:service];
    }
    else {
        cell.accessoryView = [connectButtons objectForKey:service];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self numberOfServices];
}

#pragma mark button clicks

-(void)didClickBackButton:(id)sender {
    NSLog(@"Clicking back button!");
    
    [caption resignFirstResponder];

    shareURL = nil;
    shareImageURL = nil;
    uploadingImageLock = NO;
    
    [delegate shouldCloseShareController:NO];
}

-(void)didClickDoneButton:(id)sender {
    NSLog(@"Clicking done button!");
    
    [caption resignFirstResponder];
    [self setShareCaption:[caption text]];
    
    if (!activityIndicatorLarge)
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self.view addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];

#if 1
    [delegate shouldCloseShareController:YES];
#else
    [self uploadImage:PNG];
#endif
}

-(void)didClickConnectButton:(id)sender {
    UIButton * button = (UIButton*)sender;
    NSLog(@"Clicking connect for %@", button.titleLabel.text);

    //[delegate connectService:button.titleLabel.text];
    if ([button.titleLabel.text isEqualToString:@"Twitter"]) {
        // enable twitter
        [self doTwitterConnect];
    }
}

-(void)didConnectService:(NSString*)name {
    // called by delegate after isConnected:service has changed states
    [tableView reloadData];
}

-(void)didClickToggleButton:(id)sender {
    UIButton * button = (UIButton*)sender;
    NSString * service = button.titleLabel.text;
    NSLog(@"Clicking toggle for %@", button.titleLabel.text);
    
    int state = [self shareServiceIsSharing:service]; //button.tag;
    if (state == 0) {
        state = 1;
        [button setImage:[UIImage imageNamed:@"btn_share_switch_on@2x.png"] forState:UIControlStateNormal];
        [self shareServiceDidToggle:service];
        //button.tag = state;
    } else {
        state = 0;
        [button setImage:[UIImage imageNamed:@"btn_share_switch_off@2x.png"] forState:UIControlStateNormal];
        [self shareServiceDidToggle:service];
        //button.tag = state;
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

-(void)uploadImage:(NSData *)dataPNG{
    NSLog(@"ShareController starting upload image!");
    //if ([delegate respondsToSelector:@selector(sharePixDialogDidFinish)])
    //    [delegate sharePixDialogDidFinish];
    
    uploadingImageLock = YES;
    
    NSString * username = [[delegate getUsername] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString * serverString = [NSString stringWithFormat:@"http://%@/users/%@/pictures", HOSTNAME, username];
    NSURL *url=[[NSURL alloc] initWithString:serverString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setData:dataPNG forKey:@"picture[data]"];
    [request startAsynchronous];
    //[url autorelease]; // arc conversion
    
}

-(void)startUploadImage:(Tag*)_tag withDelegate:(NSObject<ShareControllerDelegate> *)_delegate {
    UIImage * result = [_tag tagToUIImageUsingBase:YES retainStixLayer:YES useHighRes:YES];
    NSData *png = UIImagePNGRepresentation(result);
    [self setImage:result];
    [self setPNG:png];
    [self setTag:_tag];
    [self setDelegate:_delegate];
    [self uploadImage:png];
}

-(void)doSharePix {
    [self didSharePixWithURL:[self shareURL] andImageURL:[self shareImageURL]];
}

-(void)didSharePixWithURL:(NSString *)url andImageURL:(NSString*)imageURL{
    NSLog(@"ShareController didSharePixWithURL %@", url);

    uploadingImageLock = NO; // unlock, and wait for share dialog's DONE Button
#if 1
    // do everything synchronously - do this after uploadimage is done
    NSLog(@"ShareController starting share via various services");
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Pix shared by %@ at %@", [delegate getUsername], url);
    //NSString * subject = [NSString stringWithFormat:@"%@ wants to share and remix a photo!", [delegate getUsername]];
    NSString * fullmessage = [NSString stringWithFormat:@"Let's remix photos with crazy, fun digital stickers... %@", url];
    NSString * _caption = [NSString stringWithFormat:@"Get Sticky with me..."];
    if ([shareCaption length] > 0) {
        _caption = [NSString stringWithFormat:@"%@", shareCaption];
    }

    // Facebook - TODO: use sharekit
    if ([self shareServiceIsSharing:@"Facebook"]) {
        FacebookHelper * fbHelper = [FacebookHelper sharedFacebookHelper];
        [fbHelper postToFacebookWithLink:url andPictureLink:imageURL andTitle:@"See my Remixed Photo!" andCaption:_caption andDescription:fullmessage useDialog:NO]; // auto
    }
    
    // Twitter
    if ([self shareServiceIsSharing:@"Twitter"]) {
        SHKTwitter * twitter = [[SHKTwitter alloc] init];
        [twitter setShareDelegate:self];
        SHKItem *item = [SHKItem text:[NSString stringWithFormat:@"%@ %@", _caption, url]];
        [item setImage:self.image];
        [item setTitle:_caption];
        [twitter setItem:item];
        [twitter share];
    }
    
    //if ([delegate respondsToSelector:@selector(sharePixDialogDidFinish)]) // doesn't exist
    //    [delegate sharePixDialogDidFinish];

    if (activityIndicatorLarge) {
        [activityIndicatorLarge setHidden:YES];
        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
    }
    //[delegate shouldCloseShareController:YES];
#endif
}

#pragma mark ASIHttpRequest for sharing

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Response %d : %@", request.responseStatusCode, [request responseString]);
    // the response is an HTML file of the redirect to the image page
    // in this image page there is a meta tag: <meta shared_id='<ID>'>
    // also the webURL: <meta web_url='/users/<USERNAME>/pictures/<ID>'>
    
    NSString * responseString = [request responseString];
    NSRange range0 = [responseString rangeOfString:@"<meta web_url"];
    NSRange range1 = [responseString rangeOfString:@"<meta shared_id"];
    if (range0.length == 0 || range1.length == 0) {
        NSLog(@"Create share page failed!");
        //if ([delegate respondsToSelector:@selector(sharePixDialogDidFail:)])
        //    [delegate sharePixDialogDidFail:0];
    }
    else {
        range0.location = range0.location + 15;
        range0.length = range1.location - range0.location-3; // this could change based on how we output web
        NSString * substring = [responseString substringWithRange:range0];
        NSLog(@"substring for weburl: <%@>", substring);
        
        NSRange imgRange = [responseString rangeOfString:@"http://s3.amazonaws.com"];
        imgRange.length = 60;
        NSString * imgSubstring = [responseString substringWithRange:imgRange];
        NSRange imgRangeEnd = [imgSubstring rangeOfString:@"\" />"];
        imgRange.length = imgRangeEnd.location;
        imgSubstring = [responseString substringWithRange:imgRange];
        
        NSString * weburl = [NSString stringWithFormat:@"http://%@/%@", HOSTNAME,substring];

        [self setShareURL:weburl];
        [self setShareImageURL:imgSubstring];
        NSLog(@"Setting share caption: %@", [self shareCaption]);
#if 0
        [self didSharePixWithURL:weburl andImageURL:imgSubstring];
#else
        [delegate uploadImageFinished];
#endif
    }
}

- (void) requestFailed:(ASIHTTPRequest *) request {
    NSError *error = [request error];
    NSLog(@"%@", error);
    
    NSLog(@"ASIHttpRequest to upload image failed!");
#if 1
    if ([delegate respondsToSelector:@selector(sharePixDialogDidFail:)])
        [delegate sharePixDialogDidFail:1];
#else
    [self uploadImage:PNG];
#endif
}

#pragma mark sharekit

-(void)doTwitterConnect {
	[SHK setRootViewController:self];
    /*
    For Twitter with iOS 5, it will not autoshare. If you want twitter to autoshare on iOS 5, remove the iOS 5 support from the SHKTwitter.m file.
    
    - (BOOL)twitterFrameworkAvailable {
        return NO;
        ...
    }
    
    To enable autoshare, change this function to return YES for both SHKTwitter.m and SHKFacebook.m.
        
        - (BOOL)shouldAutoShare
    {
        return YES;
    }
     */
    
    // only do this to test oauth
    if ([SHKTwitter isServiceAuthorized])
    {
        //[SHKTwitter logout];
        NSLog(@"Twitter already authorized!");   
    }
    SHKTwitter * twitter = [[SHKTwitter alloc] init];
    [twitter setShareDelegate:self];
    
#if 1
    // try to connect only
    if ([SHK connected] // has internet
        && ![SHKTwitter isServiceAuthorized]) { 
        SHKItem *item = [[SHKItem alloc] init];
        [item setShareType:SHKShareTypeUserInfo];
        [twitter setItem:item];
        [twitter share];
    } else {
        [self didTwitterConnect];
    }
#else
    // do a full share
    // Create the item to share (in this example, a url)
    SHKItem *item = [SHKItem text:@"Twitter from stix"];
    [twitter setItem:item];
    [twitter share];
#endif
}

-(void)didTwitterConnect {
    NSString * service = @"Twitter";
    
    // set connect to true in defaults
    [self connectService:service];
    
    // set sharing to true in share controller menu
    [self shareServiceShouldShare:YES forService:service]; 

    // saving to defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * connectedString = [NSString stringWithFormat:@"%@IsConnected", service]; // should not be not connected
    NSString * sharingString = [NSString stringWithFormat:@"%@IsSharing", service];
    BOOL isConnected = [[serviceIsConnected objectForKey:service] boolValue];
    BOOL isSharing = [[serviceIsSharing objectForKey:service] boolValue];
    NSLog(@"Toggling sharing service %@: %@ %d %@ %d", service, @"connected: ", isConnected, @"sharing: ", isSharing);
    [defaults setBool:isConnected forKey:connectedString];
    [defaults setBool:isSharing forKey:sharingString];
    [defaults synchronize];

}

-(void)doTwitterShare {
    SHKTwitter * twitter = [[SHKTwitter alloc] init];
    [twitter setShareDelegate:self];
    SHKItem *item = [SHKItem text:@"Twitter from stix"];
    [twitter setItem:item];
    [twitter share];
}

- (void)sharerStartedSending:(SHKSharer *)sharer {
    NSLog(@"Started sending");
}
- (void)sharerFinishedSending:(SHKSharer *)sharer {
    if ([[sharer item] shareType] == SHKShareTypeUserInfo) {
        NSLog(@"Finished sending: userinfo");
        [self didTwitterConnect];
    }

    // only cause activityIndicator to go away when all sharers have finished? or just do in background?
    /*
    if (activityIndicatorLarge) {
        [activityIndicatorLarge setHidden:YES];
        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
    }
    //[delegate shouldCloseShareController:YES];
    [delegate shouldCloseShareController:NO];
     */
}
- (void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin {
    NSLog(@"Failed with error: %@ shouldRelogin: %d", [error description], shouldRelogin);
    
    // todo: display duplicate status error - should not happen
}
- (void)sharerCancelledSending:(SHKSharer *)sharer {
    NSLog(@"Cancelled sending");
}
- (void)sharerShowBadCredentialsAlert:(SHKSharer *)sharer {
    NSLog(@"Bad credentials!");
}
- (void)sharerShowOtherAuthorizationErrorAlert:(SHKSharer *)sharer {
    NSLog(@"Other error");
}


-(BOOL) shareServiceIsConnected:(NSString *)service {
    NSNumber * connectionState = [serviceIsConnected objectForKey:service];
    if (!connectionState) {
        // check with each service to see if it's already connected
        if ([service isEqualToString:@"Facebook"]) {
            FacebookHelper * fbHelper = [FacebookHelper sharedFacebookHelper];
            if (![fbHelper facebookHasSession])
                return NO;
            // hack: assume that if session is valid, user has given post permission
            return YES;
        }
        else {
            return NO;
        }
    }
    NSLog(@"%@ is connected: %d", service, [connectionState boolValue]);
    return [connectionState boolValue];
}
-(BOOL) shareServiceIsSharing:(NSString*)service {
    NSLog(@"ServiceIsSharing: %d objects", [serviceIsSharing count]);
    NSNumber * sharingState = [serviceIsSharing objectForKey:service];
    if (!sharingState)
        return NO;
    NSLog(@"%@ exists and is sharing: %d", service, [sharingState boolValue]);
    return [sharingState boolValue];
}

-(void)shareServiceDidToggle:(NSString *)service {
    BOOL state = [self shareServiceIsSharing:service];
    [serviceIsSharing setObject:[NSNumber numberWithBool:!state] forKey:service];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * connectedString = [NSString stringWithFormat:@"%@IsConnected", service]; // should not be not connected
    NSString * sharingString = [NSString stringWithFormat:@"%@IsSharing", service];
    BOOL isConnected = [[serviceIsConnected objectForKey:service] boolValue];
    BOOL isSharing = [[serviceIsSharing objectForKey:service] boolValue];
    
    if (isSharing) {
        [k addMetricWithDescription:@"ShareServiceToggle" andUsername:[delegate getUsername] andStringValue:[NSString stringWithFormat:@"SharingOn", service] andIntegerValue:0];
    }
    else {
        [k addMetricWithDescription:@"ShareServiceToggle" andUsername:[delegate getUsername] andStringValue:[NSString stringWithFormat:@"SharingOn", service] andIntegerValue:0];
    }    
    NSLog(@"Toggling sharing service %@: %@ %d %@ %d", service, connectedString, isConnected, sharingString, isSharing);
    [defaults setBool:isConnected forKey:connectedString];
    [defaults setBool:isSharing forKey:sharingString];
    [defaults synchronize];
}

-(void)connectService:(NSString *)service {
    // only changes the serviceIsSharing toggle array and defaults to YES - actual connection happens in ShareController
    NSLog(@"Connecting sharing service %@", service);
    
    [serviceIsConnected setObject:[NSNumber numberWithBool:YES] forKey:service];
    [serviceIsSharing setObject:[NSNumber numberWithBool:YES] forKey:service]; // automatically start sharing after connect
    [self didConnectService:service]; // just reloads table
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * connectString = [NSString stringWithFormat:@"%@IsConnected", service];
    NSString * shareString = [NSString stringWithFormat:@"%@IsSharing", service];
    [defaults setBool:[[serviceIsConnected objectForKey:service] boolValue] forKey:connectString];
    [defaults setBool:[[serviceIsSharing objectForKey:service] boolValue] forKey:shareString];
    [defaults synchronize];
    
    [k addMetricWithDescription:@"ShareServiceConnect" andUsername:[delegate getUsername] andStringValue:service andIntegerValue:0];
//    else {
//        [self showAlertWithTitle:@"Connect for Share" andMessage:[NSString stringWithFormat:@"Connecting with %@ coming soon!", service] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
//    }
}

-(void)shareServiceShouldShare:(BOOL)doShare forService:(NSString *)service {
    [serviceIsSharing setObject:[NSNumber numberWithBool:doShare] forKey:service]; // automatically start sharing after connect
    
    // update image
    NSLog(@"Share service %@ should share: %d", service, doShare);
    UIButton * toggle = [toggles objectForKey:service];
    if (doShare) {
        [toggle setImage:[UIImage imageNamed:@"btn_share_switch_on@2x.png"] forState:UIControlStateNormal];
    }
    else {
        [toggle setImage:[UIImage imageNamed:@"btn_share_switch_off@2x.png"] forState:UIControlStateNormal];
    }
    [toggles setObject:toggle forKey:service];
}
-(void)shareServiceShouldConnect:(BOOL)doConnect forService:(NSString *)service {
    [serviceIsConnected setObject:[NSNumber numberWithBool:doConnect] forKey:service]; // automatically start sharing after connect
}
@end
