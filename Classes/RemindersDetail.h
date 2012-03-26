//
//  RemindersDetail.h
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

@interface RemindersDetail : UIViewController <UITextViewDelegate, UIActionSheetDelegate> {

    NSManagedObjectContext *objContext;
    UISegmentedControl *priority , *repeat;
    UITextView * name;
    Reminder * curReminder;
    UIToolbar * toolBar;
}

@property (nonatomic, retain) NSManagedObjectContext *objContext;
@property (nonatomic, assign) Reminder * curReminder;

@property (nonatomic, retain) IBOutlet UISegmentedControl * priority;
@property (nonatomic, retain) IBOutlet UISegmentedControl * repeat;
@property (nonatomic, retain) IBOutlet UITextView * name;
@property (nonatomic, retain) IBOutlet UIToolbar * toolBar;

- (void)save;
- (IBAction)valueChanged:(id)sender;
- (IBAction)remove:(id)sender;


@end
