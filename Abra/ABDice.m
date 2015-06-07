//
//  ABDice.m
//  
//
//  Created by Ian Hatcher on 1/18/15.
//
//

#import "ABDice.h"
#import "ABData.h"
#import "ABConstants.h"

// Method to split string that works with extended chars (emoji)
@interface NSString (ConvertToArray)
- (NSMutableArray *) convertToMutableArray;
@end
@implementation NSString (ConvertToArray)
- (NSMutableArray *) convertToMutableArray {
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





// PRIVATE METHODS
@interface ABDice ()

// init
+ (void) loadErrataAndAddToDictionary;

// cache
+ (void) initCacheWithLexicon:(NSArray *)lexicon;
+ (void) updateCacheWithLexicon:(NSArray *)lexicon;

// internal
+ (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t;
+ (NSArray *) topMatchesForTerm:(NSString *)term inLexicon:(NSArray *)lexicon;
+ (NSDictionary *) topCoreMatchesForLexicon:(NSArray *)lexicon;
+ (NSDictionary *) getMatchesForKeys:(NSArray *)strings inLexicon:(NSArray *)lexicon;

@end


@implementation ABDice

NSMutableDictionary *charArrayCache;
NSMutableDictionary *diceDictionary;
NSMutableDictionary *diceAdditionsDictionary;



//////////
// INIT //
//////////

+ (void) setDiceDictionary:(NSMutableDictionary *)dict {
    diceDictionary = dict;
    [ABDice loadErrataAndAddToDictionary];
    [ABDice initCacheWithLexicon:[diceDictionary allKeys]];
}


+ (void) setDiceAdditions:(NSDictionary *)dict {
    DDLogInfo(@"Dice additions: adding %i entries", [[dict allKeys] count]);
    diceAdditionsDictionary = [NSMutableDictionary dictionary];
    [ABDice updateCacheWithLexicon:[dict allKeys]];
    for (NSString *key in dict) {
        [diceDictionary setObject:[dict objectForKey:key] forKey:key];
    }
    diceAdditionsDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
}

+ (void) generateDiceDictionary {
    DDLogInfo(@"%@", @"Dice dictionary: generating ...");
    diceDictionary = [NSMutableDictionary dictionaryWithDictionary:[ABDice topCoreMatchesForLexicon:[ABData loadWordList]]];
    DDLogInfo(@"%@", @"Dice dictionary: done generating.");
    [ABDice loadErrataAndAddToDictionary];
}


+ (void) addEntriesToDictionary:(NSArray *)entries {
    int entriesCount = [entries count];
    for (int i = 0; i < entriesCount; i++) {
        NSArray *terms = [entries[i] componentsSeparatedByString:@" "];
        NSString *key = terms[0];
        NSMutableArray *others = [NSMutableArray array];
        int termsCount = [terms count];
        for (int j = 1; j < termsCount; j++) {
            [others addObject:terms[j]];
        }
        [diceDictionary setObject:[NSArray arrayWithArray:others] forKey:key];
    }
}

+ (void) loadErrataAndAddToDictionary {
    DDLogInfo(@"%@", @"Dice errata: loading ...");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"diceErrata" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *entries = [rawText componentsSeparatedByString:@"\n"];
    [ABDice addEntriesToDictionary:entries];
    DDLogInfo(@"%@", @"Dice errata: done.");
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
    if(![diceDictionary objectForKey:text]) return nil;
    return [diceDictionary objectForKey:text];
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



@end
