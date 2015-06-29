//
//  ABHistory.m
//  Abra
//
//  Created by Ian Hatcher on 6/28/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABHistory.h"

@implementation ABHistory

NSUserDefaults *defaults;

#pragma mark Singleton Methods

+ (id) history {
    static ABHistory *history = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ history = [[self alloc] init]; });
    return history;
}


- (id)init {
    if (self = [super init]) {
        defaults = [NSUserDefaults standardUserDefaults];
        
        self.mutateCount = (int)[defaults integerForKey:@"mutateCount"];
        self.cadabraCount = (int)[defaults integerForKey:@"cadabraCount"];
        self.shareCount = (int)[defaults integerForKey:@"shareCount"];
        self.eraseCount = (int)[defaults integerForKey:@"eraseCount"];
        self.pruneCount = (int)[defaults integerForKey:@"pruneCount"];
        self.graftCount = (int)[defaults integerForKey:@"graftCount"];
        self.magicTapCount = (int)[defaults integerForKey:@"magicTapCount"];
    }

    return self;
}


- (void) setMutateCount:(int)count {
    _mutateCount = count;
    [defaults setInteger:count forKey:@"mutateCount"];
    [defaults synchronize];
}

- (void) setCadabraCount:(int)count {
    _cadabraCount = count;
    [defaults setInteger:count forKey:@"cadabraCount"];
    [defaults synchronize];
}

- (void) setShareCount:(int)count {
    _shareCount = count;
    [defaults setInteger:count forKey:@"shareCount"];
    [defaults synchronize];
}

- (void) setEraseCount:(int)count {
    _eraseCount = count;
    [defaults setInteger:count forKey:@"eraseCount"];
    [defaults synchronize];
}

- (void) setPruneCount:(int)count {
    _pruneCount = count;
    [defaults setInteger:count forKey:@"pruneCount"];
    [defaults synchronize];
}

- (void) setGraftcount:(int)count {
    _graftCount = count;
    [defaults setInteger:count forKey:@"graftCount"];
    [defaults synchronize];
}

- (void) setMagicTapCount:(int)count {
    _magicTapCount = count;
    [defaults setInteger:count forKey:@"cadabraCount"];
    [defaults synchronize];
}



@end
