//
//  ABCadabra.m
//  Abra
//
//  Created by Ian Hatcher on 6/9/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABCadabra.h"
#import "ABConstants.h"
#import "ABState.h"
#import "ABData.h"
#import "ABDice.h"
#import "ABMutate.h"
#import "ABScriptWord.h"
#import "ABWord.h"
#import "ABLine.h"
#import "ABEmoji.h"
#import "ABScript.h"
#import "ABHistory.h"
#import "ABApprentice.h"

@interface NSString (ConvertToArray)
- (NSArray *) convertToArray;
@end
@implementation NSString (ConvertToArray)
- (NSArray *) convertToArray {
    NSMutableArray *arr = [NSMutableArray array];
    NSUInteger i = 0;
    while (i < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *chStr = [self substringWithRange:range];
        [arr addObject:chStr];
        i += range.length;
    }
    return arr;
}
@end

@interface NSMutableArray (Shuffling)
- (void) shuffle;
@end
@implementation NSMutableArray (Shuffling)
- (void) shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}
@end




// ----------------------------------------------------------------------------------------

typedef NS_ENUM(NSInteger, areaType) {
    AREA_TOP, AREA_BOTTOM, AREA_LEFT, AREA_RIGHT, AREA_INNER, AREA_OUTER, AREA_RANDOM
};


@implementation ABCadabra

NSArray *ABLines, *stanzaLines;
NSMutableArray *stringLines, *allStrings;
ABHistory *history;
ABApprentice *apprentice;


+ (void) castSpell:(NSString *)spell withMagicWord:(NSString *)magicWord {
    
    if(apprentice == nil) apprentice = [[ABApprentice alloc] init];
    if(history == nil) history = [ABHistory history];
    [history record:MAGIC line:-1 index:-1];

    
    ABLines = [ABState getLines];
    stanzaLines = [ABState getCurrentScriptWordLines];
    stringLines = [NSMutableArray array];
    allStrings = [NSMutableArray array];
    
    int hasFamilyCount = 0;
    int hasEmojiCount = 0;
    int mutatedCount = 0;
    int graftedCount = 0;
    int visibleCount = 0;
    int totalWordCount = 0;
    
    
//    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    
    for(ABLine *line in ABLines) {
        
        NSMutableArray *stringLine = [NSMutableArray array];
        int swlen = (int)[line.lineScriptWords count];
        
        for(int i = 0; i < swlen; i ++) {
            
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            ABWord *w = [line.lineWords objectAtIndex:i];
            
            BOOL visible = (w.isErased == NO);
            
            [allStrings addObject:sw.text];
            [stringLine addObject:sw.text];
            
//            analysis = [ABCadabra analyzeLines];
            
            if(sw.hasFamily) hasFamilyCount ++;
            if(visible && sw.emojiCount > 0) hasEmojiCount ++;
            if(visible && sw.morphCount > 0) mutatedCount ++;
            if(visible && sw.isGrafted == YES) graftedCount ++;
            if(visible) visibleCount ++;
            totalWordCount ++;
        }
        [stringLines addObject:stringLine];
    }

    
    BOOL inSpaceyMode = [ABState checkSpaceyMode];

    // check for conditions like all erased, etc.
    
    

    // SPECIFIC SPELL
    if(spell != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerCadabra" object:self];
        
        
    // RANDOM SPELL
    } else {
        
        if(inSpaceyMode && ABI(12) < 5) [ABState setSpaceyMode:NO];
        
        BOOL ok = NO;
        NSString *s;
        
        while(ok == NO) {
            
            s = [apprentice randomSpell];
            
            if([ABState checkLinesMirrored] && ABI(3) == 0) s = @"MIRROR";
            
            // Don't do emoji transforms unless there are emoji
            if(([s isEqualToString:@"EMOJI_COLOR_SHIFT"] || [s isEqualToString:@"ERASE_ALL_EMOJI"] || [s isEqualToString:@"ERASE_ALL_EXCEPT_EMOJI"]) && hasEmojiCount == 0) {
                continue;
            }
            
            if(([s isEqualToString:@"ERASE_ALL_EMOJI"] || [s isEqualToString:@"ERASE_ALL_EXCEPT_EMOJI"]) && hasEmojiCount == visibleCount) {
                continue;
            }

            if(([s isEqualToString:@"SPACEY_MODE"] || [s isEqualToString:@"SPACEY_SPACE"]) && inSpaceyMode) {
                continue;
            }
            
            ok = YES;
        }
        
        spell = s;

    }


    DDLogInfo(@"spell: %@", spell);
    
    if([spell isEqualToString:@"PRUNE_FIRST_LAST"]) [ABCadabra pruneInterior];
    if([spell isEqualToString:@"SPIN"]) [ABCadabra spin];
    if([spell isEqualToString:@"REDACT"]) [ABCadabra redact];
    if([spell isEqualToString:@"ALLITERATIVE_ERASE"]) [ABCadabra alliterativeErase];
    if([spell isEqualToString:@"RANDOM_ERASE"]) [ABCadabra randomErase];
    if([spell isEqualToString:@"RANDOM_PRUNE"]) [ABCadabra randomPrune];
    if([spell isEqualToString:@"MINOR_ERASE"]) [ABCadabra randomMinorErase];
    if([spell isEqualToString:@"ERASE_ALL"]) [ABCadabra eraseAll];
    if([spell isEqualToString:@"RAINBOW"]) [ABCadabra rainbow];
    if([spell isEqualToString:@"RANDOM_COLORIZE"]) [ABCadabra randomColorize];
    if([spell isEqualToString:@"FLIP_LINE_ORDER"]) [ABCadabra flipLines];
    if([spell isEqualToString:@"MIRROR"]) [ABCadabra mirror];
    if([spell isEqualToString:@"SHUFFLE"]) [ABCadabra shuffle];
    if([spell isEqualToString:@"SPACEY_MODE"]) [ABCadabra spaceOutLetters];
    if([spell isEqualToString:@"SPACEY_SPACE"]) [ABCadabra spaceySpace];
    if([spell isEqualToString:@"EMOJI_COLOR_SHIFT"]) [ABCadabra emojiColorShift];
    if([spell isEqualToString:@"ERASE_ALL_EMOJI"]) [ABCadabra eraseAllEmoji];
    if([spell isEqualToString:@"ERASE_ALL_EXCEPT_EMOJI"]) [ABCadabra eraseAllExceptEmoji];
    if([spell isEqualToString:@"WEAVE"]) [ABCadabra flipLines]; // TODO
    if([spell isEqualToString:@"BLACK_BOX"]) [ABCadabra blackBox];
    if([spell isEqualToString:@"BOOST_MUTATION"]) [ABCadabra boostMutation];
    if([spell isEqualToString:@"MOON_PHASE"]) [ABCadabra moonPhase];
    if([spell isEqualToString:@"TWINS"]) [ABCadabra twins];
    if([spell isEqualToString:@"WORDS_TO_EMOJI"]) [ABCadabra wordsToEmoji];
    
    if([spell isEqualToString:@"AREA_RANDOM"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_TOP"]) [ABCadabra areaEffect:AREA_TOP withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_LEFT"]) [ABCadabra areaEffect:AREA_LEFT withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_RIGHT"]) [ABCadabra areaEffect:AREA_RIGHT withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_BOTTOM"]) [ABCadabra areaEffect:AREA_BOTTOM withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_INNER"]) [ABCadabra areaEffect:AREA_INNER withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_OUTER"]) [ABCadabra areaEffect:AREA_OUTER withFx:@"MUTATE"];
    
    if([spell isEqualToString:@"FOREST"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"TREES"];
    if([spell isEqualToString:@"CHRIS"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"CHRIS"];
    if([spell isEqualToString:@"CHESS"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"CHESS"];
    if([spell isEqualToString:@"DEATH"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"DEATH"];
    if([spell isEqualToString:@"FRUIT"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"FRUIT"];
    if([spell isEqualToString:@"RICH"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"RICH"];
    if([spell isEqualToString:@"SWEETS"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"SWEETS"];
    if([spell isEqualToString:@"AMERICA"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"AMERICA"];
    if([spell isEqualToString:@"PAST_GRAFT"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"PAST_GRAFT"];
    
    if([spell hasPrefix:@"WORDS_"]) [ABCadabra areaEffect:AREA_RANDOM withFx:spell];
    if([spell isEqualToString:@"STANZA_COLOR_EMOJI"]) [ABCadabra areaEffect:AREA_RANDOM withFx:spell];

    
}













///////////////////////////////////////////////////////
///////////////////    HELPERS    /////////////////////
///////////////////////////////////////////////////////


+ (BOOL) searchLinesForWord:(NSString *)word {
    for(NSArray *line in stanzaLines) {
        for(ABScriptWord *w in line) {
            if([w.text isEqualToString:word]) return YES;
        }
    }
    return NO;
}


+ (NSArray *) splitArrayInHalf:(NSArray *)wholeArray {
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

+ (NSArray *) locationsOfGraftedWordsIn:(NSArray *)SWArray {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[SWArray count]; i ++) {
        ABScriptWord *sw = [SWArray objectAtIndex:i];
        if(sw.isGrafted) [locs addObject:@(i)];
    }
    return locs;
}


+ (NSArray *) locationsOfEmojiIn:(NSArray *)SWArray {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[SWArray count]; i ++) {
        ABScriptWord *sw = [SWArray objectAtIndex:i];
        if(sw.emojiCount > 0) [locs addObject:@(i)];
    }
    return locs;
}


+ (NSArray *) locationsOfMutatedWordsIn:(NSArray *)SWArray {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[SWArray count]; i ++) {
        ABScriptWord *sw = [SWArray objectAtIndex:i];
        if(sw.morphCount > 0) [locs addObject:@(i)];
    }
    return locs;
}


+ (void) randomlyAddSW:(ABScriptWord *)sw intoSWLines:(NSArray *)swLines {
    
    int lineIndex = ABI((int)[swLines count]);
    NSMutableArray *line = [NSMutableArray arrayWithArray:[swLines objectAtIndex:lineIndex]];
    
    int rndIndex = ABI((int)[line count]);
    [line insertObject:sw atIndex:rndIndex];
    
    [ABState updateCurrentScriptWordLinesWithLine:line atIndex:lineIndex];
    [[ABLines objectAtIndex:lineIndex] changeWordsToWords:[NSArray arrayWithArray:line]];
}





+ (NSArray *) splitParagraphIntoLinesOfScriptWords:(NSString *)paragraph {
    
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



+ (void) replaceAllWithText:(NSArray *)newLines {
    int num = 0;
    for(NSArray *array in newLines) {
        if(num == [ABLines count]) return;
        [ABState updateCurrentScriptWordLinesWithLine:array atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:array]];
        num ++;
    }
}


+ (ABScriptWord *) getEmojiForConcept:(NSString *)concept {
    return [ABData getScriptWordAndRunChecks:[ABEmoji getRandomEmojiStringWithConcept:concept]];
}




+ (ABScriptWord *) randomSWWordFromString:(NSString *)string {
    NSArray *arr = [string componentsSeparatedByString:@" "];
    NSUInteger randomIndex = arc4random() % [arr count];
    return [ABData getScriptWordAndRunChecks:[arr objectAtIndex:randomIndex]];
}



+ (ABScriptWord *) randomSWCharacterFromString:(NSString *)string {
    NSArray *arr = [string convertToArray];
    NSUInteger randomIndex = arc4random() % [arr count];
    return [ABData getScriptWordAndRunChecks:[arr objectAtIndex:randomIndex]];
}


+ (ABScriptWord *) getSymbol {

    NSArray *arr = [@"ੴ ௬ ༆ ༀ" componentsSeparatedByString:@" "];
    NSUInteger randomIndex = arc4random() % [arr count];
    return [ABData getScriptWordAndRunChecks:[arr objectAtIndex:randomIndex]];
}



//////////////////   COMPLEX HELPERS    /////////////////////



+ (NSMutableDictionary *) analyzeLines {
    
    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    [analysis setObject:[NSMutableDictionary dictionary] forKey:@"firstCharPopularity"];
    [analysis setObject:[NSMutableDictionary dictionary] forKey:@"charCounts"];
    [analysis setObject:[NSMutableDictionary dictionary] forKey:@"lineLengths"];
//    
//    int num = 0;
//    for(NSArray *array in stanzaLines) {
//        for(ABScriptWord *sw in array) {
//            NSArray *array = [sw charArray];
//        }
//    }
    
    return analysis;
}



+ (NSArray *) mapWithOddsFrom:(CGFloat)startOdds to:(CGFloat)endOdds totalItems:(int)totalItems minIndex:(int)min maxIndex:(int)max {
    
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










/*      
 
 
                                   __   __
                                  [  | [  |
             .--.  _ .--.   .---.  | |  | |  .--.
            ( (`\][ '/'`\ \/ /__\\ | |  | | ( (`\]
             `'.'. | \__/ || \__., | |  | |  `'.'.
            [\__) )| ;.__/  '.__.'[___][___][\__) )
----------------- [__| -------------------------------------------------------------- */


+ (void) flashTwins {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"flashTwins" object:self];
}


+ (void) boostMutation {
    [ABState boostMutationLevel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"prevNextFeedbackFlash" object:nil];
}



+ (void) blackBox {
    NSArray *newLines = [ABCadabra splitParagraphIntoLinesOfScriptWords:BLOCK_BLACK_BOX];
    int num = 0;
    for(NSArray *array in newLines) {
        if(num == [ABLines count]) return;
        [ABState updateCurrentScriptWordLinesWithLine:array atIndex:num];
        ABLine *line = [ABLines objectAtIndex:num];
        line.lossyTransitions = YES;
        [line changeWordsToWords:[NSArray arrayWithArray:array]];
        line.lossyTransitions = NO;
        num ++;
    }
}


+ (void) moonPhase {
    NSString *moon = [ABEmoji getEmojiForCurrentMoonPhase];
    if([ABCadabra searchLinesForWord:moon]) return;
    ABScriptWord *sw = [ABData getScriptWord:moon];
    [ABCadabra randomlyAddSW:sw intoSWLines:stanzaLines];
}




+ (int) averageSourceStanzasFor:(ABScriptWord *)sw1 and:(ABScriptWord *)sw2 {
    int ss1 = (sw1 != nil) ? sw1.sourceStanza : [ABState getCurrentStanza];
    int ss2 = (sw2 != nil) ? sw2.sourceStanza : [ABState getCurrentStanza];
    return floor((ss2 + ss1) / 2);
}


// "before" only used for sourceStanza avg
+ (NSArray *) insertSW:(ABScriptWord *)sw0 afterSW:(ABScriptWord *)sw1 andBefore:(ABScriptWord *)sw2 {
    int ss = [ABCadabra averageSourceStanzasFor:sw1 and:sw2];
    
    sw0.sourceStanza = ss;
    return @[sw1, sw0];
}

// "before" only used for sourceStanza avg
+ (NSArray *) replaceWithSW:(ABScriptWord *)sw0 afterSW:(ABScriptWord *)sw1 andBefore:(ABScriptWord *)sw2 {
    int ss = [ABCadabra averageSourceStanzasFor:sw1 and:sw2];
    sw0.sourceStanza = ss;
    return @[sw0];
}


+ (NSMutableArray *) applySpellFx:(NSString *)spellFx toLine:(NSArray *)line withMap:(NSArray *)map {
    
    if([map count] != [line count]) DDLogError(@"count mismatch!");
    NSMutableArray *newLine = [NSMutableArray array];

    ABScriptWord *nextSW = nil;
    int lineCount = (int)[line count];
    
    for(int i = 0; i < lineCount; i ++) {

        ABScriptWord *sw = [line objectAtIndex:i];
        if(i + 1 < lineCount) nextSW = [line objectAtIndex:i + 1]; else nextSW = nil;
        
        if([[map objectAtIndex:i] boolValue] == NO) {
            [newLine addObject:sw];
        
        } else {
            NSArray *newSWs = @[];
            
            if([spellFx isEqualToString:@"MUTATE"]) {
                // Added this occasional pass to offset mutational doubling / tripling
                if(ABI(10) == 0) continue;
                newSWs = [ABMutate mutateWord:sw inLine:line];
            }

            if([spellFx isEqualToString:@"TREES"]) newSWs = [ABCadabra insertSW:[ABCadabra getEmojiForConcept:@"forest"] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"FRUIT"]) newSWs = [ABCadabra insertSW:[ABCadabra getEmojiForConcept:@"fruit"] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"RICH"]) newSWs = [ABCadabra insertSW:[ABCadabra getEmojiForConcept:@"rich"] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"SWEETS"]) newSWs = [ABCadabra insertSW:[ABCadabra getEmojiForConcept:@"sweets"] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"AMERICA"]) newSWs = [ABCadabra insertSW:[ABCadabra getEmojiForConcept:@"america"] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"CHRIS"]) newSWs = [ABCadabra insertSW:[ABCadabra getEmojiForConcept:@"chris"] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"DEATH"]) newSWs = [ABCadabra replaceWithSW:[ABCadabra randomSWCharacterFromString:SYMBOLS_DEATH] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"CHESS"]) newSWs = [ABCadabra insertSW:[ABCadabra randomSWCharacterFromString:SYMBOLS_CHESS] afterSW:sw andBefore:nextSW];
            if([spellFx isEqualToString:@"PAST_GRAFT"]) newSWs = [ABCadabra insertSW:[ABData getPastGraftWord] afterSW:sw andBefore:nextSW];
            
            if([spellFx hasPrefix:@"WORDS_"]) newSWs = [ABCadabra insertSW:[apprentice randomSWFrom:spellFx] afterSW:sw andBefore:nextSW];
            
            
            if([spellFx isEqualToString:@"STANZA_COLOR_EMOJI"]) {
                int stanza = sw.sourceStanza > -1 ? sw.sourceStanza : [ABState getCurrentStanza];
                stanza = stanza % 42;
                NSString *emoji = [ABEmoji getEmojiForStanza:stanza];
                if(!emoji) {
                    emoji = @"?";
                    DDLogDebug(@"SPELL STANZA EMOJI FAILED FOR STANZA: %d", stanza);
                }
                newSWs = @[[ABData getScriptWordAndRunChecks:emoji]];
            }

            [newLine addObjectsFromArray:newSWs];
        }
    }
    return newLine;
}




+ (NSMutableArray *) mutateMultipleWordsInLine:(NSArray *)line withMap:(NSArray *)map {
    
    if([map count] != [line count]) {
        DDLogError(@"count mismatch!");
    }
    
    NSMutableArray *newLine = [NSMutableArray array];
    
    int i = 0;
    for(ABScriptWord *sw in line) {
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
    
    return newLine;
}



+ (void) partiallyMutateAllLines {
    int num = 0;
    CGFloat odds = 0.9f;
    for(NSArray *line in stanzaLines) {
        NSArray *map = [ABCadabra mapWithOddsFrom:odds to:odds totalItems:(int)[line count] minIndex:0 maxIndex:(int)[line count]];
        NSMutableArray *newLine = [ABCadabra mutateMultipleWordsInLine:line withMap:map];
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
        odds -= 0.1f;
    }
}


+ (void) areaEffect:(areaType)type withFx:(NSString *)spellFx {

    CGFloat top, bottom, left = 0.0f, right = 0.0f, verticalIncrement, verticalOdds, inner, outer;
    BOOL isVertical = NO, isRadiant = NO;
    
    if(type == AREA_RANDOM) {
        type = (areaType) (arc4random() % (int) AREA_RANDOM);
    }

    // Horiz fades
    if(type == AREA_LEFT) {
        left = ABF(0.6f) + 0.1f;
        right = 0.0f;
    }
    if(type == AREA_RIGHT) {
        left = 0.0f;
        right = ABF(0.6f) + 0.1f;
    }

    // Vertical fades
    if(type == AREA_TOP) {
        top = ABF(0.6f) + 0.1f;
        bottom = 0.0f;
    }
    if(type == AREA_BOTTOM) {
        top = 0.0f;
        bottom = ABF(0.6f) + 0.1f;
    }
    if(type == AREA_TOP || type == AREA_BOTTOM) {
        isVertical = YES;
        verticalIncrement = (bottom - top) / [stanzaLines count];
        verticalOdds = top;
    }
    
    // Radiant fades
    if(type == AREA_INNER) {
        inner = ABF(0.6f) + 0.1f;
        outer = -0.2f;
    }
    if(type == AREA_OUTER) {
        inner = -0.2f;
        outer = ABF(0.6f) + 0.1f;
    }
    if(type == AREA_OUTER || type == AREA_INNER) {
        isVertical = YES;
        isRadiant = YES;
        verticalOdds = outer;
        verticalIncrement = ((inner - outer) / [stanzaLines count]) * 2;
    }


    int num = 0;
    
    NSMutableArray *newLines = [NSMutableArray array];

    for(NSArray *line in stanzaLines) {

        CGFloat leftOdds = isVertical ? verticalOdds : left;
        CGFloat rightOdds = isVertical ? verticalOdds : right;
        
        NSArray *map;
        
        if(isRadiant) {
            NSArray *splits = [ABCadabra splitArrayInHalf:line];
            NSArray *map1, *map2;
            if(type == AREA_INNER) {
                map1 = [ABCadabra mapWithOddsFrom:0 to:verticalOdds * 2 totalItems:(int)[splits[0] count] minIndex:0 maxIndex:(int)[splits[0] count]];
                map2 = [ABCadabra mapWithOddsFrom:verticalOdds * 2 to:0 totalItems:(int)[splits[1] count] minIndex:0 maxIndex:(int)[splits[1] count]];
            }
            if(type == AREA_OUTER) {
                map1 = [ABCadabra mapWithOddsFrom:ABF(0.3f) + 0.4f to:verticalOdds totalItems:(int)[splits[0] count] minIndex:0 maxIndex:(int)[splits[0] count]];
                map2 = [ABCadabra mapWithOddsFrom:verticalOdds to:ABF(0.3f) + 0.4f totalItems:(int)[splits[1] count] minIndex:0 maxIndex:(int)[splits[1] count]];
            }
            map = [map1 arrayByAddingObjectsFromArray:map2];
        } else {
            map = [ABCadabra mapWithOddsFrom:leftOdds to:rightOdds totalItems:(int)[line count] minIndex:0 maxIndex:(int)[line count]];
        }
        
        
        NSMutableArray *newLine = [ABCadabra applySpellFx:spellFx toLine:line withMap:map];
        
        [newLines addObject:newLine];
        num ++;
        
        if(isVertical || isRadiant) {
            if(isRadiant && (num > [stanzaLines count] / 2)) {
                verticalOdds -= verticalIncrement;
            } else {
                verticalOdds += verticalIncrement;
            }
        }
    }
    
    
    
    for(int i = 0; i < [newLines count]; i ++) {
        NSArray *line = [newLines objectAtIndex:i];
        [ABState updateCurrentScriptWordLinesWithLine:line atIndex:i];
        [[ABLines objectAtIndex:i] changeWordsToWords:[NSArray arrayWithArray:line]];
    }

    
}



+ (void) flipLines {
    
    NSMutableArray *pos = [NSMutableArray array];
    int c = (int)[ABLines count];
    if (c > 10) {
        ABLine *eleven = [ABLines objectAtIndex:10];
        if([eleven.lineWords count] == 0) c = 10;
    }
    
    for(int i = c - 1; i > -1; i--) {
        ABLine *line = [ABLines objectAtIndex:i];
        [pos addObject:[NSNumber numberWithFloat:line.yPosition]];
    }

    if([ABState checkLinesAreFlipped] == YES) {
        pos = [NSMutableArray arrayWithArray:[[pos reverseObjectEnumerator] allObjects]];
        [ABState setLinesAreFlipped:NO];
    } else {
        [ABState setLinesAreFlipped:YES];
    }

    CGFloat d = 0;
    CGFloat speed = ABF(0.04f);
    for(int i=0; i < c; i++) {
        ABLine *line = [ABLines objectAtIndex:i];
        [line animateToYPosition:[[pos objectAtIndex:i] floatValue] duration:2.0f + ((speed + 0.06f) * i) delay:((0.10f + speed) * d)];
        d ++;
        d += (d / 20);
    }
}





+ (void) mirror {
    [ABState setLinesMirrored:![ABState checkLinesMirrored]];
    CGFloat delay = 0.2f;
    CGFloat increment = 0.06f + ABF(0.2f);
    for(ABLine *line in ABLines) {
        [line mirrorWithDelay:delay];
        delay += increment;
    }
}




// TODO: fix bug in this
+ (void) weaveLines {
    
    NSMutableArray *pos = [NSMutableArray array];
    int c = (int)[ABLines count];
    if (c > 10) {
        ABLine *eleven = [ABLines objectAtIndex:10];
        if([eleven.lineWords count] == 0) c = 10;
    }
    
    for(int i = c - 1; i > -1; i--) {
        ABLine *line = [ABLines objectAtIndex:i];
        [pos addObject:[NSNumber numberWithFloat:line.yPosition]];
    }

    pos = [NSMutableArray arrayWithArray:[[pos reverseObjectEnumerator] allObjects]];

    int modulo = 1;
    if([ABState checkLinesAreWoven] == NO) {
        [ABState setLinesAreWoven:YES];
    } else {
        [ABState setLinesAreWoven:NO];
        modulo = 0;
    }
    
    CGFloat d = 0.0f;
    CGFloat last = 0.0f;
    for(int i = 0; i < c; i++) {
        CGFloat y;
        ABLine *line = [ABLines objectAtIndex:i];
        if(fmod(i + modulo, 2) == 0) {
            y = last;
        } else {
            if(i < c - 1) {
                last = [[pos objectAtIndex:i] floatValue];
                y = [[pos objectAtIndex:i+1] floatValue];
            } else {
                continue;
            }
        }
        [line animateToYPosition:y duration:2.0f + (0.08f * i) delay:(0.12f * d)];
        d ++;
        d += (d / 20);
    }
}




+ (NSArray *) spaceyLettersMagic:(NSArray *)lines andSpaceOut:(BOOL)spaceOut inTransition:(BOOL)inTransition {
    
    if(lines == nil) lines = [ABState getCurrentScriptWordLines];
    NSArray *abLines = [ABState getLines];
 
    int num = 0;
    NSMutableArray *newLines = [NSMutableArray array];
    
    for(int i=0; i<[lines count]; i++) {
        NSArray *array = [lines objectAtIndex:i];
        ABLine *wordLine = [abLines objectAtIndex:i];
        NSMutableArray *newLine = [NSMutableArray array];
        
        for(int j=0; j<[array count]; j++) {
            ABScriptWord *sw = [array objectAtIndex:j];
            if(inTransition == NO) {
                ABWord *w = [wordLine.lineWords objectAtIndex:j];
                if(w.isErased || w.isRedacted) {
                    [newLine addObject:sw];
                    continue;
                }
            }
            [newLine addObjectsFromArray:[ABMutate splitWordIntoLetters:sw andSpaceOut:spaceOut]];
        }
        [newLines addObject:newLine];
        num ++;
    }
    return [NSArray arrayWithArray:newLines];
}


+ (void) spaceOutLetters {
    [ABState setSpaceyMode:YES];
    [ABState changeAllLinesToLines:[ABCadabra spaceyLettersMagic:nil andSpaceOut:NO inTransition:NO]];
}

+ (void) spaceySpace {
    [ABState changeAllLinesToLines:[ABCadabra spaceyLettersMagic:nil andSpaceOut:YES inTransition:NO]];
}





+ (void) shuffle {

    int num = 0;
    for(NSArray *array in stanzaLines) {
        NSMutableArray *newLine = [NSMutableArray arrayWithArray:array];
        [newLine shuffle];
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}




+ (void) wordsToEmoji {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            NSString *s = [ABEmoji emojiWordTransform:sw.text];
            if(s) [newLine addObject:[ABData getScriptWord:s]];
            else [newLine addObject:sw];
        }
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}


+ (void) emojiColorShift {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            if(sw.emojiCount > 0) {
                NSArray *array = [sw charArray];
                NSMutableArray *newText = [NSMutableArray array];
                for(NSString *str in array) {
                    if([ABEmoji isEmoji:str]) {
                        NSString *replacement = [ABEmoji getEmojiOfSameColorAsEmoji:str];
                        [newText addObject:replacement];
                    } else {
                        [newText addObject:str];
                    }
                }
                ABScriptWord *newSW = [ABData getScriptWord:[newText componentsJoinedByString:@""]];
                if(!newSW.hasRunChecks) [newSW runChecks];
                [newLine addObject:newSW];
            } else {
                [newLine addObject:sw];
            }
        }
        
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}






+ (void) emojiTransform {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            NSString *emojiTransform = [ABEmoji emojiWordTransform:sw.text];
            if(emojiTransform != nil) {
                [newLine addObject:[ABData getScriptWord:emojiTransform]];
            } else {
                [newLine addObject:sw];
            }
        }
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}




+ (void) rainbow {
    
    int col = 0;
    int l = 0, lineNum = 0;
    for(ABLine *line in ABLines) {

        NSMutableArray *newLine = [NSMutableArray array];
        int i = 0;
        col = l;
        l = l + 2;
        int replacements = 0;

        for(ABWord *w in line.lineWords) {
            
            [w fadeColorToSourceStanza:col];
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            
            if(sw.emojiCount > 0) {
                NSArray *array = [sw charArray];
                NSMutableArray *newText = [NSMutableArray array];
                for(NSString *str in array) {
                    if([ABEmoji isEmoji:str]) {
                        NSString *replacement = [ABEmoji getEmojiForStanza:col];
                        DDLogInfo(@"%i %@", col, replacement);
                        [newText addObject:replacement];
                        replacements ++;
                    } else {
                        [newText addObject:str];
                    }
                }
                ABScriptWord *newSW = [ABData getScriptWord:[newText componentsJoinedByString:@""]];
                if(!newSW.hasRunChecks) [newSW runChecks];
                newSW.sourceStanza = col;
                [newLine addObject:newSW];

            } else {
                sw.sourceStanza = col;
                [newLine addObject:sw];
            }

            if(++ col == [ABScript totalStanzasCount]) col = 0;
            i ++;
        }
        
        if(replacements > 0) {
            [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:lineNum];
            [[ABLines objectAtIndex:lineNum] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        }
        
        lineNum ++;
    }
}



+ (void) randomColorize {
    
    int max = [ABScript totalStanzasCount];
    int col = ABI(max);
    int lineNum = 0;
    for(ABLine *line in ABLines) {
        
        NSMutableArray *newLine = [NSMutableArray array];
        int i = 0;
        int replacements = 0;
        
        for(ABWord *w in line.lineWords) {
            
            if(col > max) col -= max;
            if(col < 0) col += max;
            
            [w fadeColorToSourceStanza:col];
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            
            if(sw.emojiCount > 0) {
                NSArray *array = [sw charArray];
                NSMutableArray *newText = [NSMutableArray array];
                for(NSString *str in array) {
                    if([ABEmoji isEmoji:str]) {
                        NSString *replacement = [ABEmoji getEmojiForStanza:col];
                        DDLogInfo(@"%i %@", col, replacement);
                        [newText addObject:replacement];
                        replacements ++;
                    } else {
                        [newText addObject:str];
                    }
                }
                ABScriptWord *newSW = [ABData getScriptWord:[newText componentsJoinedByString:@""]];
                if(!newSW.hasRunChecks) [newSW runChecks];
                newSW.sourceStanza = col;
                [newLine addObject:newSW];
                
            } else {
                sw.sourceStanza = col;
                [newLine addObject:sw];
            }
            
            col += ABI(8);
            
        }
        
        if(replacements > 0) {
            [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:lineNum];
            [[ABLines objectAtIndex:lineNum] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        }
        
        lineNum ++;
    }
}










// TODO : make this better
+ (void) alliterativeErase {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
//    NSString *letter = @"s";
    for(ABLine *line in ABLines) {
        for(ABScriptWord *sw in line.lineScriptWords) {
            NSString *t = [[sw charArray] objectAtIndex:0];
            if([dict objectForKey:t] == nil) [dict setObject:@(0) forKey:t];
            NSNumber *n = [dict objectForKey:t];
            [dict setObject:[NSNumber numberWithInt:[n intValue] + 1] forKey:t];
        }
    }

    NSString *top = @"";
    int best = 0;
    for(NSString *key in [dict allKeys]) {
        int v = [[dict objectForKey:key] intValue];
        if(v > best) {
            top = key;
            best = v;
        }
    }
    
    for(ABLine *line in ABLines) {
        int i = 0;
        for(ABWord *w in line.lineWords) {
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            DDLogInfo(@"%@ %@", [[sw charArray] objectAtIndex:0], sw.text);
            if([[[sw charArray] objectAtIndex:0] isEqualToString:top]) {
                //
            } else {
                [w eraseWithDelay:ABF(1.5)];
            }
            i ++;
        }
    }
}





+ (void) randomErase {
    CGFloat speed = ABF(1.0) + 1.2;
    CGFloat odds = ABI(8) + 1;
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            if(ABI(9) < odds) [w eraseWithDelay:ABF(speed)];
        }
    }
}



+ (void) randomMinorErase {
    CGFloat speed = ABF(1.0) + 1.2;
    CGFloat odds = ABF(2.5) + 1;
    if([ABState numberOfLinesToDisplay] < 7) odds += 1.0f;
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            if(ABI(9) < odds) [w eraseWithDelay:ABF(speed)];
        }
    }
}


+ (void) randomPrune {
    CGFloat odds = ABI(4) + 4;
    int num = 0;
    for(NSArray *line in stanzaLines) {
        if([line count] == 0) continue;
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in line) {
            if(ABI(9) < odds) [newLine addObject:sw];
        }
        
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}







+ (void) eraseAll {
    CGFloat speed = ABF(0.5) + 1.0;
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            [w eraseWithDelay:ABF(speed)];
        }
    }
}



+ (void) redact {
    CGFloat odds = ABI(5) + 3;
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            if(ABI(9) < odds) [w redact];
        }
    }
}

+ (void) spin {
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            [w spin];
        }
    }
}



+ (void) pruneInterior {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        if([array count] == 0) continue;
        NSMutableArray *newLine = [NSMutableArray array];
        [newLine addObject:[array firstObject]];
        if([array count] > 1) [newLine addObject:[array lastObject]];
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}


+ (void) eraseAllEmoji {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        if([array count] == 0) continue;
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            if(sw.emojiCount < 1) [newLine addObject:sw];
        }
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}




+ (void) eraseAllExceptEmoji {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        if([array count] == 0) continue;
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            if(sw.emojiCount > 0) [newLine addObject:sw];
        }
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}





+ (void) twins {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        if([array count] == 0) continue;
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            [newLine addObject:sw];
            [newLine addObject:sw];
        }
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }

    [self flashTwins];

}







+ (void) revealCadabraWords {
    
    NSArray *lines = [ABState getLines];
    for(ABLine *line in lines) {
        int len = (int)[line.lineScriptWords count];
        for(int i=0; i < len; i ++) {
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            if(sw.cadabra == nil && [line.lineWords objectAtIndex:i] != nil) {
                [[line.lineWords objectAtIndex:i] quickDim];
            }
        }
    }
    
}

@end
