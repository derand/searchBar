//
//  mainViewController.h
//  searchBar
//
//  Created by maliy on 9/23/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import "mainViewController.h"


@implementation mainViewController

#pragma mark lifeCycle

- (id) init
{
	if (self = [super init])
	{
		itemsList = [[NSMutableArray alloc] initWithCapacity:200];
		for (NSInteger i=0; i<200; i++)
		{
			[itemsList addObject:[NSString stringWithFormat:@"item %03d", i+1]];
		}
		
		keyboardShown = NO;
	}
	return self;
}

- (void) dealloc
{
	[searched release];
	[itemsList release];
	
	[super dealloc];
}

#pragma mark -

- (void) search:(NSString *) matchString
{
	NSString *upString = [matchString uppercaseString];
	if (searched)
		[searched release];
	
	searched = [[NSMutableArray alloc] init];
	for (NSString *line in itemsList)
	{
		if ([matchString length] == 0)
		{
			[searched addObject:line];
			continue;
		}
		
		NSRange range = [[line uppercaseString] rangeOfString:upString];
		if (range.location != NSNotFound)
			[searched addObject:line];
	}
	
	[tv reloadData];
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self search:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark tableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [searched count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *rv = nil;
	NSString *cellID = @"cell_ID";
	rv = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (rv==nil)
	{
		rv = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellID] autorelease];
	}
	rv.textLabel.text = [searched objectAtIndex:indexPath.row];
    return rv;
}

- (void) deselect
{
	[tv deselectRowAtIndexPath:[tv indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSelector:@selector(deselect) withObject:nil afterDelay:0.5];
}

#pragma mark -

- (void) keyboardWillShown:(NSNotification*) aNotification
{
	if (keyboardShown)
		return;
	
	NSDictionary* info = [aNotification userInfo];
	NSLog(@"%@", info);
	
	// Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	if (!aValue)
	{
		aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	}
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	CGRect rct = CGRectMake(0.0, sb.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-sb.frame.size.height);
	CGFloat kHeight = MIN(keyboardSize.width, keyboardSize.height);
	rct.size.height -= kHeight;
	tv.frame = rct;
	
	keyboardShown = YES;
}

- (void) keyboardDidShown:(NSNotification*) aNotification
{
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
	tv.frame = CGRectMake(0.0, sb.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-sb.frame.size.height);
	keyboardShown = NO;
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShown:)
												 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
}

- (void) unRegisterForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -

- (void) viewDidAppear:(BOOL) animated
{
	[self registerForKeyboardNotifications];
}

- (void) viewDidDisappear:(BOOL) animated
{
	[self unRegisterForKeyboardNotifications];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
										  duration:(NSTimeInterval) duration
{
	if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft ||
		interfaceOrientation==UIInterfaceOrientationLandscapeLeft)
	{
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
	else
	{
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}

}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	[super loadView];
	
	self.navigationItem.title = NSLocalizedString(@"Search test", @"");
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	
	UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	contentView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
	
	self.view = contentView;
	[contentView release];

	CGRect rct = self.navigationController.navigationBar.frame;
	rct.origin.y = 0.0;
	sb = [[UISearchBar alloc] initWithFrame:rct];
    sb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	sb.showsCancelButton = YES;
	sb.delegate = self;
	[self.view addSubview:sb];
	
	rct = CGRectMake(0.0, sb.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-sb.frame.size.height);
	tv = [[UITableView alloc] initWithFrame:rct style:UITableViewStylePlain];
	tv.delegate = self;
	tv.dataSource = self;
	//tv.scrollEnabled = NO; // no scrolling in this case, we don't want to interfere with text view scrolling
	tv.autoresizesSubviews = YES;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:tv];
	
	[self search:@""];

}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[tv release];
	[sb release];
}



@end
