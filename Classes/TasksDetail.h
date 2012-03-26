//
//  TasksDetail.h
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import <MessageUI/MessageUI.h>

@interface TasksDetail : UIViewController <UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {

    NSManagedObjectContext *objContext;
    UISegmentedControl * priority;
    UITextView * name;
    UITextField * deadline;
    Task * curTask;
    NSDate * userDeadline;
    UIToolbar * toolBar;
    UIButton * backButton;
}

@property (nonatomic, retain) NSManagedObjectContext *objContext;
@property (nonatomic, assign) Task * curTask;
@property (nonatomic, assign) NSDate * userDeadline;

@property (nonatomic, retain) IBOutlet UISegmentedControl * priority;
@property (nonatomic, retain) IBOutlet UITextView * name;
@property (nonatomic, retain) IBOutlet UITextField * deadline;
@property (nonatomic, retain) IBOutlet UIToolbar * toolBar;

- (void)save;
- (IBAction)clearDate:(id)sender;
- (IBAction)valueChanged:(id)sender;
- (IBAction)mail:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)datePickerChanged:(id)sender;

@end
