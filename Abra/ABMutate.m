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
#import "ABDictionary.h"

@implementation ABMutate

static ABMutate *ABMutateInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABMutateInstance == NULL) ABMutateInstance = [[ABMutate alloc] init];
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
            targetWord.sourceStanza = [ABState currentIndex];
        }
        returnArray = [ABMutate sliceWordInHalf:targetWord];
    }
    
    // Look for user-submitted text; if found, duplicate it
    else if(ABI(20) < 18 && [targetWord isGrafted]) {
        ABScriptWord *duplicate = [targetWord copy];
        if(ABI(2) == 0) {
            duplicate.isGrafted = NO;
            duplicate.sourceStanza = [ABState currentIndex];
        }
        returnArray = @[targetWord, duplicate];
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
        returnArray = [ABMutate splitWordIntoLetters:stanzaWord];
    }
    
    // Add random word in letters
    else if(ABI(20) < 3) {
        returnArray = [ABMutate splitWordIntoLetters:randomWord];
    }
    
    // Add random word
    else if(true) {
        returnArray = @[[ABMutate randomWordWithMutationLevel:mutationLevel]];
    }
    
    return returnArray;
}




+ (NSArray *) explodeOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABMutate alterOneWordInLine:line atIndex:index withMutationType:EXPLODE];
}

+ (NSArray *) mutateRandomWordInLine:(NSArray *)line {
    return [ABMutate mutateOneWordInLine:line atWordIndex:ABI((int)[line count])];
}

+ (NSArray *) pruneOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABMutate alterOneWordInLine:line atIndex:index withMutationType:CUT];
}

+ (NSArray *) multiplyOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABMutate alterOneWordInLine:line atIndex:index withMutationType:CLONE];
}

+ (NSArray *) graftOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABMutate alterOneWordInLine:line atIndex:index withMutationType:GRAFTWORD];
}

+ (NSArray *) mutateOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    int mutationLevel = [ABState checkMutationLevel];
    if(mutationLevel < 1 || (ABI(7) < 4)) {
        return [ABMutate alterOneWordInLine:line atIndex:index withMutationType:DICE];
    } else {
        return [ABMutate alterOneWordInLine:line atIndex:index withMutationType:RANDOM];
    }
}



+ (NSArray *) alterOneWordInLine:(NSArray *)line atIndex:(int)index withMutationType:(mutationType)type {
    
    ABScriptWord *oldWord = [line objectAtIndex:index];
    NSMutableArray *newLine = [NSMutableArray array];
    NSArray *newWords;
    
    if(type == DICE) {
        newWords = @[[ABMutate throwDiceCoefficient:oldWord]];
    } else if(type == RANDOM) {
        newWords = [ABMutate mutate:oldWord andLocalWords:line mutationLevel:5 lineLength:(int)[line count]];
    } else if(type == EXPLODE) {
        newWords = [ABMutate splitWordIntoLetters:oldWord];
    } else if(type == CUT) {
        newWords = @[];
    } else if(type == GRAFTWORD) {
        ABScriptWord *gw = [ABDictionary getWordToGraft];
        gw.sourceStanza = oldWord.sourceStanza;
        newWords = @[gw];
    } else if(type == CLONE) {
        newWords = @[oldWord, oldWord];
    }
    
    for(int i=0; i < [newWords count]; i ++) {
        ABScriptWord *w = [newWords objectAtIndex:i];
        w.morphCount = oldWord.morphCount + 1;
    }
    
    
    for(int l=0; l < [line count]; l ++) {
        if(l == index) {
            [newLine addObjectsFromArray:newWords];
        } else {
            [newLine addObject:[line objectAtIndex:l]];
        }
    }
    
    return [NSArray arrayWithArray:newLine];
    
}






+ (NSArray *) mutateLines:(NSArray *)stanza atMutationLevel:(int)mutationLevel {
    
    NSArray *targetStanza = stanza;
    NSMutableArray *newStanza = [[NSMutableArray alloc] init];
    NSArray *allTargetWords = [ABScript allWordsInLines:stanza];
    
    for(int l=0; l < [targetStanza count]; l ++) {
        
        NSArray *targetLine = [targetStanza objectAtIndex:l];
        NSMutableArray *newLine = [[NSMutableArray alloc] init];
        
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
    NSMutableArray *newStanza = [[NSMutableArray alloc] init];
    
    for(int l=0; l < [targetStanza count]; l ++) {
        
        NSArray *targetLine = [targetStanza objectAtIndex:l];
        NSArray *oldLine = ([oldStanza count] < l) ? [oldStanza objectAtIndex:l] : nil;
        NSMutableArray *newLine = [[NSMutableArray alloc] init];
        
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
    
    int index = [ABState currentIndex];
    
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



+ (ABScriptWord *) throwDiceCoefficient:(ABScriptWord *)word {
    
    NSArray *dice = [ABDictionary diceForKey:word.text];
    if(!dice) {
        NSLog(@">> Dice match not found: %@", word.text);
        return [ABScript trulyRandomWord];
    }
    
    ABScriptWord *new = [ABScriptWord copyScriptWord:word];
    
    @try {
        int range = 4 + (word.morphCount * 7);
        int max = (int)[dice count];
        if(range > max) range = max;
        int randomIndex = ABI(range);
        NSString *w = [dice objectAtIndex:randomIndex];
        if(!w) {
            NSLog(@">> Problematic dice match for: %@", word.text);
            return word;
        }
        if(![ABDictionary scriptWord:w]) [ABDictionary addToScriptWords:w];
        NSLog(@"* Dice: %@ -> %@ (%i)", word.text, [dice objectAtIndex:randomIndex], word.morphCount);
        new = [ABDictionary scriptWord:w];
    }
    @catch (NSException *exception) {
        NSLog(@">> DICE ERROR: %@", word.text);
    }
    @finally {
        // To make changes more colorful sooner, change this last digit:
        new.sourceStanza = word.sourceStanza + word.morphCount + 2;
        return new;
    }
}



+ (ABScriptWord *) fuseWordObjects:(NSArray *)objs {
    
    if([objs count] == 0) {
        ABScriptWord *sw = [ABScript trulyRandomWord];
        objs = @[sw];
    }
    
    NSMutableArray *text = [[NSMutableArray alloc] init];
    ABScriptWord *first = objs[0];
    
    for (int i = 0; i < [objs count]; i++) {
        ABScriptWord *o = objs[i];
        [text addObject:o.text];
    }
    
    ABScriptWord *sw = [[ABScriptWord alloc] initWithText:[text componentsJoinedByString:@""] sourceStanza:first.sourceStanza];
    return sw;
}


+ (NSArray *) splitWordIntoLetters:(ABScriptWord *)word {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *wordText = [word text];
    
    for (int i = 0; i < [wordText length]; i++) {
        NSString *ch = [wordText substringWithRange:NSMakeRange(i, 1)];
        ABScriptWord *sw = [[ABScriptWord alloc] initWithText:ch sourceStanza:word.sourceStanza];
        if(i != 0) sw.marginLeft = NO;
        if(i != [wordText length] - 1) sw.marginRight = NO;
        
        [array addObject:sw];
    }
    return [NSArray arrayWithArray:array];
}


+ (NSArray *) sliceWordInHalf:(ABScriptWord *)word {
    
    NSArray *letters = [ABMutate splitWordIntoLetters:word];
    
    NSMutableArray *firstHalf = [[NSMutableArray alloc] init];
    NSMutableArray *secondHalf = [[NSMutableArray alloc] init];
    BOOL cut = NO;
    
    for (int i = 0; i < [letters count]; i++) {
        if(cut == NO) {
            [firstHalf addObject:[letters objectAtIndex:i]];
            if(ABI((int)[letters count]) < 1) cut = YES;
            if(i == [letters count] - 2) cut = YES;
        } else {
            [secondHalf addObject:[letters objectAtIndex:i]];
        }
    }
    
    ABScriptWord *first = [ABMutate fuseWordObjects:firstHalf];
    ABScriptWord *second = [ABMutate fuseWordObjects:secondHalf];
    first.marginRight = NO;
    second.marginLeft = YES;
    
    return @[first, second];
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
    NSMutableArray *newLine = [[NSMutableArray alloc] init];
    
    if(lineLength < 80) return line;
    int destroyOdds = 5 + ((lineLength - 70) / 8);
    
    for(int i=0; i<[line count]; i++){
        if(ABI(50) < destroyOdds) continue;
        [newLine addObject:[line objectAtIndex:i]];
    }
    
    return [NSArray arrayWithArray:newLine];
}




@end
