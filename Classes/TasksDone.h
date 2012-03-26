//
//  TasksDone.h
//  JustDone
//
//  Created by elian on 29/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TasksDone : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate> {

    NSFetchedResultsController * fetchController, *fetchSearchController;
    NSManagedObjectContext *objContext;
    UISearchDisplayController * searchController;
    UINavigationController * navController;
}

@property (nonatomic, retain) NSManagedObjectContext *objContext;
@property (nonatomic, retain) UINavigationController * navController;

- (IBAction)searchTask:(id)sender;
- (IBAction)removeAll:(id)sender;
- (IBAction)back:(id)sender;

- (void)configureCell:(UITableViewCell *)cell withObject:(Task*)task;
- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event;

@end
