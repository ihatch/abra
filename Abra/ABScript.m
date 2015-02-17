//
//  ABScripts.m
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABScript.h"
#import "ABState.h"
#import "ABConstants.h"
#import "ABScriptWord.h"

typedef enum { DICE, RANDOM, EXPLODE, CUT, CLONE } mutationType;

@implementation ABScript

NSString *dataFilePath;
NSMutableArray *userFileData;
NSMutableArray *userWords;

NSArray *script;
NSArray *wordList;
NSMutableDictionary *diceDictionary;
NSMutableDictionary *abScriptWordsDictionary;
NSMutableArray *allWordObjs;
int stanzaCount;

NSFileManager *fileManager;
NSString *docsDir;
NSArray *dirPaths;

static ABScript *ABScriptInstance = NULL;



+ (void)initialize {
    @synchronized(self) {
        
        if (ABScriptInstance == NULL) ABScriptInstance = [[ABScript alloc] init];
        
        allWordObjs = [[NSMutableArray alloc] init];
        
        [ABScriptInstance parseScriptFile];
        [ABScriptInstance parseWordList];
        [ABScriptInstance parseDiceCoefficientDictionary];
    }
}





/////////////////////////////////////
// PARSE FILES + BUILD DATA ARRAYS //
/////////////////////////////////////


- (void) initDataStorage {
    
    fileManager = [NSFileManager defaultManager];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the data file
    dataFilePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"data.archive"]];
    
    // Check if the file already exists
    if ([fileManager fileExistsAtPath: dataFilePath]) {
        userFileData = [NSKeyedUnarchiver unarchiveObjectWithFile: dataFilePath];
        
        if([userFileData count] > 0) {
            userWords = userFileData[0];
        } else {
            userWords = [NSMutableArray array];
        }
        
    }
}



// Just strings-- not word objs
- (void) parseWordList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wordList" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    wordList = [rawText componentsSeparatedByString:@"\n"];
}



// Dice coefficient lookiup table
- (void) parseDiceCoefficientDictionary {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dice" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *entries = [rawText componentsSeparatedByString:@"\n"];
    diceDictionary = [NSMutableDictionary dictionary];
    for (int i = 0; i < [entries count]; i++) {
        NSArray *terms = [entries[i] componentsSeparatedByString:@" "];
        NSString *key = terms[0];
        NSMutableArray *others = [NSMutableArray array];
        for (int j = 1; j < [terms count]; j++) {
            [others addObject:terms[j]];
        }
        [diceDictionary setObject:[NSArray arrayWithArray:others] forKey:key];
    }
}



// Create nested structure of word objects
- (void) parseScriptFile {
    
    abScriptWordsDictionary = [NSMutableDictionary dictionary];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *rawStanzas = [rawText componentsSeparatedByString:@"\n\n\n"];

    NSMutableArray *stanzas = [NSMutableArray array];
    NSMutableArray *stanzaObjs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [rawStanzas count]; i++) {
        
        NSMutableArray *lines = [NSMutableArray arrayWithArray: [rawStanzas[i] componentsSeparatedByString:@"\n"]];
        NSMutableArray *linesObjs = [[NSMutableArray alloc] init];
        
        // Make certain punctuations their own word objects
        for (int j = 0; j < [lines count]; j++) {
            lines[j] = [lines[j] stringByReplacingOccurrencesOfString:@"-" withString:@" - "];
            lines[j] = [lines[j] stringByReplacingOccurrencesOfString:@", " withString:@" , "];
            lines[j] = [lines[j] stringByReplacingOccurrencesOfString:@"’s " withString:@" ’s "];
        }
        
        // Remove any empty lines in each stanza
        [lines removeObject:@""];
        
        // Split into words
        for (int j = 0; j < [lines count]; j++) {
            
            [linesObjs addObject:[[NSMutableArray alloc] init]];
            
            lines[j] = [lines[j] componentsSeparatedByString:@" "];
            ABScriptWord *lastWordObj = nil;
            BOOL connectNextWord = NO;
            
            for (int z = 0; z < [lines[j] count]; z++) {
                
                BOOL connectLastAndCurrent = NO;

                NSString *text = lines[j][z];
                
                if([text isEqualToString:@"estropheeeeeeeeeeeeeeeeeeeeeeeees"]) {
                    NSArray *parts = [self specialHandlingForCrazyEeeWordWithSourceStanza:i];
                    [allWordObjs addObjectsFromArray:parts];
                    [linesObjs[j] addObjectsFromArray:parts];
                    continue;
                }
                
                ABScriptWord *sw = [[ABScriptWord alloc] initWithText:text sourceStanza:i];

                if(connectNextWord) {
                    connectLastAndCurrent = YES;
                    connectNextWord = NO;
                }

                if([text isEqualToString:@","] ||
                   [text isEqualToString:@"’s"]) {
                    sw.marginLeft = NO;
                    connectLastAndCurrent = YES;
                }

                if([text isEqualToString:@"-"]) {
                    sw.marginLeft = NO;
                    sw.marginRight = NO;
                    connectLastAndCurrent = YES;
                    connectNextWord = YES;
                }
                
                if(connectLastAndCurrent && lastWordObj != nil) {
                    [lastWordObj addRightSister:text];
                    [sw addLeftSister:[lastWordObj text]];
                }
                
                lastWordObj = sw;
                [allWordObjs addObject:sw];
                [linesObjs[j] addObject:sw];
                [abScriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];

            }
        }
        
        // Add the cleaned and parsed array of word objects
        stanzaObjs[i] = [NSArray arrayWithArray:linesObjs];
        stanzas[i] = [NSArray arrayWithArray:lines];
    }
    
    
    
    
    script = [NSArray arrayWithArray:stanzaObjs];
    stanzaCount = (int)[stanzas count];
}



- (NSArray *) specialHandlingForCrazyEeeWordWithSourceStanza:(int)stanza {
    
    ABScriptWord *sw1 = [[ABScriptWord alloc] initWithText:@"estroph" sourceStanza:stanza];
    ABScriptWord *sw2 = [[ABScriptWord alloc] initWithText:@"eeeeeeeeeeeeeeeeeeeeeeeee" sourceStanza:stanza];
    ABScriptWord *sw3 = [[ABScriptWord alloc] initWithText:@"s" sourceStanza:stanza];

    sw1.marginRight = NO;
    sw2.marginLeft = NO; sw2.marginRight = NO;
    sw3.marginLeft = NO;
    
    return @[sw1, sw2, sw3];
}














/////////////
// GETTERS //
/////////////


+ (NSArray *) linesAtStanzaNumber:(int)stanza {
    if(stanza >= [script count]) return script[[script count] - 1];
    if(stanza < 0) return script[0];
    return script[stanza];
}

+ (NSArray *) wordsAtStanzaNumber:(int)stanza andLineNumber:(int)line {
    if(script[stanza][line]) {
        return script[stanza][line];
    } else {
        return [ABScript emptyLine];
    }
}

+ (NSArray *) emptyLine {
    return @[];
}

+ (int) lastStanzaIndex {
    return (int)[script count] - 1;
}

+ (int) firstStanzaIndex {
    return 0;
}

+ (int) scriptStanzasCount {
    return stanzaCount;
}

+ (int) totalStanzasCount {
    return stanzaCount + 1;
}



+ (NSArray *) allWordsInLines:(NSArray *)stanza {
    NSMutableArray *words = [NSMutableArray array];
    for(int l=0; l < [stanza count]; l ++) {
        NSArray *line = [stanza objectAtIndex:l];
        for(int w=0; w < [line count]; w ++) {
            [words addObject:[line objectAtIndex:w]];
        }
    }
    return [NSArray arrayWithArray:words];
}



+ (ABScriptWord *) randomScriptWordFromSet:(NSArray *)words {
    return [words objectAtIndex:ABI((int)[words count])];
}



+ (ABScriptWord *) trulyRandomWord {
    int randomIndex = arc4random() % [allWordObjs count];
    return [allWordObjs objectAtIndex:randomIndex];
}











///////////////////////
// BASIC LINE MIXING //
///////////////////////


+ (NSArray *) mixStanzaLines:(NSArray *)oldStanzaLines withStanzaAtIndex:(int)stanzaIndex {
    
    NSArray *lines1 = oldStanzaLines;
    NSArray *lines2 = script[stanzaIndex];
    
    NSMutableArray *remixStanza = [[NSMutableArray alloc] init];
    
    for(int l=0; l<[lines1 count]; l++) {
        
        NSMutableArray *remixLine = [[NSMutableArray alloc] init];
        
        NSArray *line1 = [lines1 objectAtIndex:l];
        NSArray *line2 = [lines2 objectAtIndex:l];
        
        int c1 = (int)[line1 count];
        int c2 = (int)[line2 count];
        
        int larger = (c1 > c2) ? c1 : c2;
        
        for(int i=0; i < larger; i++) {
            int r = ABI(2);
            
            if((r == 0 && i < c1)) {
                [remixLine addObject:[line1 objectAtIndex:i]];
            } else if((r == 1 && i < c2)) {
                [remixLine addObject:[line2 objectAtIndex:i]];
            }
        }
        
        [remixStanza addObject:remixLine];
    }
    
    return [NSArray arrayWithArray:remixStanza];
}












///////////////
// MUTATIONS //
///////////////


+ (NSArray *) mutate:(ABScriptWord *)targetWord andLocalWords:(NSArray *)localWords mutationLevel:(int)mutationLevel lineLength:(int)lineLength {
    
    NSArray *returnArray;
    ABScriptWord *stanzaWord = [ABScript randomScriptWordFromSet:localWords];
    ABScriptWord *randomWord = (ABI(4) == 0) ? [ABScript trulyRandomWord] :
                                               [ABScript randomWordWithMutationLevel:mutationLevel];

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
        returnArray = [ABScript sliceWordInHalf:targetWord];
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
        returnArray = [ABScript sliceWordInHalf:stanzaWord];
    }
    
    // Random halves of truly random word
    else if(ABI(28) < 2 && [[randomWord text] length] > 1) {
        returnArray = [ABScript sliceWordInHalf:randomWord];
    }
    
    // Add old word in letters
    else if(ABI(20) < 3) {
        returnArray = [ABScript splitWordIntoLetters:stanzaWord];
    }
    
    // Add random word in letters
    else if(ABI(20) < 3) {
        returnArray = [ABScript splitWordIntoLetters:randomWord];
    }
    
    // Add random word
    else if(true) {
        returnArray = @[[ABScript randomWordWithMutationLevel:mutationLevel]];
    }
    
    return returnArray;
}




+ (NSArray *) explodeOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABScript mutateOneWordInLine:line atIndex:index withMutationType:EXPLODE];
}


+ (NSArray *) mutateRandomWordInLine:(NSArray *)line {
    return [ABScript mutateOneWordInLine:line atWordIndex:ABI((int)[line count])];
}


+ (NSArray *) mutateOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    int mutationLevel = [ABState checkMutationLevel];
    if(mutationLevel < 1 || (ABI(7) < 4)) {
        return [ABScript mutateOneWordInLine:line atIndex:index withMutationType:DICE];
    } else {
        return [ABScript mutateOneWordInLine:line atIndex:index withMutationType:RANDOM];
    }
}

+ (NSArray *) pruneOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABScript mutateOneWordInLine:line atIndex:index withMutationType:CUT];
}

+ (NSArray *) multiplyOneWordInLine:(NSArray *)line atWordIndex:(int)index {
    return [ABScript mutateOneWordInLine:line atIndex:index withMutationType:CLONE];
}



+ (NSArray *) mutateOneWordInLine:(NSArray *)line atIndex:(int)index withMutationType:(mutationType)type {
    
    ABScriptWord *oldWord = [line objectAtIndex:index];
    NSMutableArray *newLine = [NSMutableArray array];
    NSArray *newWords;
    
    if(type == DICE) {
        newWords = @[[ABScript throwDiceCoefficient:oldWord]];
    } else if(type == RANDOM) {
        newWords = [ABScript mutate:oldWord andLocalWords:line mutationLevel:5 lineLength:(int)[line count]];
    } else if(type == EXPLODE) {
        newWords = [ABScript splitWordIntoLetters:oldWord];
    } else if(type == CUT) {
        newWords = @[];
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
        
        int lineLength = [ABScript totalCharLengthOfWordObjs:targetLine];
        
        for(int w=0; w < [targetLine count]; w ++) {
            
            ABScriptWord *targetWord = [targetLine objectAtIndex:w];
            if([targetWord.text isEqualToString:@""]) continue;

            // Allow target word to pass unimpeded?
            if(ABI(32) > mutationLevel && targetWord.isGrafted == NO) {
                [newLine addObject:targetWord];
                continue;
            }
            
            // Add a mutation
            [newLine addObjectsFromArray:[ABScript mutate:targetWord andLocalWords:allTargetWords mutationLevel:mutationLevel lineLength:lineLength]];
        }
        
        NSArray *filteredLine = [ABScript cutWordsOutOfTooLongLine:newLine];
        [newStanza addObject:filteredLine];
    }
    
    NSArray *result = [NSArray arrayWithArray:newStanza];
    return result;
}





+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel {
    return [ABScript remixStanza:stanza andOldStanza:oldStanza atMutationLevel:mutationLevel andLimitTo:0];
}





+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel andLimitTo:(int)limit {
    
    int changes = 0;
    NSArray *targetStanza = stanza;
    NSMutableArray *newStanza = [[NSMutableArray alloc] init];
    
    for(int l=0; l < [targetStanza count]; l ++) {
        
        NSArray *targetLine = [targetStanza objectAtIndex:l];
        NSArray *oldLine = ([oldStanza count] < l) ? [oldStanza objectAtIndex:l] : nil;
        NSMutableArray *newLine = [[NSMutableArray alloc] init];
        
        int lineLength = [ABScript totalCharLengthOfWordObjs:targetLine];
        
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
            [newLine addObjectsFromArray:[ABScript mutate:targetWord andLocalWords:targetLine mutationLevel:mutationLevel lineLength:lineLength]];
        }
        
        NSArray *filteredLine = [ABScript cutWordsOutOfTooLongLine:newLine];
        [newStanza addObject:filteredLine];
    }
    
    NSArray *result = [NSArray arrayWithArray:newStanza];
    return result;
}







+ (ABScriptWord *) randomWordWithMutationLevel:(CGFloat)mutationLevel {
    
    int index = [ABState currentIndex];

    CGFloat range = 10 + (mutationLevel * 4);
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
    NSLog(@"WORD: %@ %i", word.text, word.morphCount);
    if(![diceDictionary objectForKey:word.text]) return word;
    ABScriptWord *new = [ABScriptWord copyScriptWord:word];
    @try {
        NSArray *dice = [diceDictionary objectForKey:word.text];
        int range = 4 + (word.morphCount * 4);
        if(range > ((int)[dice count])) range = (int)([dice count]);
        int randomIndex = ABI(range);
        if(![dice objectAtIndex:randomIndex]) return word;
        if(![abScriptWordsDictionary objectForKey:[dice objectAtIndex:randomIndex]]) return word;
        NSLog(@"...?: %@", [dice objectAtIndex:randomIndex]);
        new = [abScriptWordsDictionary objectForKey:[dice objectAtIndex:randomIndex]];
    }
    @catch (NSException *exception) {
        NSLog(@">> ERROR: %@", word.text);
    }
    @finally {
        new.sourceStanza = word.sourceStanza + word.morphCount;
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
    
    NSArray *letters = [ABScript splitWordIntoLetters:word];

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
    
    ABScriptWord *first = [ABScript fuseWordObjects:firstHalf];
    ABScriptWord *second = [ABScript fuseWordObjects:secondHalf];
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
    
    int lineLength = [ABScript totalCharLengthOfWordObjs:line];
    NSMutableArray *newLine = [[NSMutableArray alloc] init];
    
    if(lineLength < 80) return line;
    int destroyOdds = 5 + ((lineLength - 70) / 8);
    
    for(int i=0; i<[line count]; i++){
        if(ABI(50) < destroyOdds) continue;
        [newLine addObject:[line objectAtIndex:i]];
    }

    return [NSArray arrayWithArray:newLine];
}




//////////////
// GRAFTING //
//////////////


+ (NSArray *) parseGraftTextIntoScriptWords:(NSString *)text {
    
    NSArray *words = [text componentsSeparatedByString:@" "];
    NSMutableArray *scriptWords = [NSMutableArray array];
    
    for(int i=0; i<[words count]; i++) {
        ABScriptWord *sw = [[ABScriptWord alloc] initWithText:words[i] sourceStanza:-1];
        sw.isGrafted = YES;
        [scriptWords addObject:sw];
    }
    return [NSArray arrayWithArray:scriptWords];
}


+ (NSArray *) graftText:(NSArray *)scriptWords intoStanzaLines:(NSArray *)stanzaLines {

    int slc = (int)[stanzaLines count];
    int gtc = (int)[scriptWords count];
    
    NSMutableArray *mixedLines = [NSMutableArray array];
    for(int l=0; l<slc; l++) {
        NSMutableArray *line = [NSMutableArray array];
        BOOL spent = NO;
        for(int i=0; i < [stanzaLines[l] count]; i++) {
            if(spent == NO && ABI(11) == 0) {
                ABScriptWord *w = [ABScriptWord copyScriptWord:scriptWords[ABI(gtc)]];
                w.isGrafted = YES;
                [line addObject:w];
            }
            [line addObject:stanzaLines[l][i]];
        }
        [mixedLines addObject:line];
    }
    
    return [NSArray arrayWithArray:mixedLines];
}



// Modified to use individual letters rather than bigrams
+ (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t {
    
	// Verifying the input:
	if (s == nil || t == nil) return 0;

	// Quick check to catch identical objects:
	if ([s isEqualToString:t]) return 1;
    
    // avoid exception for single character searches
    if ([s length] < 2 || [t length] < 2) return 0;
    
	// Create the substrings for string s:
	int n = (int)[s length] - 1;
    NSMutableArray *sPairs = [[NSMutableArray alloc] initWithCapacity:n];
	for (int i = 0; i <= n; i ++) {
		[sPairs addObject:@([s characterAtIndex:i])];
    }

	// Create the substrings for string t:
    int m = (int)[t length] - 1;
	NSMutableArray *tPairs = [[NSMutableArray alloc] initWithCapacity:m];
	for (int i = 0; i <= m; i++) {
		[tPairs addObject:@([t characterAtIndex:i])];
    }
    
	// Sort the substrings:
	NSArray *sSortedPairs = [sPairs sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
	NSArray *tSortedPairs = [tPairs sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    
	// Count the matches:
	int matches = 0, i = 0, j = 0;
	while (i < n && j < m) {
        NSComparisonResult result = [[sSortedPairs objectAtIndex:i] compare:[tSortedPairs objectAtIndex:j]];
		if ([[sSortedPairs objectAtIndex:i] isEqualToString: [tSortedPairs objectAtIndex:j]]) {
			matches += 2;
			i++;
			j++;
		} else if (result == NSOrderedAscending) {
			i++;
		} else {
			j++;
        }
    }
	return (CGFloat) matches / (n + m);
}


@end














/*
 
 with bigrams::
 
 
 - (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t {
 
 // Verifying the input:
 if (s == nil || t == nil) return 0;
 
 // Quick check to catch identical objects:
 if ([s isEqualToString:t]) return 1;
 
 // avoid exception for single character searches
 if ([s length] < 2 || [t length] < 2) return 0;
 
 // Create the substrings for string s:
 int n = [s length] - 1;
 NSMutableArray *sPairs = [[NSMutableArray alloc] initWithCapacity:n];
 for (int i = 0; i <= n - 1; i ++) {
 [sPairs addObject:[s substringWithRange:NSMakeRange(i, 2)]];
 }
 
 // Create the substrings for string t:
 int m = [t length] - 1;
 NSMutableArray *tPairs = [[NSMutableArray alloc] initWithCapacity:m];
 for (int i = 0; i <= m - 1; i++) {
 [tPairs addObject:[t substringWithRange:NSMakeRange(i, 2)]];
 }
 
 // Sort the substrings:
 NSArray *sSortedPairs = [sPairs sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
 NSArray *tSortedPairs = [tPairs sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
 
 // Count the matches:
 int matches = 0, i = 0, j = 0;
 while (i < n && j < m) {
 NSComparisonResult result = [[sSortedPairs objectAtIndex:i] compare:[tSortedPairs objectAtIndex:j]];
 if ([[sSortedPairs objectAtIndex:i] isEqualToString: [tSortedPairs objectAtIndex:j]]) {
 matches += 2;
 i++;
 j++;
 } else if (result == NSOrderedAscending) {
 i++;
 } else {
 j++;
 }
 }
 return (CGFloat) matches / (n + m);
 }
 
*/
