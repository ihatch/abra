//
//  ABApprentice.m
//  Abra
//
//  Created by Ian Hatcher on 7/5/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABApprentice.h"
#import "ABConstants.h"
#import "ABScriptWord.h"
#import "ABMutate.h"
#import "ABEmoji.h"
#import "ABData.h"
#import "ABLine.h"
#import "ABState.h"
#import "NSString+ABExtras.h"


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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spell_odds" ofType:@"txt"];
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


// --------------------------------------------------------------------------------


/////////////
// RANDOMS //
/////////////

- (NSString *) randomStringFrom:(NSString *)source {
    NSArray *array = [wordsDict objectForKey:source];
    NSUInteger randomIndex = arc4random() % [array count];
    return [array objectAtIndex:randomIndex];
}

- (ABScriptWord *) randomSWFrom:(NSString *)source {
    return [ABData getScriptWordAndRunChecks:[self randomStringFrom:source]];
}

- (int) rndIndex:(NSArray *)array {
    return (int)(arc4random() % [array count]);
}






//////////////
// SEARCHES //
//////////////

- (BOOL) searchLines:(NSArray *)lines forWord:(NSString *)word {
    for(NSArray *line in lines) {
        for(ABScriptWord *w in line) {
            if([w.text isEqualToString:word]) return YES;
        }
    }
    return NO;
}

- (NSArray *) locationsOfGraftsIn:(NSArray *)SWArray {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[SWArray count]; i ++) {
        ABScriptWord *sw = [SWArray objectAtIndex:i];
        if(sw.isGrafted) [locs addObject:@(i)];
    }
    return locs;
}

- (NSArray *) locationsOfEmojiIn:(NSArray *)SWArray {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[SWArray count]; i ++) {
        ABScriptWord *sw = [SWArray objectAtIndex:i];
        if(sw.emojiCount > 0) [locs addObject:@(i)];
    }
    return locs;
}

- (NSArray *) locationsOfMutationsIn:(NSArray *)SWArray {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[SWArray count]; i ++) {
        ABScriptWord *sw = [SWArray objectAtIndex:i];
        if(sw.morphCount > 0) [locs addObject:@(i)];
    }
    return locs;
}





//////////
// MAPS //
//////////

- (NSArray *) mapWithOddsFrom:(CGFloat)startOdds to:(CGFloat)endOdds total:(int)totalItems min:(int)min max:(int)max {
    
    if(max > totalItems) DDLogError(@"ERROR: Bad counting!");
    int total = max - min;
    CGFloat oddsSpread = endOdds - startOdds;
    CGFloat oddsIncrement = oddsSpread / total;
    CGFloat threshold = startOdds;
    NSMutableArray *map = [NSMutableArray array];
    
    for(int i = 0; i < totalItems; i ++) {
        if(i < min || i > max) {
            [map addObject:@(NO)];
            continue;
        }
        threshold += oddsIncrement;
        if(ABF(1.0f) < threshold) [map addObject:@(YES)];
        else [map addObject:@(NO)];
    }
    
    return [NSArray arrayWithArray:map];
}




- (NSArray *) fullMapWithPercent:(CGFloat)percent andStanzaLines:(NSArray *)lines {
    
    int totalWords = 0;
    for(NSArray *line in lines) totalWords += [line count];
    int numYes = (int)floor(totalWords * percent);

    NSMutableArray *map = [NSMutableArray array];
    for(int i=0; i<totalWords; i++) [map addObject:@(NO)];
    
    int placed = 0;
    
    while(placed < numYes) {
        int x = arc4random_uniform(totalWords);
        if([[map objectAtIndex:x] boolValue] == NO) {
            [map replaceObjectAtIndex:x withObject:@(YES)];
            placed ++;
        }
    }
    
    return [NSArray arrayWithArray:map];
}

- (NSArray *) fullMapWithPercent:(CGFloat)percent andABLines:(NSArray *)lines {
    
    int totalWords = 0;
    for(ABLine *line in lines) totalWords += [line.lineWords count];
    int numYes = (int)floor(totalWords * percent);
    
    NSMutableArray *map = [NSMutableArray array];
    for(int i=0; i<totalWords; i++) [map addObject:@(NO)];
    
    int placed = 0;
    
    while(placed < numYes) {
        int x = arc4random_uniform(totalWords);
        if([[map objectAtIndex:x] boolValue] == NO) {
            [map replaceObjectAtIndex:x withObject:@(YES)];
            placed ++;
        }
    }
    
    return [NSArray arrayWithArray:map];
}





///////////
// COLOR //
///////////

- (int) averageSourceStanzas:(ABScriptWord *)sw1 and:(ABScriptWord *)sw2 {
    int ss1 = (sw1 != nil) ? sw1.sourceStanza : [ABState getCurrentStanza];
    int ss2 = (sw2 != nil) ? sw2.sourceStanza : [ABState getCurrentStanza];
    return floor((ss2 + ss1) / 2);
}






//////////////////
// ARRAY SPLITS //
//////////////////

- (NSArray *) splitArrayInHalf:(NSArray *)wholeArray {
    NSArray *firstHalfOfArray;
    NSArray *secondHalfOfArray;
    NSRange someRange;
    
    someRange.location = 0;
    someRange.length = [wholeArray count] / 2;
    firstHalfOfArray = [wholeArray subarrayWithRange:someRange];
    someRange.location = someRange.length;
    someRange.length = [wholeArray count] - someRange.length;
    secondHalfOfArray = [wholeArray subarrayWithRange:someRange];
    return @[firstHalfOfArray, secondHalfOfArray];
}


- (NSArray *) splitParagraphIntoLinesOfScriptWords:(NSString *)paragraph {
    
    NSArray *lines = [paragraph componentsSeparatedByString:@"\n"];
    NSMutableArray *newLines = [NSMutableArray array];
    
    for(NSString *line in lines) {
        NSArray *words = [line componentsSeparatedByString:@" "];
        NSMutableArray *newWords = [NSMutableArray array];
        for(NSString *w in words) {
            ABScriptWord *sw = [ABData scriptWord:w stanza:-1 fam:words leftSis:nil rightSis:nil graft:NO check:NO];
            [newWords addObject:sw];
        }
        [newLines addObject:newWords];
    }
    return [NSArray arrayWithArray:newLines];
}






//////////////////
// SCRIPT WORDS //
//////////////////


- (ABScriptWord *) swEmojiForConcept:(NSString *)concept {
    return [ABData getScriptWordAndRunChecks:[ABEmoji getRandomEmojiStringWithConcept:concept]];
}

- (ABScriptWord *) swWordFromString:(NSString *)string {
    NSArray *arr = [string componentsSeparatedByString:@" "];
    NSUInteger randomIndex = arc4random() % [arr count];
    return [ABData getScriptWordAndRunChecks:[arr objectAtIndex:randomIndex]];
}

- (ABScriptWord *) swCharFromString:(NSString *)string {
    NSArray *arr = [string convertToArray];
    NSUInteger randomIndex = arc4random() % [arr count];
    return [ABData getScriptWordAndRunChecks:[arr objectAtIndex:randomIndex]];
}

- (ABScriptWord *) swSymbol {
    NSArray *arr = [@"ੴ ௬ ༆ ༀ" componentsSeparatedByString:@" "];
    NSUInteger randomIndex = arc4random() % [arr count];
    return [ABData getScriptWordAndRunChecks:[arr objectAtIndex:randomIndex]];
}



// "before" only used for sourceStanza avg
- (NSArray *) swInsert:(ABScriptWord *)sw0 after:(ABScriptWord *)sw1 before:(ABScriptWord *)sw2 {
    int ss = [self averageSourceStanzas:sw1 and:sw2];
    sw0.sourceStanza = ss;
    return @[sw1, sw0];
}


// "before" only used for sourceStanza avg
- (NSArray *) swReplace:(ABScriptWord *)sw0 after:(ABScriptWord *)sw1 before:(ABScriptWord *)sw2 {
    int ss = [self averageSourceStanzas:sw1 and:sw2];
    if(!sw0.hasRunChecks) [sw0 runChecks];
    sw0.sourceStanza = ss;
    return @[sw0];
}









///////////////////
// MASS MUTATION //
///////////////////

- (NSArray *) mutateMultipleWordsInLine:(NSArray *)line withMap:(NSArray *)map {
    
    if([map count] != [line count]) {
        DDLogError(@"count mismatch!");
    }
    
    NSMutableArray *newLine = [NSMutableArray array];
    
    int i = 0;
    for(ABScriptWord *sw in line) {

        // pass over this spot
        if([[map objectAtIndex:i] boolValue] == NO) {
            [newLine addObject:sw];
            
        
        } else {
            if(ABI(10) > 1) {
                NSArray *new = [ABMutate mutateWord:sw inLine:line];
                [newLine addObjectsFromArray:new];
            }
        }
        i ++;
    }
    
    return [NSArray arrayWithArray:newLine];
}





@end

