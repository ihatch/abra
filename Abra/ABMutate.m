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


// Method to split string that works with extended chars (emoji)
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




// PRIVATE
@interface ABMutate ()

+ (NSArray *) alterOneWord:(ABScriptWord *)oldWord inLine:(NSArray *)line withMutationType:(mutationType)type;

@end



@implementation ABMutate

UITextChecker *textChecker;

static ABMutate *ABMutateInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABMutateInstance == NULL) ABMutateInstance = [[ABMutate alloc] init];
        textChecker = [[UITextChecker alloc] init];
    }
}





+ (NSArray *) mutate:(ABScriptWord *)targetWord andLocalWords:(NSArray *)localWords mutationLevel:(int)mutationLevel lineLength:(int)lineLength {
    
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
        ABScriptWord *duplicate = [targetWord copy];
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




+ (NSArray *) explodeWord:(ABScriptWord *)sw {
    return [ABMutate alterOneWord:sw inLine:nil withMutationType:EXPLODE];
}

+ (NSArray *) multiplyWord:(ABScriptWord *)sw {
    return [ABMutate alterOneWord:sw inLine:nil withMutationType:CLONE];
}

+ (NSArray *) graftWord:(ABScriptWord *)sw {
    return [ABMutate alterOneWord:sw inLine:nil withMutationType:GRAFTWORD];
}

+ (NSArray *) mutateWord:(ABScriptWord *)sw inLine:(NSArray *)line {
    mutationType type = RANDOM;
    if([ABState checkMutationLevel] < 1 || (ABI(7) < 4)) type = DICE;
    return [ABMutate alterOneWord:sw inLine:line withMutationType:type];
}


// Returns NEW words, not entire line. Line is passed in just for context and using that info for effects
+ (NSArray *) alterOneWord:(ABScriptWord *)oldWord inLine:(NSArray *)line withMutationType:(mutationType)type {
    
    NSArray *newWords;
    
    if(type == DICE) {
        
        // TODO: check for emoji precedent

        NSString *emojiTransform = [ABEmoji emojiWordTransform:oldWord.text];
        ABScriptWord *sw;
        
        if(emojiTransform == nil) sw = [ABMutate attemptMatchBySpellCheck:oldWord];

        if(emojiTransform != nil && ABI(25) == 0) {
            newWords = @[[ABData getScriptWord:emojiTransform]];

        } else if(sw != nil) {
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
        
    } else if(type == EXPLODE) {
        newWords = [ABMutate splitWordIntoLetters:oldWord andSpaceOut:NO];
        
    } else if(type == GRAFTWORD) {
        ABScriptWord *gw = [ABData getWordToGraft];
        gw.sourceStanza = oldWord.sourceStanza;
        newWords = @[gw];
        
    } else if(type == CLONE) {
        newWords = @[oldWord, oldWord];
    }
    
    for(int i=0; i < [newWords count]; i ++) {
        ABScriptWord *w = [newWords objectAtIndex:i];
        w.morphCount = oldWord.morphCount + 1;
    }
    
    return [NSArray arrayWithArray:newWords];
}





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
    
    int changes = 0;
    NSArray *targetStanza = stanza;
    NSMutableArray *newStanza = [NSMutableArray array];
    
    for(int l=0; l < [targetStanza count]; l ++) {
        
        NSArray *targetLine = [targetStanza objectAtIndex:l];
        NSArray *oldLine = ([oldStanza count] < l) ? [oldStanza objectAtIndex:l] : nil;
        NSMutableArray *newLine = [NSMutableArray array];
        
        int lineLength = [ABMutate totalCharLengthOfWordObjs:targetLine];
        
        for(int w=0; w < [targetLine count]; w ++) {
            
            ABScriptWord *targetWord = [targetLine objectAtIndex:w];
            
            // Allow target new word to pass unimpeded?
            if((ABI(32) > mutationLevel && targetWord.isGrafted == NO) ||
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
    

    // TODO :: RETURN TO THIS
    
    
    // try cutting a letter...
    NSString *cut = [ABMutate cutFirstOrLastLetter:word.text];
    NSArray *cuts = [ABMutate spellCheck:cut];
    
    if([cuts count]) return [ABData getScriptWord:simple[0] withSourceStanza:word.sourceStanza];
    
    // okay, try a scrambler...
    NSString *scrambled = [ABMutate scrambleString:word.text];
    NSArray *scram = [ABMutate spellCheck:scrambled];
    
    if([scram count]) return [ABData getScriptWord:scram[0] withSourceStanza:word.sourceStanza];
    
    // If not, make a slice of it, then spellcheck that
    NSArray *slices = [ABMutate sliceStringInHalf:word.text];
    if(slices) DDLogInfo(@"Slice: %@ | %@", slices[0], slices[1]);
    else DDLogInfo(@"Slice fail :( %@", word.text);
    NSString *slice;
    NSArray *matches;
    
    if(slices == nil) {
        DDLogWarn(@"Spell check failed for %@ !", word.text);
        return nil;
    }
    
    slice = [slices objectAtIndex:0];

    if([slice length] > 2) {
        matches = [ABMutate spellCheck: slice];
        if([matches count] > 0) {
            ABScriptWord *sw = [ABData getScriptWord:matches[0] withSourceStanza:word.sourceStanza];
            return sw;
        }
    }

    DDLogWarn(@"Spell check really really failed for %@ ! :(", word.text);
    return nil;
    
}



+ (ABScriptWord *) throwDiceCoefficient:(ABScriptWord *)word {
    
    NSArray *dice = [ABDice diceForKey:word.text];
    if([dice count] == 0) {
        DDLogWarn(@">> Dice match not found: %@ - ", word.text);
        // TODO: simple pattern analysis to swap in, say, emoji for emoji
        // or text for emoji based on emoji.h (or mutate that text)
        // or a string similarly sized in char count
        ABScriptWord *result = [ABMutate attemptMatchBySpellCheck:word];
        if(result != nil) {
            DDLogWarn(@">> Found match by spell check: %@ -> %@ ", word.text, result.text);
            return result;
        }
        
        DDLogWarn(@">> Spell check match failed too! Returning something random :( - %@", word.text);
        return [ABScript trulyRandomWord];
    }
    
    ABScriptWord *new = [ABScriptWord copyScriptWord:word];
    
    @try {
        int range = 4 + (word.morphCount * 3);
        int max = (int)[dice count];
        if(range > max) range = max;
        if(max > 0 && word.morphCount < 2 && word.isGrafted) {
            int randomIndex = ABI(range);
            NSString *w = [dice objectAtIndex:randomIndex];
            if(!w) {
                DDLogWarn(@">> Problematic dice match for: %@", word.text);
                return word;
            }
            DDLogVerbose(@"* Dice: %@ -> %@ (%i)", word.text, [dice objectAtIndex:randomIndex], word.morphCount);
            new = [ABData getScriptWord:w];
            
        } else if(range == max && ABI(5) == 0) {
            new = [ABData getPastGraftWord];
            if(!new) new = [ABScript trulyRandomWord];
            DDLogWarn(@"!!! Random (radical) mutation: %@ -> %@", word.text, new.text);
            new.morphCount = (int)(new.morphCount / 3);
        } else {
            int randomIndex = ABI(range);
            NSString *w = [dice objectAtIndex:randomIndex];
            if(!w) {
                DDLogWarn(@">> Problematic dice match for: %@", word.text);
                return word;
            }
            DDLogVerbose(@"* Dice: %@ -> %@ (%i)", word.text, [dice objectAtIndex:randomIndex], word.morphCount);
            new = [ABData getScriptWord:w];
        }
    }
    @catch (NSException *exception) {
        DDLogError(@">> DICE ERROR: %@", word.text);
    }
    @finally {
        // To make changes more colorful sooner, change this last digit:
        new.sourceStanza = word.sourceStanza + ABI(word.morphCount) + 1;
        return new;
    }
}



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



+ (NSString *) cutFirstOrLastLetter: (NSString *)string {
    NSMutableArray *original = [NSMutableArray arrayWithArray:[string convertToArray]];
    int c = (int)[original count];
    if(c < 2) return nil;
    if(c < 4 && ABI(2 == 0)) {
        return [[ABMutate sliceString:string atIndex:c - 1] objectAtIndex:0];
    }
    
    // TODO: RETURN TO THIS
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
