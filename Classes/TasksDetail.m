//
//  TasksDetail.m
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import "TasksDetail.h"
#import <QuartzCore/QuartzCore.h>


@implementation TasksDetail

@synthesize objContext, priority, name, deadline, curTask, userDeadline, toolBar;


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        self.toolBar.hidden = YES;
    
    self.navigationItem.title = @"Details";
    self.userDeadline = nil;
    
    name.layer.cornerRadius = 5;
    name.clipsToBounds = YES;
    name.text = curTask.name;
    priority.selectedSegmentIndex = [curTask.priority intValue];
    if (curTask.deadline) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM' at 'hh:mm a"];
        deadline.text = [formatter stringFromDate:curTask.deadline];
        [formatter release];
    }
    
    UIDatePicker* datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.date = [NSDate date];
    datePicker.minuteInterval = 15;
    [datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    deadline.inputView = datePicker;
    
    [datePicker release];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.toolBar.hidden = YES;
    }else{
        self.toolBar.hidden = NO;
    }
}


#pragma mark -
#pragma mark Custom procedures

- (void)save {    
    curTask.priority = [NSNumber numberWithInteger:self.priority.selectedSegmentIndex];
    
    if (self.userDeadline)
        curTask.deadline = self.userDeadline;
    
    if ([self.name.text length] > 0){
        curTask.name = self.name.text;
    }else {
        self.name.text = curTask.name;
    }

    NSError *error;
    if (![objContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't save item data." 
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }    
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)valueChanged:(id)sender {
    [self save];
}

- (IBAction)clearDate:(id)sender {
    self.deadline.text = nil;
    self.userDeadline = nil;
    curTask.deadline = nil;
    [self.deadline resignFirstResponder];    
}

- (IBAction)datePickerChanged:(id)sender {
    UIDatePicker*picker = (UIDatePicker*)sender;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    self.userDeadline = picker.date;
    [formatter setDateFormat:@"dd MMMM' at 'hh:mm a"];
    self.deadline.text = [formatter stringFromDate:picker.date];
    
    [formatter release];
}

- (IBAction)remove:(id)sender {
    UIActionSheet * popup = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this task ?" delegate:self cancelButtonTitle:@"Cancel" 
                                          destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    
    //[popup showFromToolbar:self.toolBar];
    [popup showInView:[[UIApplication sharedApplication] keyWindow]];
    [popup release];
}

- (IBAction)mail:(id)sender {
    if (![MFMailComposeViewController canSendMail]){
        return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM' at 'hh:mm a"];
    NSString * body;
    if (self.curTask.completionDate){
        body = [NSString stringWithFormat:@"Task details\n\n%@\n\nPriority: %@\nCreated: %@\nDeadline: %@\nCompleted: %@\n", 
                self.name.text, [self.priority titleForSegmentAtIndex:self.priority.selectedSegmentIndex], 
                [formatter stringFromDate:self.curTask.creationDate], self.deadline.text, [formatter stringFromDate:self.curTask.completionDate]];
    }else {
        body = [NSString stringWithFormat:@"Task details\n\n%@\n\nPriority: %@\nCreated: %@\nDeadline: %@\n", 
                self.name.text, [self.priority titleForSegmentAtIndex:self.priority.selectedSegmentIndex], 
                [formatter stringFromDate:self.curTask.creationDate], self.deadline.text];
    }
    NSString * subject = @"Task";
    
    [controller setSubject:subject];
    [controller setMessageBody:body isHTML:NO];
    
    [self presentModalViewController:controller animated:YES];
    
    [formatter release];
    [controller release];
}

#pragma mark -
#pragma mark MailComposer delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.destructiveButtonIndex == buttonIndex){
        [objContext deleteObject:self.curTask];
        
        NSError *error;
        if (![objContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't delete task item." 
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    
}


#pragma mark -
#pragma mark Text/Field View delegate


- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:textView
                                                                                action:@selector(resignFirstResponder)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
    [self save];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:textField
                                                                                action:@selector(resignFirstResponder)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(clearDate:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = clearButton;
    
    [clearButton release];
    [doneButton release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    [self save];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength < TASK_NAME_MAX) ? YES : NO;    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [objContext release];
    [name release];
    [priority release];
    [deadline release];
    [toolBar release];
    
    [super dealloc];
}


@end
