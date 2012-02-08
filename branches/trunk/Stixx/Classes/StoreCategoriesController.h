//
//  StoreCategoriesController.h
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "OutlineLabel.h"

@protocol StoreCategoriesControllerDelegate
-(void)didSelectRow:(int)row;
-(void)didClickGetStix:(NSString*)stixStringID;
@end

@interface StoreCategoriesController : UITableViewController
{
    NSObject<StoreCategoriesControllerDelegate> *delegate;
    
    NSMutableArray * subcategories; // subcategories
    NSMutableArray * stixStringIDs; // stix in this category/subcategory
    NSMutableDictionary * stixStringButtons;
}

-(void)addSubcategory:(NSString *) string;
-(void)addSubcategoriesFromArray:(NSMutableArray *)subarray;
-(void)addStix:(NSString *)stixID;
-(void)addStixFromArray:(NSMutableArray *)stixArray;

-(int)getTypeForRow:(int)row;
-(NSString *)getStringForRow:(int)row;

-(void)didClickGetStix:(id)sender event:(id)event;

@property (nonatomic, assign) NSObject<StoreCategoriesControllerDelegate> *delegate;

@end
