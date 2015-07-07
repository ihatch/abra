//
//  ABApprentice.m
//  Abra
//
//  Created by Ian Hatcher on 7/5/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABApprentice.h"
#import "ABConstants.h"
#import "ABData.h"

@implementation ABApprentice

NSArray *spells;
NSDictionary *wordsDict;

- (id) init {
    if(self = [super init]) {
        [self parseConstants];
        [self parseOdds];
    }
    return self;
}


- (void) parseConstants {
    wordsDict = @{
        @"WORDS_DONE_HERE": [WORDS_DONE_HERE componentsSeparatedByString:@" "],
        @"WORDS_SPEAK": [WORDS_SPEAK componentsSeparatedByString:@" "],
        @"WORDS_COLOR_BARS": [WORDS_COLOR_BARS componentsSeparatedByString:@" "],
        @"WORDS_ATTENTION": [WORDS_ATTENTION componentsSeparatedByString:@" "],
        @"WORDS_SYNC_RATES": [WORDS_SYNC_RATES componentsSeparatedByString:@" "],
        @"WORDS_NETWORK": [WORDS_NETWORK componentsSeparatedByString:@" "],
        @"WORDS_PYTHON": [WORDS_PYTHON componentsSeparatedByString:@" "],
        @"WORDS_PERIMETER": [WORDS_PERIMETER componentsSeparatedByString:@" "],
        @"WORDS_STING": [WORDS_STING componentsSeparatedByString:@" "]
    };
    
}


- (void) parseOdds {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spellOdds" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *rawSpells = [rawText componentsSeparatedByString:@"\n"];
    NSMutableArray *allSpells = [NSMutableArray array];
    
    for(NSString *string in rawSpells) {
        if([string isEqualToString:@""]) continue;
        NSArray *splitSpell = [string componentsSeparatedByString:@" | "];
        NSString *spellName = [splitSpell objectAtIndex:0];
        int spellCount = [[splitSpell objectAtIndex:1] intValue];
        for(int i = 0; i < spellCount; i ++) {
            [allSpells addObject:spellName];
        }
    }
    
    spells = [NSArray arrayWithArray:allSpells];

}


- (NSString *)randomSpell {
    return [spells objectAtIndex:(arc4random() % [spells count])];
}





- (NSString *) randomStringFrom:(NSString *)source {
    NSArray *array = [wordsDict objectForKey:source];
    NSUInteger randomIndex = arc4random() % [array count];
    return [array objectAtIndex:randomIndex];
}

- (ABScriptWord *) randomSWFrom:(NSString *)source {
    return [ABData getScriptWordAndRunChecks:[self randomStringFrom:source]];
}




@end

