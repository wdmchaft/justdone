//
//  RemindersAll.h
//  JustDone
//
//  Created by elian on 12/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RemindersAll : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController * fetchController;
    NSManagedObjectContext *objContext;
    UINavigationController * navController;
}

@property (nonatomic, retain) NSManagedObjectContext *objContext;
@property (nonatomic, retain) UINavigationController * navController;

- (IBAction)doneCheckbox:(id)sender withEvent:(UIEvent*)event;
- (IBAction)back:(id)sender;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)index;

@end
