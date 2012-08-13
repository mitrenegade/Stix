//
//  AboutViewController.h
//  Stixx
//
//  Created by Bobby Ren on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView * webView;
}
@property (nonatomic) IBOutlet UIWebView * webView;

@end
