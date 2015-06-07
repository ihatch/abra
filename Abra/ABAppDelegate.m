//
//  ABAppDelegate.m
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

//#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ABAppDelegate.h"
#import "ABClock.h"
#import "ABMainViewController.h"

@implementation ABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // CocoaLumberjack init
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    
//    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
//    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    
//    [DDLog addLogger:fileLogger];

    // Preloads keyboard so there's no lag on initial keyboard appearance.
    NSLog(@"Keyboard loading ...");
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    NSLog(@"Keyboard loaded.");
    
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
