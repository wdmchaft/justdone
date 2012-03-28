//
//  Reminders.m
//  JustDone
//
//  Created by elian on 07/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import "Reminders.h"
#import "RemindersAll.h"
#import "RemindersDetail.h"

@implementation Reminders

@synthesize objContext;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                               target:self action:@selector(addTask:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];

    UIBarButtonItem *showButton = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStyleBordered
                                                                               target:self action:@selector(showButton:)];
    self.navigationItem.leftBarButtonItem = showButton;
    [showButton release];
    
    self.navigationItem.title = @"Reminders";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchReminders];
}

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

- (void)fetchReminders {
    // Configure the request's entity, and optionally its predicates
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reminder" inManagedObjectContext:objContext];
    NSFetchRequest *fetchRequest;
    fetchRequest = [[entity managedObjectModel] fetchRequestFromTemplateWithName:@"reminderTasks" 
                                                           substitutionVariables:[NSDictionary dictionaryWithObject:[NSDate date] forKey:@"date"]];
    // Configure the sorters
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"reminder" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Init fetch controller and perform fetch
    [fetchController release];
    fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:objContext 
                                                            sectionNameKeyPath:@"reminderName" cacheName:nil];   
    fetchController.delegate = nil;
    
    NSError *error;
    BOOL success = [fetchController performFetch:&error];
    if (!success) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't read reminder items." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    NSUInteger count = [fetchController.fetchedObjects count];
    self.navigationController.tabBarItem.badgeValue = nil;
    if (count > 0)
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", count];

    [self.tableView reloadData];
    
    [sortDescriptors release];
    [sortDescriptor release];
    [sortDescriptor2 release];
}

- (NSUInteger)numberOfReminders {
    [self fetchReminders];
    return [fetchController.fetchedObjects count];
}

- (NSUInteger)tomorrowNumberOfReminders {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reminder" inManagedObjectContext:objContext];
    NSFetchRequest *fetchRequest;
    fetchRequest = [[entity managedObjectModel] fetchRequestFromTemplateWithName:@"reminderTasks" 
                                                           substitutionVariables:[NSDictionary dictionaryWithObject:
                                                                                  [NSDate dateWithTimeIntervalSinceNow:3600*24] forKey:@"date"]];
    [fetchRequest setResultType:NSManagedObjectIDResultType];
    NSError * error;
    NSUInteger count = 0;
    NSArray * result = [objContext executeFetchRequest:fetchRequest error:&error];
    if (result){
        count = [result count];
    }
    return count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)index {
    Reminder *task = (Reminder*)[fetchController objectAtIndexPath:index];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage*img = [UIImage imageNamed:@"checkbox.png"];
    
    [button setImage:img forState:UIControlStateNormal];
    //[button setImage:[UIImage imageNamed:@"checkbox-pressed.png"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(doneCheckbox:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake(-15.0, -15.0, img.size.width+15, img.size.height+15);
    button.userInteractionEnabled = YES;
    button.selected = NO;

    NSArray * prios = [NSArray arrayWithObjects:@"low",@"normal",@"high",nil];
    NSArray * colors = [NSArray arrayWithObjects:[UIColor grayColor],[UIColor brownColor],[UIColor orangeColor],nil];
    cell.detailTextLabel.text = [prios objectAtIndex:[task.priority unsignedIntegerValue]];
    cell.detailTextLabel.textColor = [colors objectAtIndex:[task.priority unsignedIntegerValue]];
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

- (IBAction)addTask:(id)sender {
    Reminder * reminder = (Reminder *)[NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:objContext];
    NSError *error;
    if (![objContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't add item data." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [self fetchReminders];
    [self.tableView scrollToRowAtIndexPath:[fetchController indexPathForObject:reminder] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)showButton:(id)sender {
    RemindersAll* controller = [[RemindersAll alloc] initWithNibName:@"RemindersAll" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];

    controller.objContext = self.objContext;
    controller.navController = self.navigationController;
    [nav setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.navigationController presentModalViewController:nav animated:YES];
    
    [controller release];
    [nav release];
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
    Reminder*task = (Reminder*)[fetchController objectAtIndexPath:indexPath];

    if ([task.reminderAfter compare:[NSDate date]] == NSOrderedAscending){
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

