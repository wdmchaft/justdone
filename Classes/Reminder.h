//
//  Reminder.h
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#define REMINDER_NAME_MAX 512

@interface Reminder :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * reminderAfter;
@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * reminderName;
@property (nonatomic, retain) NSString * name;

+ (NSDate*) nextMondayFromDate:(NSDate*)date;
+ (NSDate*) nextMonthFromDate:(NSDate*)date;
+ (NSDate*) nextDayFromDate:(NSDate*)date;

@end



