//
//  ABData.m
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//
//  Handles words saved into the lexicon, etc.


#import "ABData.h"
#import "ABConstants.h"
#import "ABDice.h"
#import "ABState.h"
#import "ABScriptWord.h"
#import "ABScript.h"
#import "ABEmoji.h"
#import "NSString+ABExtras.h"
#import "NSString+Tokenize.h"

// Private
@interface ABData ()

//+ (NSString *) filePathWithName:(NSString *)name;
//+ (NSDictionary *) loadDataForKey:(NSString *)key;
//+ (NSMutableDictionary *) loadMutableDataForKey:(NSString *)key;
//+ (NSMutableDictionary *) loadPrecompiledData:(NSString *)key;

@end



@implementation ABData

NSMutableDictionary *scriptData;
NSMutableDictionary *abScriptWordsDictionary;

NSMutableArray *pastGrafts;        // an array of arrays of individual word strings
NSMutableArray *pastGraftStrings;  // an array of strings consisting of space-separated words
NSMutableArray *allPastGraftTerms;

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
    NSDate *methodStart = [NSDate date];

    DDLogInfo(@"== initEmoji");
    [ABEmoji initEmoji];
    DDLogInfo(@"== initCoreScript");
    [ABData initCoreScript];
    DDLogInfo(@"== initCoreDictionary");
    [ABData initCoreDictionary];
    DDLogInfo(@"== loadOtherLanguages");
    [ABData loadOtherLanguages];
    DDLogInfo(@"== loadDiceAdditions");
    [ABData loadDiceAdditions];
    DDLogInfo(@"== loadGrafts");
    [ABData loadGrafts];
    DDLogInfo(@"== initMagicWords");
    [ABData initMagicWords];
    
//    [ABData createNewDiceDictionaryFromTxtFile:@"words_greek" andSaveToAbraDataFileWithKey:@"greek"];  // saves as "abraData-greek" in Library/Developer/CoreSimulator/???
    
    DDLogInfo(@"===== DATA: loaded. (%f sec) =====", [[NSDate date] timeIntervalSinceDate:methodStart]);
    
}







///////////////////////////
// INIT LISTS AND TABLES //
///////////////////////////

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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

+ (void) loadOtherLanguages {
    NSMutableDictionary *greek = [ABData loadPrecompiledData:@"greek"];
    [ABDice addNonEnglishLanguageDiceDictionary:greek andLangString:@"Greek"];
}

+ (void) setABScriptWordsDictionary:(NSMutableDictionary *) scriptWordsDictionary {
    abScriptWordsDictionary = scriptWordsDictionary;
}

+ (void) resetLexicon {
    [pastGrafts removeAllObjects];
    [pastGraftStrings removeAllObjects];
    [allPastGraftTerms removeAllObjects];
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

+ (NSMutableDictionary *) loadPrecompiledData:(NSString *)key {
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

+ (NSDictionary *) loadGestureHistory {
    return [ABData loadDataForKey:@"gestureHistory"];
}

+ (void) saveGestureHistory:(NSMutableDictionary *) gestureHistory {
    DDLogInfo(@"Saving gesture history");
    [ABData saveData:gestureHistory forKey:@"gestureHistory"];
}


+ (void) createNewDiceDictionaryFromTxtFile:(NSString *)filename andSaveToAbraDataFileWithKey:(NSString *)key {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *strings = [rawText componentsSeparatedByString:@"\n"];
    NSDictionary *dict = [ABDice createDiceDictionaryToBeSavedWithStrings:strings];
    [ABData saveData:dict forKey:key];
    
}









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
    NSArray *left = leftSis == nil ? nil : @[leftSis];
    NSArray *right = leftSis == nil ? nil : @[rightSis];
    return [ABData scriptWord:text stanza:stanza fam:family leftSisters:left rightSisters:right graft:graft check:check];
}

+ (ABScriptWord *) scriptWord:(NSString *)text stanza:(int)stanza fam:(NSArray *)family leftSisters:(NSArray *)leftSis rightSisters:(NSArray *)rightSis graft:(BOOL)graft check:(BOOL)check {
    if(stanza == -1) stanza = [ABState getCurrentStanza];
    ABScriptWord *sw = [abScriptWordsDictionary objectForKey:text];
    
    // Create new scriptWord and add to dictionary (NOT persistently to next user session)
    if(sw == nil) {
        sw = [[ABScriptWord alloc] initWithText:text sourceStanza:stanza inFamily:family isGrafted:graft];
        if(leftSis) [sw addLeftSisters:leftSis];
        if(rightSis) [sw addRightSisters:rightSis];
        if(check) [sw runChecks];
        [abScriptWordsDictionary setObject:sw forKey:text];
        
    // Use existing scriptWord, but update its familial connections
    } else {
        if(family || leftSis || rightSis) {
            if(family) [sw addFamily:family];
            if(leftSis) [sw addLeftSisters:leftSis];
            if(rightSis) [sw addRightSisters:rightSis];
            if(check && sw.hasRunChecks == NO) [sw runChecks];
//            [abScriptWordsDictionary setObject:sw forKey:text];
        }
        sw = [sw copy];
        sw.sourceStanza = stanza;
    }
    
    return sw;
}


+ (ABScriptWord *) getRandomScriptWord {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    ABScriptWord *sw = abScriptWordsDictionary[allKeys[arc4random_uniform((int)[allKeys count])]];
    return [sw copy];
}

+ (NSArray *) loadWordList {
    return [abScriptWordsDictionary allKeys];
}









////////////
// GRAFTS //
////////////


// --------------- FILES ---------------

+ (void) loadGrafts {

    NSDate *methodStart = [NSDate date];
    
    NSMutableArray *grafts = [ABData loadArrayOfStringsFromFile:@"pastGraftStrings"];
    if(!grafts || [grafts count] == 0 || [grafts isEqualToArray:@[@""]]) {
        DDLogInfo(@"No past grafts found. Initializing empty arrays.");
        pastGraftStrings = [NSMutableArray array];
        pastGrafts = [NSMutableArray array];
        return;
    }
    
    pastGraftStrings = grafts;
    pastGrafts = [NSMutableArray array];
    allPastGraftTerms = [NSMutableArray array];

    for(NSString *graft in grafts) {
        
        NSMutableArray *words = [NSMutableArray arrayWithArray:[graft componentsSeparatedByString:@" "]];
        [words removeObject:@" "];
        [words removeObject:@""];
        [pastGrafts addObject:words];

        NSArray *uniques = [[NSSet setWithArray:words] allObjects];
        NSMutableArray *onlyNew = [NSMutableArray arrayWithArray:uniques];
        [onlyNew removeObjectsInArray:allPastGraftTerms];
        [allPastGraftTerms addObjectsFromArray:onlyNew];
        
        [ABData parseGraftArrayIntoScriptWords:words];
    }
    
    DDLogInfo(@"Past grafts loaded: %i (%f sec)", (int)[pastGrafts count], [[NSDate date] timeIntervalSinceDate:methodStart]);
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

+ (NSArray *) parseGraftArrayIntoScriptWords:(NSArray *)words {
    
    NSArray *uniques = [[NSSet setWithArray:words] allObjects];
    
    NSMutableDictionary *leftSis = [NSMutableDictionary dictionary];
    NSMutableDictionary *rightSis = [NSMutableDictionary dictionary];
    
    for(NSString *s in uniques) {
        [leftSis setValue:[NSMutableArray array] forKey:s];
        [rightSis setValue:[NSMutableArray array] forKey:s];
    }
    
    NSString *last = [words firstObject];
    
    for(int i=1; i < [words count]; i++) {
        NSString *w = [words objectAtIndex:i];
        [[leftSis objectForKey:w] addObject:last];
        [[rightSis objectForKey:last] addObject:w];
        last = w;
    }
    
    NSMutableArray *scriptWords = [NSMutableArray array];
    
    for(int i=0; i<[uniques count]; i++) {
        NSArray *left = [leftSis objectForKey:uniques[i]];
        NSArray *right = [rightSis objectForKey:uniques[i]];
        ABScriptWord *sw = [ABData scriptWord:uniques[i] stanza:-1 fam:uniques leftSisters:left rightSisters:right graft:YES check:YES];
        [scriptWords addObject:sw];
    }
    
    return [NSArray arrayWithArray:scriptWords];
}




+ (NSString *) filterGraftText:(NSString *)text {
    NSCharacterSet *charactersToRemove = [NSCharacterSet illegalCharacterSet];
    text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    text = [text stringByTrimmingCharactersInSet:whitespace];
    return text;
}



// --------------- INTERFACE ---------------

+ (BOOL) graftText:(NSString *)text {
    
    NSDate *methodStart = [NSDate date];

    text = [ABData filterGraftText:text];
    if ([text length] == 0) return NO;
    
    NSArray *words = [text componentsSeparatedByString:@" "];
    if([words count] == 0) return NO;
    
    [ABDice updateDiceDictionaryWithStrings:[[NSSet setWithArray:words] allObjects]];
    NSArray *scriptWords = [ABData parseGraftArrayIntoScriptWords:words];
    
    if([ABState getExhibitionMode] == NO) {
        [pastGraftStrings addObject:text];
        [pastGrafts addObject:words];
        [ABData saveGrafts];
}
    currentGraftWords = scriptWords;
    graftIndex = 0;
    
    NSDate *methodEnd = [NSDate date];
    NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
    DDLogInfo(@"++ Graft: %i words (%f sec)", (int)[words count], executionTime);
    
    return YES;
}


+ (ABScriptWord *) getWordToGraft {
    if([currentGraftWords count] == 0) return [ABData getScriptWord:@"?"];
    ABScriptWord *w = [currentGraftWords objectAtIndex:graftIndex];
    graftIndex ++;
    if(graftIndex == [currentGraftWords count]) graftIndex = 0;
    return w;
}

+ (ABScriptWord *) getPastGraftWord {

    if([pastGrafts count] > 0) {
        NSArray *past = [pastGrafts objectAtIndex:(arc4random() % [pastGrafts count])];
        NSString *word = [past objectAtIndex:(arc4random() % [past count])];
        return [[abScriptWordsDictionary objectForKey:word] copy];
    } else if([currentGraftWords count] > 0) {
        ABScriptWord *w = [currentGraftWords objectAtIndex:(arc4random() % [currentGraftWords count])];
        return w;
    } else {
        return [ABData getScriptWord:@"?"];
    }
}


// TODO
+ (NSString *) getPastGraftString {
    if([pastGraftStrings count] == 0) return @"? ?";
    return [pastGraftStrings objectAtIndex:(arc4random() % [pastGraftStrings count])];
}









/////////////////
// MAGIC WORDS //
/////////////////


+ (void) initMagicWords {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"magic_words" ofType:@"txt"];
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
}


+ (NSString *) checkMagicWord:(NSString *)word {
    if(magicWordsIndex == nil) [ABData initMagicWords];
    return [magicWordsIndex objectForKey:word];
}







@end
