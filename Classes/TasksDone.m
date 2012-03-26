//
//  TasksDone.m
//  JustDone
//
//  Created by elian on 29/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TasksDone.h"
#import "Task.h"
#import "TasksDetail.h"

@implementation TasksDone

@synthesize objContext, navController;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
                                                                               target:self action:@selector(searchTask:)];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                                                                target:self action:@selector(removeAll:)];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Tasks" style:UIBarButtonItemStyleBordered
                                                                                  target:self action:@selector(back:)];
    
    self.navigationItem.title = @"Completed";
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = searchButton;
    
    self.toolbarItems = [NSArray arrayWithObject:removeButton];
    
    // Configure the request's entity, and optionally its predicates
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:objContext];
    NSFetchRequest *fetchRequest = [[[entity managedObjectModel] fetchRequestTemplateForName:@"doneTasks"] copy];
    
    // Configure the sorters
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Init fetch controller and perform fetch
    fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                          managedObjectContext:objContext sectionNameKeyPath:nil cacheName:@"cacheDone"];
    fetchController.delegate = self;
    
    NSError *error;
    BOOL success = [fetchController performFetch:&error];
    if (!success) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't read completed task items." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [fetchRequest release];
    
    [sortDescriptors release];
    [sortDescriptor release];
    
    [searchButton release];
    [removeButton release];
    [backButton release];
    
    // Search bar initialization
    UISearchBar * searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;

    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    
    [searchBar release];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


#pragma mark -
#pragma mark Custom procedures

- (void)configureCell:(UITableViewCell *)cell withObject:(Task*)task {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage*img = [UIImage imageNamed:@"checkbox-checked.png"];
    
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(doneCheckbox:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //button.frame = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
    button.frame = CGRectMake(-15.0, -15.0, img.size.width+15, img.size.height+15);

    button.userInteractionEnabled = YES;
    button.selected = YES;
    
    cell.textLabel.text = task.name;
    cell.accessoryView = button;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'closed' dd MMMM"];
    cell.detailTextLabel.text = [formatter stringFromDate:task.completionDate];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    [formatter release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    return [[fetcher sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    // Return the number of rows in the section.
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetcher sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    [self configureCell:cell withObject:[fetcher objectAtIndexPath:indexPath]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetcher sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    return [fetcher sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    return [fetcher sectionForSectionIndexTitle:title atIndex:index];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TasksDetail* controller = [[TasksDetail alloc] initWithNibName:@"TasksDetail" bundle:nil];
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    
    controller.objContext = self.objContext;
    controller.curTask = (Task*)[fetcher objectAtIndexPath:indexPath];;
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSFetchedResultsController * fetcher = fetchController;
    if (tableView != self.tableView){
        fetcher = fetchSearchController;
    }
    
    Task *task = (Task*)[fetcher objectAtIndexPath:indexPath];
    task.completionDate = nil;
    task.done = [NSNumber numberWithBool:NO];
    
    NSError *error;
    if (![objContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't update item data." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event {
    UIButton*button = sender;
    UITableView *tableView = self.tableView;
    if (searchController.active){
        tableView = searchController.searchResultsTableView;
    }

    NSIndexPath * indexPath = [tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: tableView]];
    if (indexPath != nil){
        button.selected = !button.selected;
        [button setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];

        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}


- (IBAction)searchTask:(id)sender {
    self.tableView.tableHeaderView = searchController.searchBar;
    [searchController setActive:YES animated:YES];
}

- (IBAction)removeAll:(id)sender {
    UIActionSheet * popup = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete all completed tasks ?" delegate:self cancelButtonTitle:@"Cancel" 
                                          destructiveButtonTitle:@"Delete all" otherButtonTitles:nil];
    
    [popup showInView:self.view];
    [popup release];
}

- (IBAction)back:(id)sender {
    [navController dismissModalViewControllerAnimated:YES];
}
 
#pragma mark -
#pragma mark Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString * str = [NSString stringWithFormat:@"*%@*", searchBar.text];
    // Configure the request's entity, and optionally its predicates
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:objContext];
    NSFetchRequest *fetchRequest = [[entity managedObjectModel] fetchRequestFromTemplateWithName:@"nameLikeTasks" 
                                    substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:str,@"name",nil]];
    
    // Configure the sorters
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Init fetch controller and perform fetch
    fetchSearchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                managedObjectContext:objContext sectionNameKeyPath:nil cacheName:nil];
    fetchSearchController.delegate = self;
    
    NSError *error;
    BOOL success = [fetchSearchController performFetch:&error];
    if (!success) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't read search results." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [searchController.searchResultsTableView reloadData];

    [sortDescriptors release];
    [sortDescriptor release];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchController setActive:NO animated:YES];
    self.tableView.tableHeaderView = nil;
}

#pragma mark -
#pragma mark Search controller delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return NO;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.tableView.tableHeaderView = nil;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [fetchSearchController release];
    fetchSearchController = nil;
}


#pragma mark -
#pragma mark Remove action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.destructiveButtonIndex == buttonIndex){

        NSArray * objects = [fetchController fetchedObjects];
        for (NSManagedObject *managedObject in objects) {
            [objContext deleteObject:managedObject];
        }
        
        NSError *error;
        if (![objContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't delete completed task items." 
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            //[self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

#pragma mark -
#pragma mark Fetch Controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = self.tableView;
    if (controller != fetchController){
        tableView = searchController.searchResultsTableView;
    }
    [tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    if (controller != fetchController){
        tableView = searchController.searchResultsTableView;
    }
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    withObject:[controller objectAtIndexPath:indexPath]];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = self.tableView;
    if (controller != fetchController){
        tableView = searchController.searchResultsTableView;
    }
    [tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [objContext release];
    [fetchController release];
    [searchController release];
    [fetchSearchController release];
    [navController release];
    
    [super dealloc];
}


@end

