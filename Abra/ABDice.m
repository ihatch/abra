//
//  ABDice.m
//  
//
//  Created by Ian Hatcher on 1/18/15.
//
//  Handles word similarity indices. The name is a reference to Dice coefficient, the starting point for this code.


#import "ABDice.h"
#import "ABData.h"
#import "ABConstants.h"
#import "NSString+ABExtras.h"


@implementation ABDice

NSMutableDictionary *charArrayCache;
NSMutableDictionary *diceDictionary;
NSMutableDictionary *diceAdditionsDictionary;
NSMutableDictionary *coreDiceDictionaryBackup;
NSMutableDictionary *oneWayAdditionsDictionary;





//////////////////
// INIT / RESET //
//////////////////

+ (void) setDiceDictionary:(NSMutableDictionary *)dict {
    diceDictionary = dict;
    coreDiceDictionaryBackup = [[NSMutableDictionary alloc] initWithDictionary:diceDictionary copyItems:YES];
    [ABDice loadErrataAndAddToDictionary];
    [ABDice loadConstWordsAndAddToDictionary];
    [ABDice initCacheWithLexicon:[diceDictionary allKeys]];
}


+ (void) setDiceAdditions:(NSDictionary *)dict {
    DDLogInfo(@"Dice additions: adding %lu entries", (unsigned long)[[dict allKeys] count]);
    diceAdditionsDictionary = [NSMutableDictionary dictionary];
    [ABDice updateCacheWithLexicon:[dict allKeys]];
    for (NSString *key in dict) {
        [diceDictionary setObject:[dict objectForKey:key] forKey:key];
    }
    diceAdditionsDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
}

// Quick fix to add Russian/Greek support. Won't work for languages that overlap w the English alphabet
+ (void) addNonEnglishLanguageDiceDictionary:(NSDictionary *)dict andLangString:(NSString *)langString {
    DDLogInfo(@"Additional language: %@ - adding %lu entries", langString, (unsigned long)[[dict allKeys] count]);
    [ABDice updateCacheWithLexicon:[dict allKeys]];
    for (NSString *key in dict) {
        [diceDictionary setObject:[dict objectForKey:key] forKey:key];
    }
}

+ (void) generateDiceDictionary {
    DDLogInfo(@"%@", @"Dice dictionary: generating ...");
    diceDictionary = [NSMutableDictionary dictionaryWithDictionary:[ABDice topCoreMatchesForLexicon:[ABData loadWordList]]];
    DDLogInfo(@"%@", @"Dice dictionary: done generating.");
    [ABDice loadErrataAndAddToDictionary];
}


+ (void) addEntries:(NSArray *)entries toDictionary:(NSMutableDictionary *)dictionary {
    int entriesCount = (int)[entries count];
    for (int i = 0; i < entriesCount; i++) {
        NSArray *terms = [entries[i] componentsSeparatedByString:@" "];
        NSString *key = terms[0];
        NSMutableArray *others = [NSMutableArray array];
        int termsCount = (int)[terms count];
        for (int j = 1; j < termsCount; j++) {
            [others addObject:terms[j]];
        }
        [dictionary setObject:[NSArray arrayWithArray:others] forKey:key];
    }
}

+ (void) loadErrataAndAddToDictionary {
    DDLogInfo(@"%@", @"Dice errata: loading ...");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dice_errata" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *entries = [rawText componentsSeparatedByString:@"\n"];
    [ABDice addEntries:entries toDictionary:diceDictionary];
    DDLogInfo(@"%@", @"Dice errata: done.");
}


+ (void) loadConstWordsAndAddToDictionary {
    oneWayAdditionsDictionary = [NSMutableDictionary dictionary];
    DDLogInfo(@"%@", @"Dice const words: loading ...");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dice_const" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *entries = [rawText componentsSeparatedByString:@"\n"];
    [ABDice addEntries:entries toDictionary:oneWayAdditionsDictionary];
    DDLogInfo(@"%@", @"Dice const words: done.");
}


+ (void) resetLexicon {
    diceDictionary = [[NSMutableDictionary alloc] initWithDictionary:coreDiceDictionaryBackup copyItems:YES];
    [ABDice loadErrataAndAddToDictionary];
    diceAdditionsDictionary = [NSMutableDictionary dictionary];
    [ABData saveDiceAdditions:diceAdditionsDictionary];
}






///////////
// CACHE //
///////////

+ (void) initCacheWithLexicon:(NSArray *)lexicon {
    NSMutableDictionary *arrays = [NSMutableDictionary dictionary];
    for(NSString * s in lexicon) {
        NSMutableArray *chars = [s convertToMutableArray];
        if([chars count] < 1 || s == nil) continue;
        if([chars count] > 1) [chars sortUsingSelector:@selector(compare:)];
        [arrays setObject:[NSArray arrayWithArray:chars] forKey:s];
    }
    
    charArrayCache = arrays;
}

+ (void) updateCacheWithLexicon:(NSArray *)lexicon {
    NSMutableDictionary *arrays = [NSMutableDictionary dictionary];
    for(NSString * s in lexicon) {
        if([charArrayCache objectForKey:s] != nil) continue;
        NSMutableArray *chars = [s convertToMutableArray];
        if([chars count] < 1 || s == nil) continue;
        if([chars count] > 1) [chars sortUsingSelector:@selector(compare:)];
        [arrays setObject:[NSArray arrayWithArray:chars] forKey:s];
    }

    [charArrayCache addEntriesFromDictionary:arrays];
}






//////////////
// MATCHING //
//////////////

+ (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t {
    
    if ([s isEqualToString:t]) return 1;
    
    int n = (int)[s length];
    int m = (int)[t length];
    
    if (s == nil || t == nil) return 0;
    if (n < 1 || m < 1) return 0;
    
    NSArray *sChars = [charArrayCache objectForKey:s];
    NSArray *tChars = [charArrayCache objectForKey:t];

    n = (int)[sChars count];
    m = (int)[tChars count];

    int matches = 0, i = 0, j = 0;
    
    while (i < n && j < m) {
        NSComparisonResult result = [sChars[i] compare:tChars[j] options:NSDiacriticInsensitiveSearch];
        if (result == NSOrderedSame) {
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



+ (NSArray *) topMatchesForTerm:(NSString *)term inLexicon:(NSArray *)lexicon {
    
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
    for(NSString * term2 in lexicon) {
        
        if([term isEqualToString:term2]) continue;
        
        CGFloat c = [ABDice diceCoefficientWithString:term andString:term2];
        if(c < 0.3) continue;
        NSString *score = [NSString stringWithFormat:@"%f", c];
        
        if (![res objectForKey:score]) [res setObject:[NSMutableArray array] forKey:score];
        [[res objectForKey:score] addObject:term2];
    }
    
    NSArray *keys = [[res allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *topterms = [NSMutableArray array];
    
    for (NSString * key in [keys reverseObjectEnumerator]) {
        
        if([topterms count] > 30) break;
        
        NSArray *terms = [res objectForKey:key];
        if([terms count] == 0) continue;
        
        for(NSString * t in terms) {
            if([topterms count] > 40) break;
            [topterms addObject:t];
        }
    }
    
    return [NSArray arrayWithArray:topterms];
}



+ (NSDictionary *) topCoreMatchesForLexicon:(NSArray *)lexicon {
    
    DDLogInfo(@"Core dice matches: computing ...");
    NSMutableDictionary *tops = [NSMutableDictionary dictionary];
    [ABDice initCacheWithLexicon:lexicon];
    
    for(NSString * term in lexicon) {
        if([term isEqualToString:@""]) continue;
        NSArray *topterms = [self topMatchesForTerm:term inLexicon:lexicon];
        [tops setObject:topterms forKey:term];
        DDLogInfo(@"----- %@", term);
    }
    
    DDLogInfo(@"Core dice matches: done.");
    return tops;
}



+ (NSDictionary *) getMatchesForKeys:(NSArray *)strings inLexicon:(NSArray *)lexicon {
    
    DDLogInfo(@"New dice: computing ...");
    NSMutableDictionary *tops = [NSMutableDictionary dictionary];
    
    for(NSString * term in strings) {
        if([term isEqualToString:@""]) continue;
        NSArray *topterms = [self topMatchesForTerm:term inLexicon:lexicon];
        [tops setObject:topterms forKey:term];
        DDLogInfo(@"----- %@", term);
    }
    
    DDLogInfo(@"New dice: done.");
    return tops;
}



+ (void) crossReferenceTerms:(NSDictionary *)diceAdditions {
    for (NSString *key in [diceAdditions allKeys]) {
        NSArray *terms = [diceAdditions objectForKey:key];
        for (NSString *entry in terms) {
            [ABDice crossReferenceDiceEntry:entry withNewTerm:key];
        }
    }
}


+ (void) crossReferenceDiceEntry:(NSString *)entry withNewTerm:(NSString *)term {
    
    NSMutableArray *diceArray = [NSMutableArray arrayWithArray:[ABDice diceForKey:entry]];
    
    if(!diceArray || [diceArray count] == 0) {
        DDLogWarn(@"Dice listing not found!: %@", entry);
        return;
    }
    
    NSUInteger newIndex = [diceArray indexOfObject:term inSortedRange:(NSRange){0, [diceArray count]} options:NSBinarySearchingInsertionIndex usingComparator:^(id obj2, id obj1) {
        NSNumber *rank1 = @([ABDice diceCoefficientWithString:entry andString:obj1]);
        NSNumber *rank2 = @([ABDice diceCoefficientWithString:entry andString:obj2]);
        return (NSComparisonResult)[rank1 compare:rank2];
    }];
    
    [diceArray insertObject:term atIndex:(int)newIndex];
    [diceDictionary setObject:diceArray forKey:entry];
    [diceAdditionsDictionary setObject:diceArray forKey:entry];
}






////////////
// PUBLIC //
////////////


+ (NSMutableArray *) diceForKey:(NSString *)text {
    if([diceDictionary objectForKey:text]) return [diceDictionary objectForKey:text];
    if([oneWayAdditionsDictionary objectForKey:text]) return [oneWayAdditionsDictionary objectForKey:text];
    return nil;
}


+ (void) updateDiceDictionaryWithStrings:(NSArray *)strings {
    
    DDLogInfo(@"Dice dictionary: updating ... ");
    NSMutableArray *newWords = [NSMutableArray array];
    for(NSString *w in strings) {
        if([diceDictionary objectForKey:w] == nil) [newWords addObject:w];
    }
    
    [ABDice updateCacheWithLexicon:newWords];
    NSArray *oldKeys = [diceDictionary allKeys];
    NSMutableArray *lexicon = [NSMutableArray arrayWithArray:[oldKeys arrayByAddingObjectsFromArray:newWords]];
    NSDictionary *diceAdditions = [ABDice getMatchesForKeys:newWords inLexicon:lexicon];
    [diceDictionary addEntriesFromDictionary:diceAdditions];
    [diceAdditionsDictionary addEntriesFromDictionary:diceAdditions];
    
    [ABDice crossReferenceTerms:diceAdditions];
    [ABData saveDiceAdditions:diceAdditionsDictionary];
    DDLogInfo(@"%@", @"Dice dictionary: done updating.");
}


// Never runs in live app, just used to create precompiled data in dev
+ (NSDictionary *) createDiceDictionaryToBeSavedWithStrings:(NSArray *)strings {
    
    DDLogInfo(@"Dice dictionary: updating with new vocabulary to be saved to a file ... ");
    NSMutableArray *newWords = [NSMutableArray array];
    for(NSString *w in strings) { [newWords addObject:w]; }
    
    [ABDice updateCacheWithLexicon:newWords];
    NSArray *oldKeys = [diceDictionary allKeys];
    NSMutableArray *lexicon = [NSMutableArray arrayWithArray:[oldKeys arrayByAddingObjectsFromArray:newWords]];
    NSDictionary *diceAdditions = [ABDice getMatchesForKeys:newWords inLexicon:lexicon];

    return diceAdditions;
    DDLogInfo(@"%@", @"Dice dictionary: done updating.");
}



@end
