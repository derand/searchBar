//
//  mainViewController.h
//  searchBar
//
//  Created by maliy on 9/23/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface mainViewController : UIViewController <UISearchBarDelegate,
								UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tv;
	UISearchBar *sb;
	
	NSMutableArray *itemsList;
	NSMutableArray *searched;
	
	BOOL keyboardShown;
}

@end
