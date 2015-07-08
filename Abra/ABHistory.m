//
//  ABHistory.m
//  Abra
//
//  Created by Ian Hatcher on 6/28/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABHistory.h"
#import "ABConstants.h"

@implementation ABHistory

NSUserDefaults *defaults;
NSMutableArray *currentGesture;
NSMutableDictionary *counts;

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
        counts = [NSMutableDictionary dictionary];

        // Track shares and longpress - TODO
        int mutate = (int)[defaults integerForKey:[NSString stringWithFormat:@"spellCount-%i", (int)(SpellMode)MUTATE]];
        int cadabra = (int)[defaults integerForKey:[NSString stringWithFormat:@"spellCount-%i", (int)(SpellMode)MAGIC]];
        int erase = (int)[defaults integerForKey:[NSString stringWithFormat:@"spellCount-%i", (int)(SpellMode)ERASE]];
        int prune = (int)[defaults integerForKey:[NSString stringWithFormat:@"spellCount-%i", (int)(SpellMode)PRUNE]];
        int graft = (int)[defaults integerForKey:[NSString stringWithFormat:@"spellCount-%i", (int)(SpellMode)GRAFT]];
        
        [counts setObject:@(mutate) forKey:@((SpellMode)MUTATE)];
        [counts setObject:@(graft) forKey:@((SpellMode)GRAFT)];
        [counts setObject:@(erase) forKey:@((SpellMode)ERASE)];
        [counts setObject:@(prune) forKey:@((SpellMode)PRUNE)];
        [counts setObject:@(cadabra) forKey:@((SpellMode)MAGIC)];

        DDLogInfo(@"<#> History :: %i %i %i %i %i", mutate, graft, erase, prune, cadabra);
    }

    return self;
}



- (void) record:(SpellMode)mode line:(int)line index:(int)index {
    [self increment:mode];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
//    DDLogInfo(@"RECORD: %f %li %i %i", timeStamp, (long)mode, line, index);
    
}



- (void) increment:(SpellMode *)mode {
    NSInteger current = [counts objectForKey:@((SpellMode)mode)];
    current ++;
    [counts setObject:@(current) forKey:@((SpellMode)mode)];
    [defaults setInteger:current forKey:[NSString stringWithFormat:@"spellCount-%i", (int)(SpellMode)mode]];
    [defaults synchronize];
}


- (void) startGesture {
    
}

- (void) recordGraft:(NSString *)text onLine:(int)line atIndex:(int)index {
    // NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    
}

- (void) endGesture {
    
}








@end
