//
//  ABCadabra.m
//  Abra
//
//  Created by Ian Hatcher on 6/9/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//
//  Cadabra effects handling.


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
#import "ABApprentice.h"
#import "NSString+ABExtras.h"


// ----------------------------------------------------------------------------------------

typedef NS_ENUM(NSInteger, areaType) {
    AREA_TOP, AREA_BOTTOM, AREA_LEFT, AREA_RIGHT, AREA_INNER, AREA_OUTER, AREA_RANDOM
};


@implementation ABCadabra

NSArray *ABLines, *stanzaLines;
NSMutableArray *stringLines, *allStrings;
ABApprentice *apprentice;


+ (void) castSpell {
    [ABCadabra castSpell:nil magicWord:nil];
}

+ (void) castSpell:(NSString *)spell {
    [ABCadabra castSpell:spell magicWord:nil];
}

+ (void) castSpell:(NSString *)spell magicWord:(NSString *)magicWord {
    
    if(apprentice == nil) apprentice = [[ABApprentice alloc] init];
    
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
    
    
    for(ABLine *line in ABLines) {
        
        NSMutableArray *stringLine = [NSMutableArray array];
        int swlen = (int)[line.lineScriptWords count];
        
        for(int i = 0; i < swlen; i ++) {
            
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            ABWord *w = [line.lineWords objectAtIndex:i];
            
            BOOL visible = (w.isErased == NO);
            
            [allStrings addObject:sw.text];
            [stringLine addObject:sw.text];
            
            if(sw.hasFamily) hasFamilyCount ++;
            if(visible && sw.emojiCount > 0) hasEmojiCount ++;
            if(visible && sw.morphCount > 0) mutatedCount ++;
            if(visible && sw.isGrafted == YES) graftedCount ++;
            if(visible) visibleCount ++;
            totalWordCount ++;
        }
        
        [stringLines addObject:stringLine];
    }

    
    BOOL inSpaceyMode = [ABState fx:@"spacey"];
    BOOL someAreErased = (visibleCount < totalWordCount);
    BOOL allAreErased = (visibleCount == 0);
    // check for conditions like all erased, etc.
    
    

    // SPECIFIC SPELL
    if(spell != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerCadabra" object:self];
        
        
        
    // RANDOM SPELL
    } else {
        
        if(inSpaceyMode && ABI(12) < 5) [ABState setFx:@"spacey" to:NO];
        
        BOOL ok = NO;
        NSString *s;
        
        while(ok == NO) {
            
            s = [apprentice randomSpell];
            
            if([ABState fx:@"mirror"] && ABI(4) == 0) s = @"MIRROR";
            if([ABState fx:@"weave"] && ABI(6) == 0) s = @"WEAVE";
            if(allAreErased) s = @"CAROUSEL_RANDOM_SCROLL";
            
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
            
            if([s isEqualToString:@"UNERASE_ALL"] && someAreErased == NO) {
                continue;
            }
            
            
            ok = YES;
        }
        
        spell = s;
    }

    
    
    NSLog(@"spell: %@", spell);
    
    if([spell isEqualToString:@"CAROUSEL_RANDOM_SCROLL"]) [ABCadabra carouselRandomScroll];
    if([spell isEqualToString:@"PRUNE_FIRST_LAST"]) [ABCadabra pruneInterior];
    if([spell isEqualToString:@"SPIN"]) [ABCadabra spin];
    if([spell isEqualToString:@"REDACT"]) [ABCadabra redact];
    if([spell isEqualToString:@"ALLITERATIVE_ERASE"]) [ABCadabra alliterativeEraseWithMagicWord:magicWord];
    if([spell isEqualToString:@"ERASE_AND_ADD"]) [ABCadabra eraseAndAdd];
    if([spell isEqualToString:@"RANDOM_ERASE"]) [ABCadabra randomErase];
    if([spell isEqualToString:@"RANDOM_PRUNE"]) [ABCadabra randomPrune];
    if([spell isEqualToString:@"MINOR_ERASE"]) [ABCadabra randomMinorErase];
    if([spell isEqualToString:@"ERASE_ALL"]) [ABCadabra eraseAll];
    if([spell isEqualToString:@"UNERASE_ALL"]) [ABCadabra uneraseAll];
    if([spell isEqualToString:@"RAINBOW"]) [ABCadabra rainbow];
    if([spell isEqualToString:@"RANDOM_COLORIZE"]) [ABCadabra randomColorize];
    if([spell isEqualToString:@"FLIP_LINE_ORDER"]) [ABCadabra flipLines];
    if([spell isEqualToString:@"WEAVE"]) [ABCadabra weaveLines];
    if([spell isEqualToString:@"MIRROR"]) [ABCadabra mirror];
    if([spell isEqualToString:@"SHUFFLE"]) [ABCadabra shuffle];
    if([spell isEqualToString:@"SPACEY_MODE"]) [ABCadabra spaceOutLetters];
    if([spell isEqualToString:@"SPACEY_SPACE"]) [ABCadabra spaceySpace];
    if([spell isEqualToString:@"EMOJI_COLOR_SHIFT"]) [ABCadabra emojiColorShift];
    if([spell isEqualToString:@"ERASE_ALL_EMOJI"]) [ABCadabra eraseAllEmoji];
    if([spell isEqualToString:@"ERASE_ALL_EXCEPT_EMOJI"]) [ABCadabra eraseAllExceptEmoji];
    if([spell isEqualToString:@"BLACK_BOX"]) [ABCadabra blackBox];
    if([spell isEqualToString:@"BOOST_MUTATION"]) [ABCadabra boostMutation];
    if([spell isEqualToString:@"MOON_PHASE"]) [ABCadabra moonPhase];
    if([spell isEqualToString:@"TWINS"]) [ABCadabra twins];
    if([spell isEqualToString:@"EMOJI_TRANSFORM"]) [ABCadabra emojiTransform];
    
    if([spell isEqualToString:@"AREA_RANDOM"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_TOP"]) [ABCadabra areaEffect:AREA_TOP withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_LEFT"]) [ABCadabra areaEffect:AREA_LEFT withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_RIGHT"]) [ABCadabra areaEffect:AREA_RIGHT withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_BOTTOM"]) [ABCadabra areaEffect:AREA_BOTTOM withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_INNER"]) [ABCadabra areaEffect:AREA_INNER withFx:@"MUTATE"];
    if([spell isEqualToString:@"AREA_OUTER"]) [ABCadabra areaEffect:AREA_OUTER withFx:@"MUTATE"];
    
    if([spell isEqualToString:@"FOREST"]) [ABCadabra areaEffect:AREA_RANDOM withFx:@"FOREST"];
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

+ (void) randomlyAddSW:(ABScriptWord *)sw intoSWLines:(NSArray *)swLines {
    
    int lineIndex = ABI((int)[swLines count]);
    NSMutableArray *line = [NSMutableArray arrayWithArray:[swLines objectAtIndex:lineIndex]];
    
    int rndIndex = ABI((int)[line count]);
    [line insertObject:sw atIndex:rndIndex];
    
    [ABState updateCurrentScriptWordLinesWithLine:line atIndex:lineIndex];
    [[ABLines objectAtIndex:lineIndex] changeWordsToWords:[NSArray arrayWithArray:line]];
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








/*                                 __   __
                                  [  | [  |        
             .--.  _ .--.   .---.  | |  | |  .--.
            ( (`\][ '/'`\ \/ /__\\ | |  | | ( (`\]
             `'.'. | \__/ || \__., | |  | |  `'.'.
            [\__) )| ;.__/  '.__.'[___][___][\__) )
----------------- [__| ------------------------------------------------------------------------------- */



//
//+ (void) addAFewEmoji {
//
//    CGFloat odds = ABF(0.1) + 0.05;
//    NSArray *map = [apprentice stanzaMapWithPercent:odds andLines:stanzaLines];
//    CGFloat delay = ABF(1.0) + 1.2;
//    int i = 0;
//
//
//    int stanza = [ABState getCurrentStanza];
//    for(int i=0; i < 2 + ABI(5); i++) {
//        ABScriptWord *sw = [ABData getScriptWordAndRunChecks:[ABEmoji getEmojiForStanza:stanza]];
//        [self randomlyAddSW:sw intoSWLines:stanzaLines];
//    }
//}
//



+ (void) alliterativeEraseWithMagicWord:(NSString *)word {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *letter = @"t";
    
    // If no magic word, go with the most common alliterative char in the stanza
    if(word == nil) {
        for(ABLine *line in ABLines) {
            for(ABScriptWord *sw in line.lineScriptWords) {
                NSString *t = [[sw charArray] objectAtIndex:0];
                if([dict objectForKey:t] == nil) [dict setObject:@(0) forKey:t];
                NSNumber *n = [dict objectForKey:t];
                [dict setObject:[NSNumber numberWithInt:[n intValue] + 1] forKey:t];
            }
        }
        
        int best = 0;
        for(NSString *key in [dict allKeys]) {
            int v = [[dict objectForKey:key] intValue];
            if(v > best) {
                letter = key;
                best = v;
            }
        }
        
        // Otherwise, use that word's first letter
    } else {
        NSArray *split = [word convertToArray];
        letter = [split objectAtIndex:0];
    }
    
    for(ABLine *line in ABLines) {
        int i = 0;
        for(ABWord *w in line.lineWords) {
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            NSLog(@"%@ %@", [[sw charArray] objectAtIndex:0], sw.text);
            if([[[sw charArray] objectAtIndex:0] isEqualToString:letter]) {
                //
            } else {
                [w eraseWithDelay:ABF(1.5)];
            }
            i ++;
        }
    }
}



+ (NSMutableArray *) applySpellFx:(NSString *)spellFx toLine:(NSArray *)line withMap:(NSArray *)map {
    
    if([map count] != [line count]) NSLog(@"count mismatch!");
    NSMutableArray *newLine = [NSMutableArray array];
    
    ABScriptWord *nsw = nil;
    int lineCount = (int)[line count];
    
    for(int i = 0; i < lineCount; i ++) {
        
        ABScriptWord *sw = [line objectAtIndex:i];
        if(i + 1 < lineCount) nsw = [line objectAtIndex:i + 1]; else nsw = nil;
        
        if([[map objectAtIndex:i] boolValue] == NO) {
            [newLine addObject:sw];
            
        } else {
            NSArray *newSWs = @[];
            
            if([spellFx isEqualToString:@"MUTATE"]) {
                // Added this occasional pass to offset mutational doubling / tripling
                if(ABI(10) == 0) continue;
                newSWs = [ABMutate mutateWord:sw inLine:line];
            }
            
            NSArray *emojiFx = @[@"FOREST", @"FRUIT", @"RICH", @"SWEETS", @"AMERICA", @"CHRIS"];
            if([emojiFx containsObject:spellFx]) newSWs = [apprentice swInsert:[apprentice swEmojiForConcept:spellFx] after:sw before:nsw];
            
            if([spellFx isEqualToString:@"DEATH"]) newSWs = [apprentice swReplace:[apprentice swCharFromString:SYMBOLS_DEATH] after:sw before:nsw];
            if([spellFx isEqualToString:@"CHESS"]) newSWs = [apprentice swInsert:[apprentice swCharFromString:SYMBOLS_CHESS] after:sw before:nsw];
            
            if([spellFx isEqualToString:@"PAST_GRAFT"]) newSWs = [apprentice swInsert:[ABData getPastGraftWord] after:sw before:nsw];
            
            if([spellFx hasPrefix:@"WORDS_"]) newSWs = [apprentice swInsert:[apprentice randomSWFrom:spellFx] after:sw before:nsw];
            
            if([spellFx isEqualToString:@"RANDOM"]) newSWs = [apprentice swInsert:[ABScript trulyRandomWord] after:sw before:nsw];
            
            
            if([spellFx isEqualToString:@"STANZA_COLOR_EMOJI"]) {
                int stanza = sw.sourceStanza > -1 ? sw.sourceStanza : [ABState getCurrentStanza];
                stanza = stanza % 42;
                NSString *emoji = [ABEmoji getEmojiForStanza:stanza];
                if(!emoji) {
                    emoji = @"?";
                    NSLog(@"SPELL STANZA EMOJI FAILED FOR STANZA: %d", stanza);
                }
                newSWs = @[[ABData getScriptWordAndRunChecks:emoji]];
            }
            
            [newLine addObjectsFromArray:newSWs];
        }
    }
    return newLine;
}





+ (void) areaEffect:(areaType)type withFx:(NSString *)spellFx {
    [ABCadabra areaEffect:type withFx:spellFx andBaseOdds:0.6f];
}


+ (void) areaEffect:(areaType)type withFx:(NSString *)spellFx andBaseOdds:(CGFloat)base {
    
    CGFloat top, bottom, left = 0.0f, right = 0.0f, verticalIncrement, verticalOdds, inner, outer;
    BOOL isVertical = NO, isRadiant = NO;
    
    if(type == AREA_RANDOM) {
        type = (areaType) (arc4random() % (int) AREA_RANDOM);
    }
    
    // Horiz fades
    if(type == AREA_LEFT) {
        left = ABF(base) + 0.1f;
        right = 0.0f;
    }
    if(type == AREA_RIGHT) {
        left = 0.0f;
        right = ABF(base) + 0.1f;
    }
    
    // Vertical fades
    if(type == AREA_TOP) {
        top = ABF(base) + 0.1f;
        bottom = 0.0f;
    }
    if(type == AREA_BOTTOM) {
        top = 0.0f;
        bottom = ABF(base) + 0.1f;
    }
    if(type == AREA_TOP || type == AREA_BOTTOM) {
        isVertical = YES;
        verticalIncrement = (bottom - top) / [stanzaLines count];
        verticalOdds = top;
    }
    
    // Radiant fades
    if(type == AREA_INNER) {
        inner = ABF(base) + 0.1f;
        outer = -0.1f;
    }
    if(type == AREA_OUTER) {
        inner = -0.1f;
        outer = ABF(base) + 0.1f;
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
            NSArray *splits = [apprentice splitArrayInHalf:line];
            NSArray *map1, *map2;
            if(type == AREA_INNER) {
                map1 = [apprentice mapWithOddsFrom:0 to:verticalOdds * 2 total:(int)[splits[0] count] min:0 max:(int)[splits[0] count]];
                map2 = [apprentice mapWithOddsFrom:verticalOdds * 2 to:0 total:(int)[splits[1] count] min:0 max:(int)[splits[1] count]];
            }
            if(type == AREA_OUTER) {
                map1 = [apprentice mapWithOddsFrom:ABF(base / 2) + (base * 0.66) to:verticalOdds total:(int)[splits[0] count] min:0 max:(int)[splits[0] count]];
                map2 = [apprentice mapWithOddsFrom:verticalOdds to:ABF(base / 2) + (base * 0.66) total:(int)[splits[1] count] min:0 max:(int)[splits[1] count]];
            }
            map = [map1 arrayByAddingObjectsFromArray:map2];
        } else {
            map = [apprentice mapWithOddsFrom:leftOdds to:rightOdds total:(int)[line count] min:0 max:(int)[line count]];
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



+ (void) blackBox {
    NSArray *newLines = [apprentice splitParagraphIntoLinesOfScriptWords:BLOCK_BLACK_BOX];
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




+ (void) boostMutation {
    [ABState boostMutationLevel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"prevNextFeedbackFlash" object:nil];
}



+ (void) carouselRandomScroll {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"carouselRandomScroll" object:self];
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
                [newLine addObject:[ABData getScriptWordAndRunChecks:emojiTransform]];
            } else {
                [newLine addObject:sw];
            }
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



+ (void) eraseAndAdd {
    [ABCadabra randomEraseAndAdd:YES];
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
    
    if([ABState fx:@"flipLines"] == YES) {
        pos = [NSMutableArray arrayWithArray:[[pos reverseObjectEnumerator] allObjects]];
        [ABState setFx:@"flipLines" to:NO];
    } else {
        [ABState setFx:@"flipLines" to:YES];
    }
    
    CGFloat d = 0;
    CGFloat offset = ABF(0.04f);
    for(int i=0; i < c; i++) {
        ABLine *line = [ABLines objectAtIndex:i];
        CGFloat duration = 2.0f + ((offset + 0.06f) * i);
        CGFloat delay = (0.10f + offset) * d;
        [line animateToYPosition:[[pos objectAtIndex:i] floatValue] duration:duration delay:delay];
        d ++;
        d += (d / 20);
    }
}


+ (void) mirror {
    [ABState setFx:@"mirror" to:![ABState fx:@"mirror"]];
    CGFloat delay = 0.2f;
    CGFloat increment = 0.06f + ABF(0.2f);
    for(ABLine *line in ABLines) {
        [line mirrorWithDelay:delay];
        delay += increment;
    }
}





+ (void) moonPhase {

    NSString *moon = [ABEmoji getEmojiForCurrentMoonPhase];
    if([apprentice searchLines:stanzaLines forWord:moon]) return;
    
    ABScriptWord *sw = [ABData getScriptWordAndRunChecks:moon];

    int lineIndex = [apprentice rndIndex:stanzaLines];
    NSMutableArray *line = [NSMutableArray arrayWithArray:[stanzaLines objectAtIndex:lineIndex]];
    int rndIndex = [apprentice rndIndex:line];
    [line insertObject:sw atIndex:rndIndex];

    [ABState updateCurrentScriptWordLinesWithLine:line atIndex:lineIndex];
    [[ABLines objectAtIndex:lineIndex] changeWordsToWords:[NSArray arrayWithArray:line]];
}






+ (void) partiallyMutateAllLines {
    int num = 0;
    CGFloat odds = 0.9f;
    for(NSArray *line in stanzaLines) {
        NSArray *map = [apprentice mapWithOddsFrom:odds to:odds total:(int)[line count] min:0 max:(int)[line count]];
        NSArray *newLine = [apprentice mutateMultipleWordsInLine:line withMap:map];
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
        odds -= 0.1f;
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
                        NSLog(@"%i %@", col, replacement);
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
                        NSLog(@"%i %@", col, replacement);
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




+ (void) randomErase {
    [ABCadabra randomEraseAndAdd:NO];
}

+ (void) randomEraseAndAdd:(BOOL)add {
    
    CGFloat odds = (ABF(1.0) * ABF(1.0)) - (ABF(0.1));
    if(odds < 0.15) odds = 0.15;
    if(odds > 0.85) odds = 0.85;
    NSArray *map = [apprentice fullMapWithPercent:odds andABLines:ABLines];
    CGFloat delay = ABF(1.0) + 1.2;
    int i = 0;
    
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            if([[map objectAtIndex:i] boolValue] == YES) [w eraseWithDelay:ABF(delay)];
            i ++;
        }
    }
    if(add) [ABCadabra areaEffect:AREA_RANDOM withFx:@"RANDOM" andBaseOdds:odds];
    
}



+ (void) randomMinorErase {
    
    CGFloat odds = ABF(0.2) + ABF(0.2) + 0.1;
    if(odds < 0.1) odds = 0.1;
    NSArray *map = [apprentice fullMapWithPercent:odds andABLines:ABLines];
    CGFloat speed = ABF(1.35) + 1.2;
    int i = 0;
    
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            if([[map objectAtIndex:i] boolValue] == YES) [w eraseWithDelay:ABF(speed)];
            i ++;
        }
    }
}


+ (void) randomPrune {
    
    CGFloat odds = (ABF(1.0) * ABF(1.0)) - (ABF(0.2));
    if(odds < 0.15) odds = 0.15;
    if(odds > 0.85) odds = 0.85;
    NSArray *map = [apprentice fullMapWithPercent:odds andStanzaLines:stanzaLines];
    int i = 0;
    int num = 0;
    for(NSArray *line in stanzaLines) {
        if([line count] == 0) continue;
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in line) {
            if([[map objectAtIndex:i] boolValue] == NO) [newLine addObject:sw];
            i ++;
        }
        
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}




+ (void) redact {
    
    CGFloat odds = (ABF(1.0) * ABF(1.0)) + (ABF(0.15));
    if(odds < 0.15) odds = 0.15;
    if(odds > 0.9) odds = 0.9;
    NSArray *map = [apprentice fullMapWithPercent:odds andABLines:ABLines];
    int i = 0;
    
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            if([[map objectAtIndex:i] boolValue] == YES) [w redact];
            i ++;
        }
    }
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




+ (NSArray *) spaceyLetters:(NSArray *)lines andSpaceOut:(BOOL)spaceOut inTransition:(BOOL)inTransition {
    
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
    [ABState setFx:@"spacey" to:YES];
    [ABState changeAllLinesToLines:[ABCadabra spaceyLetters:nil andSpaceOut:NO inTransition:NO]];
}

+ (void) spaceySpace {
    [ABState changeAllLinesToLines:[ABCadabra spaceyLetters:nil andSpaceOut:YES inTransition:NO]];
}



+ (void) spin {
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            [w spin];
        }
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

    [self twinsFlash];

}



+ (void) twinsFlash {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twinsFlash" object:self];
}



+ (void) uneraseAll {
    CGFloat speed = ABF(1.7) + 1.0;
    for(ABLine *line in ABLines) {
        for(ABWord *w in line.lineWords) {
            [w uneraseWithDelay:ABF(speed)];
        }
    }
}



+ (void) weaveLines {
    
    BOOL weave = [ABState fx:@"weave"];
    BOOL skip11 = NO;
    
    NSMutableArray *pos = [NSMutableArray array];
    if([ABLines count] == 11 && [((ABLine *)[ABLines objectAtIndex:10]).lineWords count] == 0) {
        skip11 = YES;
    }
    
    int i = 0;
    for(ABLine *line in ABLines) {
        if(i == 10 && skip11 && !weave) continue;
        [pos addObject:@(line.frame.origin.y)];
        i ++;
    }
    
    if(!weave) {
        [pos shuffle];
    } else {
        NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        [pos sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    }
    
    CGFloat base = 1.4f;
    CGFloat rnd = 1.4f;
    
    for(int i=0; i < [pos count]; i ++) {
        CGFloat y = [[pos objectAtIndex:i] floatValue];
        [[ABLines objectAtIndex:i] animateToYPosition:y duration:base + ABF(rnd) delay:ABF(rnd)];
    }
    
    [ABState setFx:@"weave" to:!weave];
    
}



@end
