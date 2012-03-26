//
//  Tasks.h
//  JustDone
//
//  Created by elian on 29/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface Tasks : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {

    NSManagedObjectContext *objContext;
    NSFetchedResultsController * fetchController;
}

@property (nonatomic, retain) NSManagedObjectContext *objContext;

- (IBAction)addTask:(id)sender;
- (IBAction)showDone:(id)sender;
- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event;

- (void)configureCell:(UITableViewCell *)cell withObject:(Task*)task;

@end
