//
//  ABAppDelegate.m
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABAppDelegate.h"
#import "TestFlight.h"
#import "ABState.h"
#import "ABClock.h"

@implementation ABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TestFlight takeOff:@"d6dae9b3-9270-4c46-a601-8900e5ebd4fc"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [ABClock deactivate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [ABClock reactivate];
}

- (void)applicationWillTerminate:(UIApplication *)application {}

@end
