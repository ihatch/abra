//
//  ABData.m
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABData.h"
#import "ABConstants.h"
#import "ABDice.h"
#import "ABState.h"
#import "ABScriptWord.h"
#import "ABScript.h"
#import "ABEmoji.h"

// Methods to split string that work with extended chars (emoji)
@interface NSString (ConvertToArray)
- (NSArray *)convertToArray;
- (NSMutableArray *) convertToMutableArray;
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




// Private
@interface ABData ()

+ (NSString *) filePathWithName:(NSString *)name;
+ (BOOL) fileExistsWithName:(NSString *)name;
+ (NSDictionary *) loadDataForKey:(NSString *)key;
+ (NSMutableDictionary *) loadMutableDataForKey:(NSString *)key;
+ (NSMutableDictionary *) loadPrecompiledData:(NSString *)key;


@end



@implementation ABData

NSMutableDictionary *scriptData;
NSMutableDictionary *abScriptWordsDictionary;

NSMutableArray *pastGrafts;        // an array of arrays of individual word strings
NSMutableArray *pastGraftStrings;  // an array of strings consisting of space-separated words
NSMutableSet *allPastGraftTerms;

NSMutableDictionary *graftsByCharCount;

NSArray *currentGraftWords;
int graftIndex;

NSMutableDictionary *magicWordsIndex;



static ABData *ABDataInstance = NULL;

+ (void) initialize {
    @synchronized(self) {
        if (ABDataInstance == NULL) ABDataInstance = [[ABData alloc] init];
    }
}



+ (void) initData {
    
    DDLogInfo(@"===== DATA: loading =====");

    DDLogInfo(@"== initCoreScript");
    [ABData initCoreScript];
    DDLogInfo(@"== initCoreDictionary");
    [ABData initCoreDictionary];
    DDLogInfo(@"== loadDiceAdditions");
    [ABData loadDiceAdditions];
    DDLogInfo(@"== loadGrafts");
    [ABData loadGrafts];
    DDLogInfo(@"== initEmoji");
    [ABEmoji initEmoji];
    DDLogInfo(@"== initMagicWords");
    [ABData initMagicWords];
    
    
    
    DDLogInfo(@"===== DATA: loaded. =====");
}







///////////////////////////
// INIT LISTS AND TABLES //
///////////////////////////

+ (void) setABScriptWordsDictionary:(NSMutableDictionary *) scriptWordsDictionary {
    abScriptWordsDictionary = scriptWordsDictionary;
}

+ (void) initCoreScript {
    scriptData = [ABScript initScriptAndParseScriptFile];
    abScriptWordsDictionary = [scriptData objectForKey:@"scriptWordsDictionary"];
}


+ (void) initCoreDictionary {
    NSMutableDictionary *diceDictionary = [ABData loadPrecompiledData:@"coreDiceDictionary"];
    if(diceDictionary == nil) {
        DDLogError(@"%@", @">> ERROR: CORE MUTATIONS TABLE NOT FOUND");
        [ABDice generateDiceDictionary];
        [ABData saveData:diceDictionary forKey:@"coreDiceDictionary"];
    } else {
        [ABDice setDiceDictionary:diceDictionary];
    }
}

+ (void) resetLexicon {
    [pastGrafts removeAllObjects];
    [pastGraftStrings removeAllObjects];
    [allPastGraftTerms removeAllObjects];
    [graftsByCharCount removeAllObjects];
    currentGraftWords = [NSArray array];
    [ABData saveGrafts];
    [ABDice resetLexicon];
    DDLogInfo(@"Reset lexicon!");
}






////////////////////////////
// DICTIONARY FILES, ETC  //
////////////////////////////

+ (NSString *) filePathWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *fileName = [@"abraData-" stringByAppendingString:name];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (BOOL) fileExistsWithName:(NSString *)name {
    NSString *filePath = [ABData filePathWithName:name];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


+ (NSMutableDictionary *) loadPrecompiledData:(NSString *)key {
    if(![ABData fileExistsWithName:key]) return nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:[@"abraData-" stringByAppendingString:key] ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return savedData;
}

+ (NSDictionary *) loadDataForKey:(NSString *)key {
    DDLogInfo(@"Loading data for key: %@", key);
    NSString *filePath = [ABData filePathWithName:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return savedData;
    }
    return nil;
}

+ (NSMutableDictionary *) loadMutableDataForKey:(NSString *)key {
    NSDictionary *data = [ABData loadDataForKey:key];
    return [ABData convertDataToMutable:data];
}

+ (NSMutableDictionary *) convertDataToMutable:(NSDictionary *)data {
    return CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(data), kCFPropertyListMutableContainersAndLeaves));
}

+ (void) saveData:(NSDictionary *)dataDict forKey:(NSString *)key {
    [NSKeyedArchiver archiveRootObject:dataDict toFile:[ABData filePathWithName:key]];
}

+ (void) saveDiceAdditions:(NSMutableDictionary *) diceAdditions {
    DDLogInfo(@"Saving dice additions");
    [ABData saveData:diceAdditions forKey:@"diceAdditions"];
}

+ (void) loadDiceAdditions {
    [ABDice setDiceAdditions:[ABData loadDataForKey:@"diceAdditions"]];
}











////////////
// GRAFTS //
////////////


// --------------- FILES ---------------


+ (void) loadGrafts {
    
    graftsByCharCount = [NSMutableDictionary dictionary];

    NSMutableArray *grafts = [ABData loadArrayOfStringsFromFile:@"pastGraftStrings"];
    if(!grafts || [grafts count] == 0 || [grafts isEqualToArray:@[@""]]) {
        DDLogInfo(@"No past grafts found. Initializing empty arrays.");
        pastGraftStrings = [NSMutableArray array];
        pastGrafts = [NSMutableArray array];
        return;
    }
    
    pastGraftStrings = grafts;
    pastGrafts = [NSMutableArray array];
    for(NSString *graft in grafts) {
        NSArray *words = [graft componentsSeparatedByString:@" "];
        [allPastGraftTerms unionSet:[NSSet setWithArray:words]];
        [pastGrafts addObject:words];
        [ABData processGraftWordsIntoScriptWords:words andDice:NO];
    }
    
    DDLogInfo(@"Past grafts loaded: %ld", (long)[pastGrafts count]);
}


+ (void) saveGrafts {
    [ABData saveArrayOfStrings:pastGraftStrings toFile:@"pastGraftStrings"];
}



+ (void) saveArrayOfStrings:(NSMutableArray *)array toFile:(NSString *)key {
    DDLogInfo(@"Saving strings data for key: %@", key);

    NSString *string = [array componentsJoinedByString:@"\n"];
    NSData *data = [string dataUsingEncoding:NSUTF16StringEncoding];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:key];
    
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    if(result == NO) DDLogError(@"ERROR: could not save file: %@", key);
}



+ (NSMutableArray *) loadArrayOfStringsFromFile:(NSString *)key {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:key];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        DDLogError(@"ERROR: File not found: %@", key);
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if(!data) {
        DDLogError(@"ERROR: No data for file: %@", key);
        return nil;
    }

    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding];
    return [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
}



// --------------- HELPERS ---------------


+ (NSArray *) processGraftWordsIntoScriptWords:(NSArray *)words andDice:(BOOL)dice {
    if(dice) [ABDice updateDiceDictionaryWithStrings:words];
    NSArray *scriptWords = [ABScript parseGraftArrayIntoScriptWords:words];
    return scriptWords;
}


+ (NSString *) filterGraftText:(NSString *)text {
    NSCharacterSet *charactersToRemove = [NSCharacterSet illegalCharacterSet];
    text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    text = [text stringByTrimmingCharactersInSet:whitespace];
    return text;
}

// TODO
//+ (void) addGraftStringToCharCountIndex:(NSString *)string {
//    NSNumber *count = @([[string convertToMutableArray] count]);
//    if([graftsByCharCount objectForKey:count] == nil) {
//        [graftsByCharCount setObject:[NSMutableArray array] forKey:count];
//    }
//    [[graftsByCharCount objectForKey:count] addObject:string];
//}



// --------------- INTERFACE ---------------


+ (BOOL) graftText:(NSString *)text {
    
    text = [ABData filterGraftText:text];
    if ([text length] == 0) return NO;
    
    NSArray *words = [text componentsSeparatedByString:@" "];
    if([words count] == 0) return NO;
    
    [ABData graftNewWords:words];
    
    [pastGrafts addObject:words];
    [pastGraftStrings addObject:text];
    
    [ABData saveGrafts];
    
    return YES;
}


+ (void) graftNewWords:(NSArray *)words {
    NSArray *scriptWords = [ABData processGraftWordsIntoScriptWords:words andDice:YES];
    [pastGrafts addObject:words];
    currentGraftWords = scriptWords;
    graftIndex = 0;
}


+ (ABScriptWord *) getWordToGraft {
    if([currentGraftWords count] == 0) return [ABData getScriptWord:@"?"];
    ABScriptWord *w = [currentGraftWords objectAtIndex:graftIndex];
    graftIndex ++;
    if(graftIndex == [currentGraftWords count]) graftIndex = 0;
    return w;
}


+ (ABScriptWord *) getPastGraftWord {
    if([pastGrafts count] == 0) return nil;
    NSArray *past = [pastGrafts objectAtIndex:(arc4random() % [pastGrafts count])];
    NSString *word = [past objectAtIndex:(arc4random() % [past count])];
    return [[abScriptWordsDictionary objectForKey:word] copyOfThisWord];
}


+ (NSMutableArray *) getPastGraftsWithCharCount:(int)count {
    return [graftsByCharCount objectForKey:@(count)];
}


//+ (NSMutableArray *) getPastGraftSimilarToWord:(NSString *)word {
//    
//}










//////////////////
// SCRIPT WORDS //
//////////////////


+ (ABScriptWord *) getScriptWord:(NSString *)text {
    return [ABData scriptWord:text stanza:-1 fam:nil leftSis:nil rightSis:nil graft:NO check:NO];
}

+ (ABScriptWord *) getScriptWordAndRunChecks:(NSString *)text {
    return [ABData scriptWord:text stanza:-1 fam:nil leftSis:nil rightSis:nil graft:NO check:YES];
}

+ (ABScriptWord *) getScriptWord:(NSString *)text withSourceStanza:(int)sourceStanza {
    if(text == nil) DDLogError(@"ERROR: NIL SENT TO getScriptWord");
    return [ABData scriptWord:text stanza:sourceStanza fam:nil leftSis:nil rightSis:nil graft:NO check:NO];
}

+ (ABScriptWord *) scriptWord:(NSString *)text stanza:(int)stanza fam:(NSArray *)family leftSis:(NSString *)leftSis rightSis:(NSString *)rightSis graft:(BOOL)graft check:(BOOL)check {
    if(stanza == -1) stanza = [ABState getCurrentStanza];
    ABScriptWord *sw = [abScriptWordsDictionary objectForKey:text];
    
    // Create new scriptWord and add to dictionary (NOT persistently to next user session)
    if(sw == nil) {
        sw = [[ABScriptWord alloc] initWithText:text sourceStanza:stanza inFamily:family isGrafted:graft];
        if(leftSis) [sw addLeftSister:leftSis];
        if(rightSis) [sw addLeftSister:rightSis];
        if(check) [sw runChecks];
        [abScriptWordsDictionary setObject:sw forKey:text];
        
    // Use existing scriptWord, but update its familial connections
    } else {
        if(family || leftSis || rightSis) {
            if(family) [sw addFamily:family];
            if(leftSis) [sw addLeftSister:leftSis];
            if(rightSis) [sw addLeftSister:rightSis];
            if(check && sw.hasRunChecks == NO) [sw runChecks];
            [abScriptWordsDictionary setObject:sw forKey:text];
        }
        sw = [sw copyOfThisWord];
        sw.sourceStanza = stanza;
    }

    return sw;
}



+ (ABScriptWord *) getRandomScriptWord {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    ABScriptWord *sw = abScriptWordsDictionary[allKeys[arc4random_uniform((int)[allKeys count])]];
    return [sw copyOfThisWord];
}

+ (NSArray *) loadWordList {
    return [abScriptWordsDictionary allKeys];
}













+ (void) initMagicWords {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"magicWords" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *rawSets = [rawText componentsSeparatedByString:@"\n\n\n"];
    
    magicWordsIndex = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < [rawSets count]; i++) {
        
        NSMutableArray *words = [NSMutableArray arrayWithArray: [rawSets[i] componentsSeparatedByString:@"\n"]];
        NSString *cadabra = [words objectAtIndex:0];

        for(int j = 1; j < [words count]; j ++) {
            NSString *w = [words objectAtIndex:j];
            [magicWordsIndex setObject:cadabra forKey:w];
        }
    }
    
    DDLogInfo(@"xcfs");
    
}


+ (NSString *) checkMagicWord:(NSString *)word {
    if(magicWordsIndex == nil) [ABData initMagicWords];
    return [magicWordsIndex objectForKey:word];
}







/////////////////////// DEV FNS ///////////////////////

+ (void) createLocalDataCacheDEV {
    [ABDice generateDiceDictionary];
}

/////////////////////// END DEV FNS ///////////////////////








@end
