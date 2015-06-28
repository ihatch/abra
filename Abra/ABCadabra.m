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


typedef NS_ENUM(NSInteger, fadeType) {
    FADE_TOP,
    FADE_BOTTOM,
    FADE_LEFT,
    FADE_RIGHT,
    FADE_INNER,
    FADE_OUTER,
    FADE_RANDOM
};


typedef NS_ENUM(NSInteger, spellFxType) {
    SPELL_FX_MUTATE,
    SPELL_FX_ERASE,
    SPELL_FX_PRUNE,
    SPELL_FX_TREES,
    SPELL_FX_STANZA_EMOJI
};


typedef NS_ENUM(NSInteger, spellType) {
    SPELL_SPIN_WORDS,
    SPELL_REDACT_WORDS,
    SPELL_ALLITERATIVE_ERASURE,
    SPELL_RANDOM_ERASURE,
    SPELL_RAINBOW,
    SPELL_SPACEY_MODE,
    SPELL_EMOJI_COLOR_SHIFT,
    SPELL_ERASE_ALL_EMOJI,
    SPELL_ERASE_ALL_EXCEPT_EMOJI,
    SPELL_EMOJI_FOREST,
    SPELL_FLIP_LINE_ORDER,
    SPELL_SHUFFLE_WORDS,
    SPELL_BLACK_BOX_QUOTE,
    SPELL_RANDOM_FADE_MUTATION
};



// Methods to split string that work with extended chars (emoji)
@interface NSString (ConvertToArray)
- (NSArray *)convertToArray;
@end
@implementation NSString (ConvertToArray)
- (NSArray *)convertToArray {
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


// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end
@implementation NSMutableArray (Shuffling)
- (void)shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}
@end



@implementation ABCadabra

NSArray *ABLines;
NSArray *stanzaLines;
NSMutableArray *stringLines;
NSMutableArray *allStrings;






+ (void) castSpell {
    
    
    ABLines = [ABState getLines];
    stanzaLines = [ABState getCurrentScriptWordLines];

    stringLines = [NSMutableArray array];
    allStrings = [NSMutableArray array];

    
    int hasFamilyCount = 0;
    int familySandwichCount = 0;
    int hasEmojiCount = 0;
    int isMutatedCount = 0;
    int isGraftedCount = 0;
    int totalWords = 0;
    
    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    
    for(ABLine *line in ABLines) {
        NSMutableArray *stringLine = [NSMutableArray array];
        for(ABScriptWord *sw in line.lineScriptWords) {
            [allStrings addObject:sw.text];
            [stringLine addObject:sw.text];
            
            analysis = [ABCadabra analyzeLines:stanzaLines];
            if(sw.hasFamily) {
                hasFamilyCount ++;
                if([sw.leftSisters count] > 0 && [sw.rightSisters count] > 0){
                    familySandwichCount ++;
                }
            }
            if(sw.emojiCount > 0) hasEmojiCount ++;
            if(sw.morphCount > 0) isMutatedCount ++;
            if(sw.isGrafted == YES) isGraftedCount ++;
            totalWords ++;
        }
        [stringLines addObject:stringLine];
    }

    
    
    
    DDLogInfo(@"test");

    [ABCadabra pruneInterior:stanzaLines];
    return;
    
    [ABCadabra spinMagic:ABLines]; // <-- needs work
    [ABCadabra redactMagic:ABLines];
    [ABCadabra firstLetterErasure:ABLines];
    [ABCadabra randomErasureMagic:ABLines];
    [ABCadabra rainbowMagic:ABLines];

    
    int chance = ABI(12);
    
    DDLogInfo(@"chance %d", chance);
    
    if([ABState checkSpaceyMode] == YES && ABI(12) < 5) {
        [ABState setSpaceyMode:NO];
    } else if(hasEmojiCount > 0 && ABI(12) < 2) {
        [ABCadabra emojiColorShift:stanzaLines];
    } else if(hasEmojiCount > 0 && hasEmojiCount < totalWords && ABI(12) < 2) {
        [ABCadabra eraseAllExceptEmoji:stanzaLines];
    } else if(hasEmojiCount > 0 && hasEmojiCount < totalWords && ABI(12) < 2) {
        [ABCadabra eraseAllEmoji:stanzaLines];
    } else if(chance == 0) {
        [ABCadabra flipLines]; // weaveLines TODO bug
    } else if(chance == 1) {
        [ABCadabra flipLines];
    } else if(chance == 2) {
        [ABCadabra randomlyReorderWords:stanzaLines];
    } else if(chance == 3) {
        NSArray *a = [ABCadabra splitParagraphIntoLinesOfScriptWords:BLACK_BOX_QUOTE];
        [ABCadabra replaceAllWithText:a];
    } else if(chance == 4) {
        [ABCadabra spaceOutLetters:stanzaLines];
    } else if(chance == 5) {
        [ABCadabra fadeMutateAcrossLines:stanzaLines withFadeType:FADE_RANDOM withSpellFxType:SPELL_FX_STANZA_EMOJI];
    } else if(chance == 6) {
        [ABCadabra fadeMutateAcrossLines:stanzaLines withFadeType:FADE_RANDOM withSpellFxType:SPELL_FX_STANZA_EMOJI];
    } else if(chance == 7) {
        [ABCadabra fadeMutateAcrossLines:stanzaLines withFadeType:FADE_RANDOM withSpellFxType:SPELL_FX_TREES];
    } else if(chance == 8) {
        [ABCadabra fadeMutateAcrossLines:stanzaLines withFadeType:FADE_RANDOM withSpellFxType:SPELL_FX_TREES];
    } else if(chance > 8) {
        [ABCadabra fadeMutateAcrossLines:stanzaLines withFadeType:FADE_RANDOM withSpellFxType:SPELL_FX_MUTATE];
    }


    
    //     BLACK_BOX_QUOTE

}






+ (void) checkWordForMagicWord:(NSString *)word {
    
    
    
    
}






+ (NSMutableDictionary *) analyzeLines:(NSArray *)stanzaLines {
    
    NSMutableDictionary *analysis = [NSMutableDictionary dictionary];
    
    [analysis setObject:[NSMutableDictionary dictionary] forKey:@"firstCharPopularity"];
    [analysis setObject:[NSMutableDictionary dictionary] forKey:@"charCounts"];
    [analysis setObject:[NSMutableDictionary dictionary] forKey:@"lineLengths"];
    
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        for(ABScriptWord *sw in array) {
            NSArray *array = [sw charArray];
        }
    }

    return analysis;
    
}









+ (NSMutableArray *) applySpellFx:(spellFxType)spellFx toLine:(NSArray *)line withMap:(NSArray *)map {
    
    if([map count] != [line count]) DDLogError(@"count mismatch!");
    NSMutableArray *newLine = [NSMutableArray array];
    
    int i = 0;
    for(ABScriptWord *sw in line) {

        if([[map objectAtIndex:i] boolValue] == NO) {
            [newLine addObject:sw];
        
        } else {
            NSArray *newSWs = @[];
            
            if(spellFx == SPELL_FX_MUTATE) {
                // Added this occasional pass to offset mutational doubling / tripling
                if(ABI(10) > 1) {
                    newSWs = [ABMutate mutateWord:sw inLine:line];
                }
            }

            if(spellFx == SPELL_FX_TREES) {
                newSWs = @[[ABData getScriptWordAndRunChecks:[ABEmoji getRandomEmojiStringWithConcept:@"forest"]]];
            }

            if(spellFx == SPELL_FX_STANZA_EMOJI) {
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
        i ++;
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
        if(ABF(1.0f) < threshold) {
            [map addObject:@(YES)];
        } else {
            [map addObject:@(NO)];
        }
    }
    
    return [NSArray arrayWithArray:map];
}



+ (void) partiallyMutateAllLines:(NSArray *)stanzaLines {
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


+ (void) fadeMutateAcrossLines:(NSArray *)stanzaLines withFadeType:(fadeType)type withSpellFxType:(spellFxType)spellFx {

    CGFloat top, bottom, left = 0.0f, right = 0.0f, verticalIncrement, verticalOdds, inner, outer;
    BOOL isVertical = NO, isRadiant = NO;
    
    if(type == FADE_RANDOM) {
        type = (fadeType) (arc4random() % (int) FADE_RANDOM);
    }

    // Horiz fades
    if(type == FADE_LEFT) {
        left = ABF(0.3f) + 0.4f;
        right = 0.0f;
    }
    if(type == FADE_RIGHT) {
        left = 0.0f;
        right = ABF(0.3f) + 0.4f;
    }

    // Vertical fades
    if(type == FADE_TOP) {
        top = ABF(0.3f) + 0.4f;
        bottom = 0.0f;
    }
    if(type == FADE_BOTTOM) {
        top = 0.0f;
        bottom = ABF(0.3f) + 0.4f;
    }
    if(type == FADE_TOP || type == FADE_BOTTOM) {
        isVertical = YES;
        verticalIncrement = (bottom - top) / [stanzaLines count];
        verticalOdds = top;
    }
    
    // Radiant fades
    if(type == FADE_INNER) {
        inner = ABF(0.3f) + 0.4f;
        outer = -0.2f;
    }
    if(type == FADE_OUTER) {
        inner = -0.2f;
        outer = ABF(0.3f) + 0.4f;
    }
    if(type == FADE_OUTER || type == FADE_INNER) {
        isVertical = YES;
        isRadiant = YES;
        verticalOdds = outer;
        verticalIncrement = ((inner - outer) / [stanzaLines count]) * 2;
    }


    int num = 0;

    for(NSArray *line in stanzaLines) {

        CGFloat leftOdds = isVertical ? verticalOdds : left;
        CGFloat rightOdds = isVertical ? verticalOdds : right;
        
        NSArray *map;
        
        if(isRadiant) {
            NSArray *splits = [ABCadabra splitArrayInHalf:line];
            NSArray *map1, *map2;
            if(type == FADE_INNER) {
                map1 = [ABCadabra mapWithOddsFrom:0 to:verticalOdds * 2 totalItems:(int)[splits[0] count] minIndex:0 maxIndex:(int)[splits[0] count]];
                map2 = [ABCadabra mapWithOddsFrom:verticalOdds * 2 to:0 totalItems:(int)[splits[1] count] minIndex:0 maxIndex:(int)[splits[1] count]];
            }
            if(type == FADE_OUTER) {
                map1 = [ABCadabra mapWithOddsFrom:ABF(0.3f) + 0.4f to:verticalOdds totalItems:(int)[splits[0] count] minIndex:0 maxIndex:(int)[splits[0] count]];
                map2 = [ABCadabra mapWithOddsFrom:verticalOdds to:ABF(0.3f) + 0.4f totalItems:(int)[splits[1] count] minIndex:0 maxIndex:(int)[splits[1] count]];
            }
            map = [map1 arrayByAddingObjectsFromArray:map2];
        } else {
            map = [ABCadabra mapWithOddsFrom:leftOdds to:rightOdds totalItems:(int)[line count] minIndex:0 maxIndex:(int)[line count]];
        }
        
        
        NSMutableArray *newLine = [ABCadabra applySpellFx:spellFx toLine:line withMap:map];
        
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
        
        if(isVertical || isRadiant) {
            if(isRadiant && (num > [stanzaLines count] / 2)) {
                verticalOdds -= verticalIncrement;
            } else {
                verticalOdds += verticalIncrement;
            }
        }
    }

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








//+ (void) applyMagicStanzaLines:(NSMutableArray *)lines withMutableInterior:(BOOL)mutable {
//    
//    NSMutableArray *newLines = [NSMutableArray array];
//    int num = 0;
//
////    if(mutable) {
////        for(NSMutableArray *array in stanzaLines) {
////            NSMutableArray *newLine = [NSMutableArray array];
////            for(ABScriptWord *sw in array) [newLine addObject:sw];
////            [newLines addObject:[NSArray arrayWithArray:newLine]];
////            num ++;
////        }
////    } else {
//        for(NSArray *array in stanzaLines) {
//            NSMutableArray *newLine = [NSMutableArray array];
//            for(ABScriptWord *sw in array) [newLine addObject:sw];
//            [newLines addObject:[NSArray arrayWithArray:newLine]];
//            num ++;
//        }
////    }
//    
//    NSArray *ready = [NSArray arrayWithArray:newLines];
//    [ABState changeAllLinesToLines:ready];
//}





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
    for(int i=0; i < c; i++) {
        ABLine *line = [ABLines objectAtIndex:i];
        [line animateToYPosition:[[pos objectAtIndex:i] floatValue] duration:2.0f + (0.08f * i) delay:(0.12f * d)];
        d ++;
        d += (d / 20);
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




// TODO: make this section toggle, not stay forever
+ (NSArray *) spaceyLettersMagic:(NSArray *)stanzaLines {

    int num = 0;
    NSMutableArray *newLines = [NSMutableArray array];
    for(NSArray *array in stanzaLines) {
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            [newLine addObjectsFromArray:[ABMutate splitWordIntoLetters:sw andSpaceOut:NO]];
        }
        [newLines addObject:newLine];
        num ++;
    }
    return [NSArray arrayWithArray:newLines];
}


+ (void) spaceOutLetters:(NSArray *)stanzaLines {
    [ABState setSpaceyMode:YES];
    [ABState changeAllLinesToLines:[ABCadabra spaceyLettersMagic:stanzaLines]];
}





+ (void) randomlyReorderWords:(NSArray *)stanzaLines {

    int num = 0;
    for(NSArray *array in stanzaLines) {  // TODO: check for iPhone mode!!!  crashes here when index gets above 4
        NSMutableArray *newLine = [NSMutableArray arrayWithArray:array];
        [newLine shuffle];
        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
        num ++;
    }
}




+ (void) emojiColorShift:(NSArray *)stanzaLines {
    
    int num = 0;
    for(NSArray *array in stanzaLines) {
        NSMutableArray *newLine = [NSMutableArray array];
        for(ABScriptWord *sw in array) {
            if(sw.emojiCount > 0) {
//                NSString *text = sw.text;
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






+ (void) emojiTransform:(NSArray *)stanzaLines {
    
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




+ (void) rainbowMagic:(NSArray *)lines {
    
    int col = 0;
    int l = 0;
    for(ABLine *line in lines) {
        int i = 0;
        col = l;
        l = l + 2;
        for(ABWord *w in line.lineWords) {
            [w fadeColorToSourceStanza:col];
            ABScriptWord *sw = [line.lineScriptWords objectAtIndex:i];
            sw.sourceStanza = col;
            if(++ col == [ABScript totalStanzasCount]) col = 0;
            i ++;
        }
    }
}





+ (void) firstLetterErasure:(NSArray *)lines {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
//    NSString *letter = @"s";
    for(ABLine *line in lines) {
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
    
    for(ABLine *line in lines) {
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





+ (void) randomErasureMagic:(NSArray *)lines {
    for(ABLine *line in lines) {
        for(ABWord *w in line.lineWords) {
            if(ABI(9) < 7) [w eraseWithDelay:ABF(1.5)];
        }
    }
}



//
//+ (void) redactMagic:(NSArray *)stanzaLines {
//    
//    NSString *redact = @"████";
//    
//    int num = 0;
//    for(NSArray *array in stanzaLines) {
//        if([array count] == 0) continue;
//        NSMutableArray *newLine = [NSMutableArray array];
//        for(ABScriptWord *sw in array) {
//            if(ABI(9) < 9) {
//                ABScriptWord *newSW = [ABData getScriptWord:redact];
//                [newLine addObject:[ABData getScriptWord:redact]];
//            } else {
//                [newLine addObject:sw];
//            }
//        }
//        [ABState updateCurrentScriptWordLinesWithLine:newLine atIndex:num];
//        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:newLine]];
//        num ++;
//    }
//}
//

+ (void) redactMagic:(NSArray *)lines {
    for(ABLine *line in lines) {
        for(ABWord *w in line.lineWords) {
            if(ABI(9) < 7) [w redact];
        }
    }
}

+ (void) spinMagic:(NSArray *)lines {
    for(ABLine *line in lines) {
        for(ABWord *w in line.lineWords) {
            [w spin];
        }
    }
}



+ (void) pruneInterior:(NSArray *)stanzaLines {
    
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


+ (void) eraseAllEmoji:(NSArray *)stanzaLines {
    
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




+ (void) eraseAllExceptEmoji:(NSArray *)stanzaLines {
    
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



+ (void) replaceAllWithText:(NSArray *)stanzaLines {
    int num = 0;
    for(NSArray *array in stanzaLines) {
        [ABState updateCurrentScriptWordLinesWithLine:array atIndex:num];
        [[ABLines objectAtIndex:num] changeWordsToWords:[NSArray arrayWithArray:array]];
        num ++;
    }
}


//+ (NSArray *) splitParagraphInto





@end
