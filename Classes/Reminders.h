//
//  Reminders.h
//  JustDone
//
//  Created by elian on 07/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Reminders : UITableViewController <NSFetchedResultsControllerDelegate> {

    NSFetchedResultsController * fetchController;
    NSManagedObjectContext *objContext;

}

@property (nonatomic, retain) NSManagedObjectContext *objContext;

- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event;
- (IBAction)showButton:(id)sender;
- (IBAction)addTask:(id)sender;

- (void)fetchReminders;
- (NSUInteger)tomorrowNumberOfReminders;
- (NSUInteger)numberOfReminders;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)index;


@end
