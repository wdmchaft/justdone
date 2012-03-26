//
//  JustDoneAppDelegate.m
//  JustDone
//
//  Created by elian on 29/02/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "JustDoneAppDelegate.h"
#import "Tasks.h"
#import "Reminder.h"
#import "Reminders.h"

@implementation JustDoneAppDelegate

@synthesize window, tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch.    
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context){
        return YES;
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"cacheTodo"];
    [NSFetchedResultsController deleteCacheWithName:@"cacheDone"];

    Tasks* controller = [[Tasks alloc] initWithNibName:@"Tasks" bundle:nil];
    Reminders* controller2 = [[Reminders alloc] initWithNibName:@"Reminders" bundle:nil];
    
    controller.objContext = context;
    controller2.objContext = context;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:controller2];

    UITabBarItem * bar = [[UITabBarItem alloc] initWithTitle:@"Tasks" image:[UIImage imageNamed:@"tasks.png"] tag:0];
    UITabBarItem * bar2 = [[UITabBarItem alloc] initWithTitle:@"Reminders" image:[UIImage imageNamed:@"calendar.png"] tag:1];
    
    nav.tabBarItem = bar;
    nav2.tabBarItem = bar2;
    
    NSArray* controllers = [NSArray arrayWithObjects:nav, nav2, nil];

    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = controllers;
    
    [[tabBarController view] setFrame:[[UIScreen mainScreen] applicationFrame]];
    
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
    [controller release];
    [controller2 release];
    [nav release];
    [nav2 release];
    [bar release];
    [bar2 release];
    
	return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Called when application is in foreground or when the user clicks the Action button in alert notification window.
    // You can use [[UIApplication sharedApplication] scheduledLocalNotifications] to get the complete list of scheduled notifications.
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    Reminders * controller = (Reminders*) [[[tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    application.applicationIconBadgeNumber = [controller numberOfReminders];

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSUInteger count = [controller tomorrowNumberOfReminders];
    if (count == 0)
        return;
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [Reminder nextDayFromDate:[NSDate date]];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = nil;
    localNotif.alertAction = nil;
    localNotif.userInfo = nil;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = count;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    Reminders * controller = (Reminders*) [[[tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    [controller numberOfReminders];
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't save application data." 
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"JustDone" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"JustDone.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:@"Couldn't read application data, press the Home button to quit." 
                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [persistentStoreCoordinator_ release];
        persistentStoreCoordinator_ = nil;
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    
    [NSFetchedResultsController deleteCacheWithName:@"cacheTodo"];
    [NSFetchedResultsController deleteCacheWithName:@"cacheDone"];
    
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [tabBarController release];
    [window release];
    [super dealloc];
}


@end

