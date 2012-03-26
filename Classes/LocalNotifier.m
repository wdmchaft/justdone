//
//  LocalNotifier.m
//  JustDone
//
//  Created by elian on 16/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import "LocalNotifier.h"


@implementation LocalNotifier

static LocalNotifier * sharedNotifier = nil;

+ (LocalNotifier*)sharedNotifier
{
    if (sharedNotifier == nil) {
        sharedNotifier = [[super allocWithZone:NULL] init];
    }
    return sharedNotifier;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedNotifier] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
