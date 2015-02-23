//
//  ABMatch.m
//  Abra
//
//  Created by Ian Hatcher on 12/12/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABMatch.h"
#import "ABScriptWord.h"

@implementation ABMatch {

    NSMutableArray *past;
    NSMutableArray *future;
    NSMutableArray *pastSet;
    NSMutableArray *solvedSet;
    
    NSMutableDictionary *wordLocations;
    NSMutableDictionary *pastLocations;
    NSMutableDictionary *futureLocations;
}


- (id) init {
    if(self = [super init]) {
        
        wordLocations = [[NSMutableDictionary alloc] init];
        [wordLocations setObject:[[NSMutableDictionary alloc] init] forKey:@"past"];
        [wordLocations setObject:[[NSMutableDictionary alloc] init] forKey:@"future"];
        
        pastLocations = [wordLocations objectForKey:@"past"];
        futureLocations = [wordLocations objectForKey:@"future"];
    }

    return self;
}


- (NSMutableArray *) matchWithPast:(NSArray *)pastArray andFuture:(NSArray *)futureArray {
    
    // If no past, this process doesn't need to run
    if([pastArray count] == 0) return nil;

    past = [NSMutableArray arrayWithArray:pastArray];
    future = [NSMutableArray arrayWithArray:futureArray];

    
    // Eliminate all non-matching words, but keep indicies intact
    for(int i=(int)[past count] - 1; i >= 0; i --) {
        if(![future containsObject:past[i]]) {
            [past replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    for(int i=(int)[future count] - 1; i >= 0; i --) {
        if(![past containsObject:future[i]]) {
            [future replaceObjectAtIndex:i withObject:@""];
        }
    }

    // Create empty solution set to be filled
    solvedSet = [[NSMutableArray alloc] initWithCapacity:[future count]];
    for(int i=0, l=(int)[future count]; i < l; i ++){
        [solvedSet addObject:@(-1)];
    }
    
    // Create set to store data about past words
    pastSet = [[NSMutableArray alloc] initWithCapacity:[past count]];
    
    // Get locations of all multiple words
    [self addToWordLocations:past forCategory:@"past"];
    [self addToWordLocations:future forCategory:@"future"];
    
    [self processPast];
    [self solveForObviousMatches];
    [self solveForRemainingPositions];
    return solvedSet;
}


- (void) addToWordLocations:(NSArray *)words forCategory:(NSString *)category {
    
    for(int i=0, l=(int)[words count]; i < l; i ++){
        
        NSString *word = [words objectAtIndex:i];
        if([word isEqualToString:@""]) continue;
        
        NSMutableDictionary *c = [wordLocations objectForKey:category];
        if(![c objectForKey:word]) {
            [c setObject:[[NSMutableArray alloc] init] forKey:word];
        }
        
        NSMutableArray *a = [c objectForKey:word];
        [a addObject:@(i)];
    }
}


- (void) processPast {
    
    NSMutableArray *left = [[NSMutableArray alloc] init];
    NSMutableArray *right = [[NSMutableArray alloc] init];
    
    for(int i=0, l=(int)[past count]; i < l; i ++){
        
        NSString *text = past[i];
        
        // Ignore removed non-matching word locations
        if([text isEqualToString:@""]) {
            [pastSet addObject:[NSNull null]];
            continue;
        }
        
        // Create array for this word, containing all other words to its left
        NSArray *aLeft = [NSArray arrayWithArray:left];
        [left addObject:@(i)];
        
        // New pastSet object
        NSMutableDictionary *aWord = [NSMutableDictionary dictionaryWithDictionary:@{@"index" : @(i),
                                                                                     @"text" : text,
                                                                                     @"left" : aLeft}];
        [pastSet addObject:aWord];
    }
    

    // Create array for each word, containing all other words to its right
    for(int i = (int)[pastSet count] - 1; i >= 0; i --) {
        if([[pastSet objectAtIndex:i] isKindOfClass:[NSNull class]]) continue;
        NSArray *aRight = [NSArray arrayWithArray:right];
        [[pastSet objectAtIndex:i] setObject:aRight forKey:@"right"];
        [right addObject:[[pastSet objectAtIndex:i] valueForKey:@"index"]];
    }
}


- (void) solveForObviousMatches {
    
    for(int i = (int)[pastSet count] - 1; i >= 0; i --) {
        
        if([[pastSet objectAtIndex:i] isKindOfClass:[NSNull class]]) continue;
        
        NSString *text = [[pastSet objectAtIndex:i] objectForKey:@"text"];
        NSMutableArray *pastLocsArray = [pastLocations objectForKey:text];
        NSMutableArray *futureLocsArray = [futureLocations objectForKey:text];
        
        // Match 1-to-1 correspondences and remove from arrays of words to match
        if([pastLocsArray count] == 1 && [futureLocsArray count] == 1) {
            [solvedSet replaceObjectAtIndex:[[futureLocsArray objectAtIndex:0] intValue] withObject:[pastLocsArray objectAtIndex:0]];
            [pastLocations removeObjectForKey:text];
            [futureLocations removeObjectForKey:text];
        }
    }

}


// Get a list of all known (solved-for) words to the left of given position
- (NSArray *) solvedIDsToLeftOfPosition:(int)i {
    NSMutableArray *known = [[NSMutableArray alloc] init];
    for(int f = i-1; f > -1; f --) {
        int fi = [[solvedSet objectAtIndex:f] intValue];
        if(fi != -1) [known addObject:[solvedSet objectAtIndex:f]];
    }
    return (NSArray *) known;
}


// Get a list of all known (solved-for) words to the right of given position
- (NSArray *) solvedIDsToRightOfPosition:(int)i {
    NSMutableArray *known = [[NSMutableArray alloc] init];
    for(int f = i+1; f < [solvedSet count]; f ++) {
        int fi = [[solvedSet objectAtIndex:f] intValue];
        if(fi != -1) [known addObject:[solvedSet objectAtIndex:f]];
    }
    return (NSArray *) known;
}


// Determine score based on matched elements between arrays
- (int) intersectionScoreForArray:(NSArray *)array1 andArray:(NSArray *)array2 {
    
    NSMutableSet *set1 = [NSMutableSet setWithArray: array1];
    NSSet *set2 = [NSSet setWithArray: array2];
    [set1 intersectSet: set2];
    NSArray *resultArray = [set1 allObjects];
    return (int)[resultArray count];
}


// Find best match for a word (of remaining options)
- (NSDictionary *) findBestMatchForWord:(NSString *)key inPast:(NSMutableArray *)pastPositions andFuture:(NSMutableArray *)futurePositions {
    
    int bestScore = -1;
    int bestPast = -1;
    int bestFuture = -1;
    
    for(int p = 0; p < [pastPositions count]; p ++) {
        
        int pastPos = [[pastPositions objectAtIndex:p] intValue];

        for(int f = 0; f < [futurePositions count]; f++) {
            
            int futurePos = [[futurePositions objectAtIndex:f] intValue];
            
            NSArray *knownLeft = [self solvedIDsToLeftOfPosition:futurePos];
            NSArray *knownRight = [self solvedIDsToRightOfPosition:futurePos];
            NSMutableDictionary *pastObject = [pastSet objectAtIndex:pastPos];
            
            int s1 = [self intersectionScoreForArray:knownLeft andArray:[pastObject objectForKey:@"left"]];
            int s2 = [self intersectionScoreForArray:knownRight andArray:[pastObject objectForKey:@"right"]];
            
            int score = s1 + s2;
            
            if(score > bestScore) {
                bestScore = score;
                bestPast = p;
                bestFuture = f;
            }
        }
    }

    return @{@"p" : [NSNumber numberWithInt:bestPast],
             @"f" : [NSNumber numberWithInt:bestFuture],
             @"pLoc" : [pastPositions objectAtIndex:bestPast],
             @"fLoc" : [futurePositions objectAtIndex:bestFuture]};
}


- (void) solveForRemainingPositions {
    
    for (NSString *key in pastLocations) {

        NSMutableArray *pastLocs = [pastLocations objectForKey:key];
        NSMutableArray *futureLocs = [futureLocations objectForKey:key];

        // Find how many matches?
        int matchesToFind = (int)[pastLocs count];
        if([futureLocs count] < matchesToFind) matchesToFind = (int)[futureLocs count];

        for(int i=0; i<matchesToFind; i++) {
            
            NSDictionary *match = [self findBestMatchForWord:key inPast:pastLocs andFuture:futureLocs];
            
            int p = [[match objectForKey:@"p"] intValue];
            int f = [[match objectForKey:@"f"] intValue];
            NSNumber *pLoc = [match objectForKey:@"pLoc"];
            NSNumber *fLoc = [match objectForKey:@"fLoc"];
            
            [solvedSet replaceObjectAtIndex:[fLoc intValue] withObject:@([pLoc intValue])];

            [pastLocs removeObjectAtIndex:p];
            [futureLocs removeObjectAtIndex:f];
        }
    }
}

@end
