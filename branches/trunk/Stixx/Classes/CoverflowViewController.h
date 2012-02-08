//
//  CoverflowViewController.h
//  Stixx
//
//  Created by Bobby Ren on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@protocol CoverflowViewControllerDelegate
-(void)didSelectCoverAtIndex:(int)index;
-(NSMutableArray*)getCoverFilenames;
@end

@interface CoverflowViewController : UIViewController <TKCoverflowViewDelegate, TKCoverflowViewDataSource> {
    
    // The coverflow view
	TKCoverflowView *coverflow; 
    
	// Covers images
	NSMutableArray *covers; 
    
    NSObject<CoverflowViewControllerDelegate> * delegate;
}

-(void)setCoverflowFrame:(CGRect)frame;

@property (retain,nonatomic) TKCoverflowView *coverflow;
@property (nonatomic, retain) NSObject<CoverflowViewControllerDelegate> * delegate;

@end
