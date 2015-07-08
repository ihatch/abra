//
//  ABMutate.m
//  Abra
//
//  Created by Ian Hatcher on 2/21/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//


#import "ABMutate.h"
#import "ABConstants.h"
#import "ABScript.h"
#import "ABScriptWord.h"
#import "ABState.h"
#import "ABData.h"
#import "ABDice.h"
#import "ABEmoji.h"
#import "NSString+ABExtras.h"


@implementation ABMutate

UITextChecker *textChecker;

static ABMutate *ABMutateInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABMutateInstance == NULL) ABMutateInstance = [[ABMutate alloc] init];
        textChecker = [[UITextChecker alloc] init];
    }
}




+ (NSArray *) mutateWord:(ABScriptWord *)sw inLine:(NSArray *)line {
    // DDLogInfo(@"mutationLevel %d", [ABState checkMutationLevel]);
    mutationType type = RANDOM;
    if([ABState checkMutationLevel] < 1 || (ABI(7) < 4)) type = DICE;
    return [ABMutate alterOneWord:sw inLine:line withMutationType:type];
}

+ (NSArray *) graftWord:(ABScriptWord *)sw {
    return [ABMutate alterOneWord:sw inLine:nil withMutationType:GRAFTWORD];
}

+ (NSArray *) explodeWord:(ABScriptWord *)sw {
    return [ABMutate alterOneWord:sw inLine:nil withMutationType:EXPLODE];
}

+ (NSArray *) multiplyWord:(ABScriptWord *)sw {
    return [ABMutate alterOneWord:sw inLine:nil withMutationType:CLONE];
}


// Returns NEW words, not entire line. Line is passed in just for context and using that info for effects
+ (NSArray *) alterOneWord:(ABScriptWord *)oldWord inLine:(NSArray *)line withMutationType:(mutationType)type {
    
    NSArray *newWords;
    
    if(type == DICE) {
        
        NSString *emojiTransform = [ABEmoji emojiWordTransform:oldWord.text];
        ABScriptWord *sw;
        
        if(emojiTransform == nil) sw = [ABMutate attemptMatchBySpellCheck:oldWord];

        if(emojiTransform != nil && ABI(25) == 0) {
            sw = [ABData getScriptWordAndRunChecks:emojiTransform];
            newWords = @[sw];

        } else if(sw != nil && ABI(7) == 0) {
            [sw runChecks];
            newWords = @[sw];
            
        } else {
            if(ABI(40) == 0) {
                newWords = @[[ABMutate throwDiceCoefficient:oldWord], [ABMutate throwDiceCoefficient:oldWord], [ABMutate throwDiceCoefficient:oldWord]];
                newWords = [newWords valueForKeyPath:@"@distinctUnionOfObjects.self"];

            } else if(ABI(9) == 0) {
                newWords = @[[ABMutate throwDiceCoefficient:oldWord], [ABMutate throwDiceCoefficient:oldWord]];
                newWords = [newWords valueForKeyPath:@"@distinctUnionOfObjects.self"];
            
            } else {
                newWords = @[[ABMutate throwDiceCoefficient:oldWord]];
            }
        }
    
    } else if(type == RANDOM) {
        newWords = [ABMutate mutate:oldWord andLocalWords:line mutationLevel:5 lineLength:(int)[line count]];
        
    } else if(type == GRAFTWORD) {
        ABScriptWord *gw = [ABData getWordToGraft];
        gw.sourceStanza = oldWord.sourceStanza;
        newWords = @[gw];
        
    } else if(type == EXPLODE) {
        newWords = [ABMutate splitWordIntoLetters:oldWord andSpaceOut:NO];
        
    } else if(type == CLONE) {
        newWords = @[oldWord, oldWord];
    }
    
    for(int i=0; i < [newWords count]; i ++) {
        ABScriptWord *w = [newWords objectAtIndex:i];
        w.morphCount = oldWord.morphCount + 1;
    }
    
    return [NSArray arrayWithArray:newWords];
}






/////////////////
// SPELL CHECK //
/////////////////


+ (NSArray *) spellCheck:(NSString *)string {
    NSRange stringRange = NSMakeRange(0, string.length);
    NSRange range = [textChecker rangeOfMisspelledWordInString:string range:stringRange startingAt:stringRange.location wrap:NO language:@"en_US"];
    NSArray *arrGuessed = [textChecker guessesForWordRange:range inString:string language:@"en_US"];
    return arrGuessed;
}


+ (ABScriptWord *) attemptMatchBySpellCheck:(ABScriptWord *)word {
    
    // Is word already misspelled?
    NSArray *simple = [ABMutate spellCheck:word.text];
    if([simple count] > 0) {
        ABScriptWord *sw = [ABData getScriptWord:simple[0]];
        return sw;
    }
    
    // don't run on short words. otherwise stanza gradually dwindle to letter fragments
    if([[word.text convertToArray] count] < 6) return nil;

    // try cutting a letter...
    NSString *cut = [ABMutate cutFirstOrLastLetter:word.text];
    NSArray *cuts = [ABMutate spellCheck:cut];
    if([cuts count]) return [ABData getScriptWord:simple[0] withSourceStanza:word.sourceStanza];
    
    // no? okay, try a scrambler...
    NSString *scrambled = [ABMutate scrambleString:word.text];
    NSArray *scram = [ABMutate spellCheck:scrambled];
    if([scram count]) return [ABData getScriptWord:scram[0] withSourceStanza:word.sourceStanza];
    
    // still no? okay, make a slice of it, then spellcheck that
    NSArray *slices = [ABMutate sliceStringInHalf:word.text];
    NSString *slice;
    NSArray *matches;

    if(slices == nil) return nil;
    slice = [slices objectAtIndex:0];

    if([slice length] > 2) {
        matches = [ABMutate spellCheck: slice];
        if([matches count] > 0) {
            ABScriptWord *sw = [ABData getScriptWord:matches[0] withSourceStanza:word.sourceStanza];
            return sw;
        }
    }

    return nil;
}






/////////////////
// COUP DE DÉS //
/////////////////


+ (ABScriptWord *) throwDiceCoefficient:(ABScriptWord *)word {
    
    NSArray *dice = [ABDice diceForKey:word.text];
    if([dice count] == 0) return [ABMutate noDiceFallbackMatch:word];
    
    ABScriptWord *sw = [ABScriptWord copyScriptWord:word];
    
    @try {
        
        int range = 4 + (word.morphCount * 3);
        int max = (int)[dice count];
        if(range > max) range = max;
        
        if(max > 0 && word.morphCount < 2 && word.isGrafted) {
            sw = [ABMutate rollDiceMatch:word dice:dice range:range max:max];
            
        } else if(range == max && ABI(5) == 0) {
            sw = [ABData getPastGraftWord];
            if(!sw) sw = [ABScript trulyRandomWord];
            DDLogWarn(@"Radical (random) dice mutation: %@ -> %@", word.text, sw.text);
            sw.morphCount = (int)(sw.morphCount / 3);
            
        } else {
            sw = [ABMutate rollDiceMatch:word dice:dice range:range max:max];
        }
    }
    
    @catch (NSException *exception) {
        DDLogError(@">> DICE ERROR: %@", word.text);
    }
    
    @finally {
        // To make changes more colorful sooner, change this last digit:
        sw.sourceStanza = word.sourceStanza + ABI(word.morphCount) + 1;
        return sw;
    }
}


+ (ABScriptWord *) rollDiceMatch:(ABScriptWord *)word dice:(NSArray *)dice range:(int)range max:(int)max {
    int randomIndex = ABI(range);
    NSString *diceWord = [dice objectAtIndex:randomIndex];
    if(!diceWord) {
        DDLogWarn(@"ERROR: Bad dice match for: %@", word.text);
        return word;
    }
//    DDLogVerbose(@"[+] Dice: %@ -> %@ (%i)", word.text, diceWord, word.morphCount);
    return [ABData getScriptWord:diceWord];
    
}


+ (ABScriptWord *) noDiceFallbackMatch:(ABScriptWord *)word {
    
    ABScriptWord *result;

    // Emoji?
    if([ABEmoji isEmoji:word.text]) result = [ABMutate diceMatchForEmoji:word.text];
    if(result) return result;
    
    // Spell check match?
    result = [ABMutate attemptMatchBySpellCheck:word];
    if(result) {
        [result runChecks];
        DDLogInfo(@">> Spell check dice match: %@ -> %@ ", word.text, result.text);
        return result;
    }
    
    // No dice!
    DDLogWarn(@">> Dice match failed! Returning a random - %@", word.text);
    return [ABScript trulyRandomWord];
}


+ (ABScriptWord *) diceMatchForEmoji:(NSString *)string {
    NSString *result = [ABEmoji getEmojiOfSameColorAsEmoji:string];
    if(result) return [ABData getScriptWord:result];
    result = [ABEmoji emojiWordTransform:result];
    if(result) return [ABData getScriptWord:result];
    DDLogWarn(@"ERROR: Emoji match failed! %@", string);
    return nil;
}











///////////////////
// REMIX STANZAS //  ("Abra classic")
///////////////////


+ (NSArray *) mutateLines:(NSArray *)stanza atMutationLevel:(int)mutationLevel {
    
    NSArray *targetStanza = stanza;
    NSMutableArray *newStanza = [NSMutableArray array];
    NSArray *allTargetWords = [ABScript allWordsInLines:stanza];
    
    for(int l=0; l < [targetStanza count]; l ++) {
        
        NSArray *targetLine = [targetStanza objectAtIndex:l];
        NSMutableArray *newLine = [NSMutableArray array];
        
        int lineLength = [ABMutate totalCharLengthOfWordObjs:targetLine];
        
        for(int w=0; w < [targetLine count]; w ++) {
            
            ABScriptWord *targetWord = [targetLine objectAtIndex:w];
            if([targetWord.text isEqualToString:@""]) continue;
            
            // Allow target word to pass unimpeded?
            if(ABI(32) > mutationLevel && targetWord.isGrafted == NO) {
                [newLine addObject:targetWord];
                continue;
            }
            
            // Add a mutation
            [newLine addObjectsFromArray:[ABMutate mutate:targetWord andLocalWords:allTargetWords mutationLevel:mutationLevel lineLength:lineLength]];
        }
        
        NSArray *filteredLine = [ABMutate cutWordsOutOfTooLongLine:newLine];
        [newStanza addObject:filteredLine];
    }
    
    NSArray *result = [NSArray arrayWithArray:newStanza];
    return result;
}


+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel {
    return [ABMutate remixStanza:stanza andOldStanza:oldStanza atMutationLevel:mutationLevel andLimitTo:0];
}


+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel andLimitTo:(int)limit {
    
    DDLogInfo(@"mutationLevel %d", mutationLevel);
    
    
    int changes = 0;
    NSArray *targetStanza = stanza;
    NSMutableArray *newStanza = [NSMutableArray array];
    
    for(int l=0; l < [targetStanza count]; l ++) {
        
        NSArray *targetLine = [targetStanza objectAtIndex:l];
        NSArray *oldLine = (l < [oldStanza count]) ? [oldStanza objectAtIndex:l] : nil;
        NSMutableArray *newLine = [NSMutableArray array];
        
        int lineLength = [ABMutate totalCharLengthOfWordObjs:targetLine];
        
        for(int w=0; w < [targetLine count]; w ++) {
            
            ABScriptWord *targetWord = [targetLine objectAtIndex:w];
            
            // Allow target new word to pass unimpeded?
            if((ABI(16) > mutationLevel && targetWord.isGrafted == NO) ||
               (limit > 0 && changes > limit - 1)) {
                [newLine addObject:targetWord];
                continue;
            }
            
            // Count number of mutations
            changes ++;
            
            // Add random word from old stanza
            if(ABI(20) < 7 && [oldLine count] > 0) {
                [newLine addObject:[oldLine objectAtIndex:(arc4random() % [oldLine count])]];
                continue;
            }
            
            // Add a mutation
            [newLine addObjectsFromArray:[ABMutate mutate:targetWord andLocalWords:targetLine mutationLevel:mutationLevel lineLength:lineLength]];
        }
        
        NSArray *filteredLine = [ABMutate cutWordsOutOfTooLongLine:newLine];
        [newStanza addObject:filteredLine];
    }
    
    NSArray *result = [NSArray arrayWithArray:newStanza];
    return result;
}



+ (NSArray *) mutate:(ABScriptWord *)targetWord andLocalWords:(NSArray *)localWords mutationLevel:(int)mutationLevel lineLength:(int)lineLength {
    
    DDLogInfo(@"mutationLevel %d %d", [ABState checkMutationLevel], mutationLevel);
    
    
    NSArray *returnArray;
    ABScriptWord *stanzaWord = [ABScript randomScriptWordFromSet:localWords];
    ABScriptWord *randomWord = (ABI(4) == 0) ? [ABScript trulyRandomWord] :
    [ABMutate randomWordWithMutationLevel:mutationLevel];
    
    int odds = 2;
    if(lineLength < 50) odds = 0;
    if(lineLength > 80) odds = 4;
    if(lineLength > 90) odds = 5;
    if(lineLength > 100) odds = 6;
    if(lineLength > 110) odds = 7;
    if(lineLength > 120) odds = 8;
    
    // Look for user-submitted text; if found, cut it up
    if(ABI(20) < 10 && [targetWord isGrafted]) {
        if(ABI(2) == 0) {
            targetWord.isGrafted = NO;
            targetWord.sourceStanza = [ABState getCurrentStanza];
        }
        returnArray = [ABMutate sliceWordInHalf:targetWord];
    }
    
    // Look for user-submitted text; if found, duplicate it
    else if(ABI(20) < 18 && [targetWord isGrafted]) {
        ABScriptWord *duplicate = [targetWord copyOfThisWord];
        if(ABI(2) == 0) {
            duplicate.isGrafted = NO;
            duplicate.sourceStanza = [ABState getCurrentStanza];
        }
        returnArray = @[targetWord, duplicate];
    }
    
    // Destroy target word
    else if(odds > 0 && ABI(20) < odds) {
        returnArray = @[];
    }
    
    // Destroy target word
    else if(odds > 0 && ABI(20) < odds) {
        returnArray = @[];
    }
    
    // Copy word from elsewhere in stanza
    else if(ABI(20) < 7) {
        returnArray = @[stanzaWord];
    }
    
    // Random halves of a copy word
    else if(ABI(20) < 4 && [[stanzaWord text] length] > 1) {
        returnArray = [ABMutate sliceWordInHalf:stanzaWord];
    }
    
    // Random halves of truly random word
    else if(ABI(28) < 2 && [[randomWord text] length] > 1) {
        returnArray = [ABMutate sliceWordInHalf:randomWord];
    }
    
    // Add old word in letters
    else if(ABI(20) < 3) {
        returnArray = [ABMutate splitWordIntoLetters:stanzaWord andSpaceOut:NO];
    }
    
    // Add random word in letters
    else if(ABI(20) < 3) {
        returnArray = [ABMutate splitWordIntoLetters:randomWord andSpaceOut:NO];
    }
    
    // Add random word
    else if(true) {
        returnArray = @[[ABMutate randomWordWithMutationLevel:mutationLevel]];
    }
    
    return returnArray;
}



+ (ABScriptWord *) randomWordWithMutationLevel:(CGFloat)mutationLevel {
    
    int index = [ABState getCurrentStanza];
    CGFloat range = 10 + (mutationLevel * 4);
    int stanzaCount = [ABScript scriptStanzasCount];
    if(range > stanzaCount) range = stanzaCount - 1;
    int offset = floor(ABF(range)) - (floor(range / 2));
    int s = index + offset;
    
    if(s < [ABScript firstStanzaIndex]) s += [ABScript lastStanzaIndex];
    if(s > [ABScript lastStanzaIndex]) s -= [ABScript lastStanzaIndex];
    
    NSArray *stanza = [ABScript linesAtStanzaNumber:s];
    ABScriptWord *word = [ABScript randomScriptWordFromSet:[ABScript allWordsInLines:stanza]];
    return word;
}








/////////////
// HELPERS //
/////////////


+ (ABScriptWord *) fuseWordObjects:(NSArray *)objs {
    
    if([objs count] == 0) {
        ABScriptWord *sw = [ABScript trulyRandomWord];
        objs = @[sw];
    }
    
    NSMutableArray *text = [NSMutableArray array];
    ABScriptWord *first = objs[0];
    
    for (int i = 0; i < [objs count]; i++) {
        ABScriptWord *o = objs[i];
        [text addObject:o.text];
    }
    
    ABScriptWord *sw = [ABData getScriptWord:[text componentsJoinedByString:@""] withSourceStanza:first.sourceStanza];
    return sw;
}


+ (NSArray *) splitWordIntoLetters:(ABScriptWord *)word andSpaceOut:(BOOL)spaceOut; {
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *wordText = [word text];
    NSArray *characters = [word charArray];
    
    for (int i = 0; i < [characters count]; i++) {
        ABScriptWord *sw =  [ABData getScriptWord:characters[i] withSourceStanza:word.sourceStanza];
        if(i != 0 && !spaceOut) sw.marginLeft = NO;
        if(i != [wordText length] - 1 && !spaceOut) sw.marginRight = NO;
        [array addObject:sw];
    }
    
    return [NSArray arrayWithArray:array];
}


+ (NSArray *) sliceWordInHalf:(ABScriptWord *)word {
    
    NSArray *slices = [ABMutate sliceStringInHalf:word.text];
    if(slices == nil) return @[word];
    
    ABScriptWord *first = [ABData getScriptWord:slices[0] withSourceStanza:word.sourceStanza];
    ABScriptWord *second = [ABData getScriptWord:slices[1] withSourceStanza:word.sourceStanza];
    first.marginRight = NO;
    second.marginLeft = YES;
    
    return @[first, second];
}


// Index is start of second substring (ie, length of first)
+ (NSArray *) sliceString:(NSString *)string atIndex:(int)index {
    NSArray *chars = [string convertToArray];
    int len = (int)[chars count];
    NSString *one = [[chars subarrayWithRange:NSMakeRange(0, index)] componentsJoinedByString:@""];
    NSString *two = [[chars subarrayWithRange:NSMakeRange(index, len - index)] componentsJoinedByString:@""];
    return @[one, two];
}


+ (NSArray *) sliceStringInHalf:(NSString *)string {
    
    int length = (int)[[string convertToArray] count];
    if(length < 2) return nil;
    if(length == 2) {
        return [ABMutate sliceString:string atIndex:1];
    } else if(length == 3 || length == 4) {
        return [ABMutate sliceString:string atIndex:2];
    }
    
    int half = ceilf(length / 2);
    if(half > 4) half ++;
    if(half > 6) half ++;
    if(half > 9) half ++;
    if(half > 11) half ++;
    if(half > 13) half ++;
    
    return [ABMutate sliceString:string atIndex:half];
}


+ (NSString *) scrambleString:(NSString *)string {
    
    NSMutableArray *original = [NSMutableArray arrayWithArray:[string convertToArray]];
    NSMutableArray *new = [[NSMutableArray alloc] initWithArray:original copyItems:YES];
    [new shuffle];
    
    for(int i=0; i < [original count]; i++) {
        if(i == 0 || i == [original count] - 1 || ABI(2) == 0) {
            new[i] = original[i];
        }
    }
    
    return [new componentsJoinedByString:@""];
}


// kinda janky but works ok
+ (NSString *) cutFirstOrLastLetter: (NSString *)string {
    
    NSMutableArray *original = [NSMutableArray arrayWithArray:[string convertToArray]];
    int c = (int)[original count];
    
    if(c < 2) return nil;
    if(c < 4 && ABI(2 == 0)) {
        return [[ABMutate sliceString:string atIndex:c - 1] objectAtIndex:0];
    }
    if(c < 5 && ABI(2 == 0)) {
        return [[ABMutate sliceString:string atIndex:1] objectAtIndex:0];
    }
    return [[ABMutate sliceString:string atIndex:1] objectAtIndex:0];
}


+ (int) totalCharLengthOfWordObjs:(NSArray *)objs {
    int t = 0;
    for(int i=0; i < [objs count]; i++){
        ABScriptWord *o = objs[i];
        t += [o.text length];
        if(o.marginRight) t += 1;
    }
    return t;
}


+ (NSArray *) cutWordsOutOfTooLongLine:(NSArray *)line {
    
    int lineLength = [ABMutate totalCharLengthOfWordObjs:line];
    NSMutableArray *newLine = [NSMutableArray array];
    
    if(lineLength < 80) return line;
    int destroyOdds = 5 + ((lineLength - 70) / 8);
    
    for(int i=0; i<[line count]; i++){
        if(ABI(50) < destroyOdds) continue;
        [newLine addObject:[line objectAtIndex:i]];
    }
    
    return [NSArray arrayWithArray:newLine];
}





@end
