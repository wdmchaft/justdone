//
//  LocalNotifier.h
//  JustDone
//
//  Created by elian on 16/03/12.
//  Copyright 2012 GEGidoni. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocalNotifier : NSObject {

}

+ (LocalNotifier*)sharedNotifier;

+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (NSUInteger)retainCount;
- (void)release;
- (id)autorelease;


@end
