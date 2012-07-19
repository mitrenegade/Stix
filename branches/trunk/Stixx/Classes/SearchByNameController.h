//
//  SearchByNameController.h
//  Stixx
//
//  Created by Bobby Ren on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendSearchResultsController.h"
enum {
    RESULTS_SEARCH_FACEBOOK,
    RESULTS_SEARCH_NAME,
    RESULTS_SEARCH_CONTACTS
};

@protocol SearchByNameDelegate <NSObject>

-(NSMutableDictionary*)getAllUsers;
-(NSMutableArray*)getAllUserNames;
-(NSMutableArray*)getAllUserEmails;
-(NSMutableArray*)getAllUserFacebookStrings;
-(NSString*)getUsername;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
@end

@interface SearchByNameController : UIViewController <FriendSearchResultsDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSObject<SearchByNameDelegate> * __unsafe_unretained delegate;
    IBOutlet UISearchBar * searchBar;
    IBOutlet UITableView * tableView;

    NSMutableArray * searchFriendName;
    NSMutableArray * searchFriendEmail;
    NSMutableArray * searchFriendID;
    NSMutableArray * searchFriendIsStix;
    
    FriendSearchResultsController * searchResultsController;
    
    int resultType;
}
@property (nonatomic, unsafe_unretained)    NSObject<SearchByNameDelegate> * delegate;
@property (nonatomic) IBOutlet UISearchBar * searchBar;
@property (nonatomic) IBOutlet UITableView * tableView;

-(void)populateFacebookSearchResults:(NSMutableArray*)allFacebookFriendNames andFacebookStrings:(NSMutableArray*)allFacebookFriendStrings;
-(void)hideSearchBar;
-(void)showSearchBar;

-(void)populateContactSearchResults;
-(void)populateNameSearchResults;
@end
