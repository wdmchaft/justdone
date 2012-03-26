//
//  RemindersDetail.m
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import "RemindersDetail.h"
#import <QuartzCore/QuartzCore.h>


@implementation RemindersDetail

@synthesize objContext, priority, repeat, name, curReminder, toolBar;

#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        self.toolBar.hidden = YES;
    
    self.navigationItem.title = @"Details";
    
    name.text = curReminder.name;
    repeat.selectedSegmentIndex = [curReminder.reminder intValue];
    priority.selectedSegmentIndex = [curReminder.priority intValue];
    name.layer.cornerRadius = 5;
    name.clipsToBounds = YES;
    
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        self.toolBar.hidden = YES;
    else
        self.toolBar.hidden = NO;
}

#pragma mark -
#pragma mark Custom procedures

- (void)save {    
    Reminder * reminder = self.curReminder;
    
    if ([self.name.text length] > 0){
        reminder.name = self.name.text;
    }else {
        self.name.text = reminder.name;
    }
    
    reminder.priority = [NSNumber numberWithInteger:self.priority.selectedSegmentIndex];
    if (repeat.selectedSegmentIndex != [reminder.reminder intValue]) {
        reminder.reminderAfter = [NSDate dateWithTimeIntervalSince1970:1];
    }
    reminder.reminder = [NSNumber numberWithInteger:self.repeat.selectedSegmentIndex];
    
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

- (IBAction)remove:(id)sender {
    UIActionSheet * popup = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this reminder ?" delegate:self cancelButtonTitle:@"Cancel" 
                                          destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    
    //[popup showFromToolbar:self.toolBar];
    [popup showInView:[[UIApplication sharedApplication] keyWindow]];
    [popup release];
}

- (IBAction)valueChanged:(id)sender {
    [self save];
}


#pragma mark -
#pragma mark ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.destructiveButtonIndex == buttonIndex){
        [objContext deleteObject:self.curReminder];
        
        NSError *error;
        if (![objContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't delete reminder item." 
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength < REMINDER_NAME_MAX) ? YES : NO;    
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
    [priority release];
    [name release];
    [repeat release];
    [toolBar release];
    
    [super dealloc];
}


@end
