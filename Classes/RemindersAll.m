//
//  RemindersAll.m
//  JustDone
//
//  Created by elian on 12/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import "RemindersAll.h"
#import "RemindersDetail.h"

@implementation RemindersAll

@synthesize objContext, navController;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Reminders" style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(back:)];
    
    self.navigationItem.title = @"All";
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    // Configure the request's entity, and optionally its predicates
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reminder" inManagedObjectContext:objContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    // Configure the sorters
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Init fetch controller and perform fetch
    fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:objContext 
                                                            sectionNameKeyPath:nil cacheName:nil];   
    fetchController.delegate = self;
    
    NSError *error;
    BOOL success = [fetchController performFetch:&error];
    if (!success) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't read reminder items." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [fetchRequest release];
    [sortDescriptors release];
    [sortDescriptor release];
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)index {
    Reminder *task = (Reminder*)[fetchController objectAtIndexPath:index];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage*img = [UIImage imageNamed:@"checkbox.png"];
    
    [button setImage:img forState:UIControlStateNormal];
    //[button setImage:[UIImage imageNamed:@"checkbox-pressed.png"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(doneCheckbox:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //button.frame = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
    button.frame = CGRectMake(-15.0, -15.0, img.size.width+15, img.size.height+15);

    button.userInteractionEnabled = YES;
    button.selected = NO;
 
    cell.detailTextLabel.text = nil;
    if ([task.reminderAfter compare:[NSDate date]] == NSOrderedDescending){
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'repeat' dd MMMM"];
        cell.detailTextLabel.text = [formatter stringFromDate:task.reminderAfter];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        button.selected = YES;
        [formatter release];
    }
    
    cell.accessoryView = button;
    cell.textLabel.text = task.name;
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event {
    UIButton*button = sender;
    
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (indexPath != nil){
        button.selected = !button.selected;
        [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (IBAction)back:(id)sender {
    [navController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[fetchController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return [fetchController sectionIndexTitles];
    return [NSArray array];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [fetchController sectionForSectionIndexTitle:title atIndex:index];
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
    RemindersDetail* controller = [[RemindersDetail alloc] initWithNibName:@"RemindersDetail" bundle:nil];
    
    controller.objContext = self.objContext;
    controller.curReminder = (Reminder*)[fetchController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Reminder *task = (Reminder*)[fetchController objectAtIndexPath:indexPath];
    
    if ([task.reminderAfter isEqualToDate:[NSDate dateWithTimeIntervalSince1970:1]]){
        switch ([task.reminder intValue]) {
            case 0:
                task.reminderAfter = [Reminder nextDayFromDate:[NSDate date]];
                break;
            case 1:
                task.reminderAfter = [Reminder nextMondayFromDate:[NSDate date]];
                break;
            case 2:
                task.reminderAfter = [Reminder nextMonthFromDate:[NSDate date]];
                break;
            default:
                break;
        }
    }else{
        task.reminderAfter = [NSDate dateWithTimeIntervalSince1970:1];
    }
    
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
    [self.tableView beginUpdates];
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
                     atIndexPath:indexPath];
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
    [self.tableView endUpdates];
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
    [navController release];
    
    [super dealloc];
}

@end

