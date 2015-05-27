//
//  ABAppDelegate.m
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABClock.h"
#import "ABMainViewController.h"

@implementation ABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Preloads keyboard so there's no lag on initial keyboard appearance.
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    
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
