//
//  ABData.m
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABData.h"
#import "ABDice.h"
#import "ABState.h"
#import "ABScriptWord.h"
#import "ABScript.h"


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

NSMutableArray *pastGrafts;                     // an array of arrays of individual word strings
NSMutableArray *pastGraftStrings;               // an array of strings consisting of space-separated words

NSMutableDictionary *wordsIndexedByCharLength;  // use special char cutup;   also create fns to add / lookup by char count


NSArray *currentGraftWords;
int graftIndex;


static ABData *ABDataInstance = NULL;

+ (void) initialize {
    @synchronized(self) {
        if (ABDataInstance == NULL) ABDataInstance = [[ABData alloc] init];
    }
}



+ (void) initAbraData {
    
    NSLog(@"Initializing Abra data ...");

    [ABData initCoreScript];
    [ABData initCoreDictionary];
    [ABData loadDiceAdditions];
    [ABData loadGrafts];
    
    
    
    NSLog(@"Initialization of Abra data completed.");
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
        NSLog(@"%@", @">> ERROR: CORE MUTATIONS TABLE NOT FOUND");
        [ABDice generateDiceDictionary];
        [ABData saveData:diceDictionary forKey:@"coreDiceDictionary"];
    } else {
        [ABDice setDiceDictionary:diceDictionary];
    }
    
}





/////////////////////////////
// INTERNAL FILE HANDLING  //
/////////////////////////////

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
    NSLog(@"Loading data for key: %@", key);
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
    [ABData saveData:diceAdditions forKey:@"diceAdditions"];
}






+ (void) loadDiceAdditions {
    [ABDice setDiceAdditions:[ABData loadDataForKey:@"diceAdditions"]];
}









///////////////////////
// ARRAYS OF STRINGS //
///////////////////////



+ (void) loadGrafts {
    
    NSMutableArray *grafts = [ABData loadArrayOfStringsFromFile:@"pastGraftStrings"];
    if(!grafts || [grafts count] == 0) {
        NSLog(@"No past grafts found. Initializing empty arrays.");
        pastGraftStrings = [NSMutableArray array];
        pastGrafts = [NSMutableArray array];
        return;
    }
    
    pastGraftStrings = grafts;
    pastGrafts = [NSMutableArray array];
    for(NSString *graft in grafts) {
        NSLog(@"Loading graft: %@", graft);
        NSArray *words = [graft componentsSeparatedByString:@" "];
        [pastGrafts addObject:words];
        [ABData processGraftWordsIntoScriptWordsAndDice:words];
    }
    

    NSLog(@"Past grafts loaded: %i", [pastGrafts count]);
}


+ (void) saveGrafts {
    [ABData saveArrayOfStrings:pastGraftStrings toFile:@"pastGraftStrings"];
}


+ (void) saveArrayOfStrings:(NSMutableArray *)array toFile:(NSString *)key {
    NSLog(@"Saving strings data for key: %@", key);

    NSString *string = [array componentsJoinedByString:@"\n"];
    NSData *data = [string dataUsingEncoding:NSUTF16StringEncoding];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:key];
    
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    if(result == NO) NSLog(@"ERROR: could not save file: %@", key);
}



+ (NSMutableArray *) loadArrayOfStringsFromFile:(NSString *)key {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:key];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"ERROR: File not found: %@", key);
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if(!data) {
        NSLog(@"ERROR: No data for file: %@", key);
        return nil;
    }

    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding];
    return [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@"\n"]];
}











// LOAD OTHER DATA

+ (NSArray *) loadWordList {
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"wordList" ofType:@"txt"];
//    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    return [rawText componentsSeparatedByString:@"\n"];

    return [abScriptWordsDictionary allKeys];
    
}







/////////////////////////
// SCRIPT WORD OBJECTS //
/////////////////////////


// Add new words to scriptWords list temporarily (not persistently)
+ (void) addToScriptWords:(NSString *)text {
    ABScriptWord *sw = [[ABScriptWord alloc] initWithText:text sourceStanza:[ABState getCurrentStanza]];
    [sw checkProperties];
    [abScriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];
}

+ (ABScriptWord *) getScriptWord:(NSString *)text {
    if(![abScriptWordsDictionary objectForKey:text]) {
        [ABData addToScriptWords:text];
    }
    return [abScriptWordsDictionary objectForKey:text];
}

+ (ABScriptWord *) getRandomScriptWord {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    ABScriptWord *sw = abScriptWordsDictionary[allKeys[arc4random_uniform([allKeys count])]];
    return [sw copyOfThisWord];
}







//////////////
// GRAFTING //
//////////////


+ (NSString *) filterGraftText:(NSString *)text {
    NSCharacterSet *charactersToRemove = [NSCharacterSet illegalCharacterSet];
    text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    text = [text stringByTrimmingCharactersInSet:whitespace];
    return text;
}


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
    NSArray *scriptWords = [ABData processGraftWordsIntoScriptWordsAndDice:words];
    [pastGrafts addObject:words];
    currentGraftWords = scriptWords;
    graftIndex = 0;
}


+ (NSArray *) processGraftWordsIntoScriptWordsAndDice:(NSArray *)words {
    
    [ABDice updateDiceDictionaryWithStrings:words];
    NSArray *scriptWords = [ABScript parseGraftArrayIntoScriptWords:words];
    
    for(ABScriptWord *sw in scriptWords) {
        if([abScriptWordsDictionary objectForKey:sw.text] != nil) continue;
        [abScriptWordsDictionary setObject:sw forKey:sw.text];
    }
    
    // Set sisters
    if([words count] > 1) {
        for(NSString *s in words) {
            for(NSString *s2 in words) {
                if([s isEqualToString:s2]) continue;
                [[abScriptWordsDictionary objectForKey:s] addSister:s2];
            }
        }
    }
    
    return scriptWords;
}




+ (ABScriptWord *) getWordToGraft {
    ABScriptWord *w = [currentGraftWords objectAtIndex:graftIndex];
    graftIndex ++;
    if(graftIndex == [currentGraftWords count]) graftIndex = 0;
    return w;
}


+ (ABScriptWord *) getPastGraftWord {
    if([pastGrafts count] == 0) return nil;
    return [pastGrafts objectAtIndex:(arc4random() % [pastGrafts count])];
}








/////////////
// LEXICON //
/////////////



+ (void) addToAllWords:(ABScriptWord *)word {
    
}








/////////////////////// DEV FNS ///////////////////////

+ (void) createLocalDataCacheDEV {
    [ABDice generateDiceDictionary];
}

/////////////////////// END DEV FNS ///////////////////////








@end
