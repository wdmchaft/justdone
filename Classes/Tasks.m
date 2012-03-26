//
//  Tasks.m
//  JustDone
//
//  Created by elian on 29/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Tasks.h"
#import "TasksDone.h"
#import "TasksDetail.h"

@implementation Tasks

@synthesize objContext;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                             target:self action:@selector(addTask:)];

    
    UIBarButtonItem *showButton = [[UIBarButtonItem alloc] initWithTitle:@"Completed" style:UIBarButtonItemStyleBordered 
                                                                               target:self action:@selector(showDone:)];
        
    self.navigationItem.title = @"Tasks";
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = showButton;
    
    // Configure the request's entity, and optionally its predicates
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:objContext];
    NSFetchRequest *fetchRequest = [[[entity managedObjectModel] fetchRequestTemplateForName:@"todoTasks"] copy];
    
    // Configure the sorters
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptor2,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Init fetch controller and perform fetch
    fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                        managedObjectContext:objContext sectionNameKeyPath:@"priorityName" cacheName:@"cacheTodo"];
    fetchController.delegate = self;
    
    NSError *error;
    BOOL success = [fetchController performFetch:&error];
    if (!success) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't read task items." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [fetchRequest release];
    [sortDescriptors release];
    [sortDescriptor release];
    [sortDescriptor2 release];
    
    [showButton release];
    [addButton release];
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
    UIImage*img = [UIImage imageNamed:@"checkbox.png"];
    
    [button setImage:img forState:UIControlStateNormal];
    //[button setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(doneCheckbox:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //button.frame = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
    button.frame = CGRectMake(-15.0, -15.0, img.size.width+15, img.size.height+15);

    button.userInteractionEnabled = YES;
    button.selected = NO;
    if ([task.done boolValue]) {
        button.selected = YES;
    }
    
    cell.textLabel.text = task.name;
    cell.detailTextLabel.text = nil;
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM"];
    if (task.deadline) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"due %@", [formatter stringFromDate:task.deadline]];
        if ([task.deadline compare:[NSDate date]] == NSOrderedAscending){
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
    cell.accessoryView = button;
    [formatter release];
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event {
    UIButton*button = sender;
    UITableView *tableView = self.tableView;
    
    NSIndexPath * indexPath = [tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: tableView]];
    if (indexPath != nil){
        button.selected = !button.selected;
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (IBAction)addTask:(id)sender {
    Task * task = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:objContext];
    NSError *error;
    if (![objContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't add item data." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [self.tableView scrollToRowAtIndexPath:[fetchController indexPathForObject:task] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)showDone:(id)sender {
    TasksDone* controller = [[TasksDone alloc] initWithNibName:@"TasksDone" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];

    controller.objContext = self.objContext;
    controller.navController = self.navigationController;
    [nav setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.navigationController presentModalViewController:nav animated:YES];
    
    [nav release];
    [controller release];
}


#pragma mark -
#pragma mark Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSFetchedResultsController * fetcher = fetchController;
    return [[fetcher sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    // Return the number of rows in the section.
    NSFetchedResultsController * fetcher = fetchController;
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
    [self configureCell:cell withObject:[fetcher objectAtIndexPath:indexPath]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSFetchedResultsController * fetcher = fetchController;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetcher sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //NSFetchedResultsController * fetcher = fetchController;
    //return [fetcher sectionIndexTitles];
    return [NSArray array];

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSFetchedResultsController * fetcher = fetchController;
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

    controller.objContext = self.objContext;
    controller.curTask = (Task*)[fetcher objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSFetchedResultsController * fetcher = fetchController;
    
    Task *task = (Task*)[fetcher objectAtIndexPath:indexPath];
    task.completionDate = [NSDate date];
    task.done = [NSNumber numberWithBool:YES];
    
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
#pragma mark Fetch Controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = self.tableView;
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
    
    [super dealloc];
}


@end

