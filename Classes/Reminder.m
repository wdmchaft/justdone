// 
//  Reminder.m
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Reminder.h"


@implementation Reminder 

@dynamic reminderAfter;
@dynamic reminder;
@dynamic creationDate;
@dynamic priority;
@dynamic reminderName;
@dynamic name;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.creationDate = [NSDate date];
    self.name = @"New Reminder";
    self.priority = [NSNumber numberWithInt:1];
    self.reminderAfter = [NSDate dateWithTimeIntervalSince1970:1];
}

- (NSString *) reminderName {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"]; 
    NSArray * rems = [NSArray arrayWithObjects:@"Today",@"This week",[formatter stringFromDate:[NSDate date]],nil];
    [self willAccessValueForKey:@"reminder"];
    NSString * name = [rems objectAtIndex:[self.reminder intValue]];
    [self didAccessValueForKey:@"reminder"];
    [formatter release];
    return name;
}

+ (NSDate*) nextMondayFromDate:(NSDate*)date {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit;
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
    if (components.weekday == 1){
        [components setDay:components.day+1];
    }else {
        [components setDay:components.day+(9-components.weekday)];    
    }
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) nextMonthFromDate:(NSDate*)date {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];  
    [components setMonth:components.month+1];
    return [gregorian dateFromComponents:components];
}

+ (NSDate*) nextDayFromDate:(NSDate*)date {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];  
    [components setDay:components.day+1];
    return [gregorian dateFromComponents:components];
}

@end
