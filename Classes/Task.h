//
//  Task.h
//  JustDone
//
//  Created by elian on 18/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#define TASK_NAME_MAX 512

@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * deadline;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * priorityName;


@end



