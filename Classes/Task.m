// 
//  Task.m
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Task.h"


@implementation Task 

@dynamic name;
@dynamic completionDate;
@dynamic creationDate;
@dynamic deadline;
@dynamic done;
@dynamic priority;
@dynamic priorityName;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.creationDate = [NSDate date];
    self.name = @"New Task";
    self.priority = [NSNumber numberWithInt:1];
}

- (NSString *) priorityName {
    NSArray * prios = [NSArray arrayWithObjects:@"Low Priority",@"Normal Priority",@"High Priority",nil];
    [self willAccessValueForKey:@"priority"];
    NSString * name = [prios objectAtIndex:[self.priority intValue]];
    [self didAccessValueForKey:@"priority"];
    return name;
}

@end
