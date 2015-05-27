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
NSMutableDictionary *diceDictionary;
NSMutableDictionary *abScriptWordsDictionary;
NSMutableArray *graftScriptWords;   //  <<------ TODO
NSMutableArray *graftsHistory;
NSArray *currentGraftWords;


NSMutableDictionary *scriptData;


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
    diceDictionary = [ABData loadPrecompiledData:@"coreDiceDictionary"];
    if(diceDictionary == nil) {
        NSLog(@"%@", @">> ERROR: CORE MUTATIONS TABLE NOT FOUND");
        [ABData generateCoreDictionary];
        [ABData saveData:diceDictionary forKey:@"coreDiceDictionary"];
    } else {
        diceDictionary = [ABData loadDiceAdditionsAndAddToDictionary:diceDictionary];
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
    //NSString *path = [ABData filePathWithName:key];
    NSString *path = [[NSBundle mainBundle] pathForResource:[@"abraData-" stringByAppendingString:key] ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return savedData;
//    return [NSMutableDictionary dictionaryWithDictionary:savedData];
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





/////////////////////// DEV FNS ///////////////////////

+ (void) createLocalDataCacheDEV {
    [ABData generateCoreDictionary];
}

// Only used in dev, and needs to be manually triggered
// Thereafter saved as a local file
+ (NSMutableDictionary *) generateCoreDictionary {
    NSLog(@"%@", @"Generating dictionary ...");
    diceDictionary = [NSMutableDictionary dictionaryWithDictionary:[ABDice topCoreMatchesForLexicon:[ABData loadWordList]]];
    diceDictionary = [ABData loadDiceAdditionsAndAddToDictionary:diceDictionary];
    NSLog(@"%@", @"Finished generating dictionary.");
    return diceDictionary;
}

/////////////////////// END DEV FNS ///////////////////////







+ (void) saveData:(NSDictionary *)dataDict forKey:(NSString *)key {
    [NSKeyedArchiver archiveRootObject:dataDict toFile:[ABData filePathWithName:key]];
}

+ (void) saveModifiedMutationsIndex:(NSDictionary *)dataDict {
    [ABData saveData:dataDict forKey:@"modifiedMutationsTable"];
}

+ (NSMutableDictionary *) loadModifiedMutationsIndex {
    return [ABData loadMutableDataForKey:@"modifiedMutationsTable"];
}









// LOAD OTHER DATA

+ (NSArray *) loadWordList {
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"wordList" ofType:@"txt"];
//    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    return [rawText componentsSeparatedByString:@"\n"];

    return [abScriptWordsDictionary allKeys];
    
}


+ (NSMutableDictionary *) loadDiceAdditionsAndAddToDictionary:(NSMutableDictionary *)diceDictionary {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"diceAdditions" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *entries = [rawText componentsSeparatedByString:@"\n"];

    for (int i = 0; i < [entries count]; i++) {
        NSArray *terms = [entries[i] componentsSeparatedByString:@" "];
        NSString *key = terms[0];
        NSMutableArray *others = [NSMutableArray array];
        for (int j = 1; j < [terms count]; j++) {
            [others addObject:terms[j]];
        }
        [diceDictionary setObject:[NSArray arrayWithArray:others] forKey:key];
    }

    return diceDictionary;
}








/////////////////////////
// SCRIPT WORD OBJECTS //
/////////////////////////


// Add new words to scriptWords list temporarily (not persistently)
+ (void) addToScriptWords:(NSString *)text {
    ABScriptWord *sw = [[ABScriptWord alloc] initWithText:text sourceStanza:[ABState getCurrentStanza]];
    [abScriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];
}

+ (ABScriptWord *) getScriptWord:(NSString *)text {
    if(![abScriptWordsDictionary objectForKey:text]) {
        [ABData addToScriptWords:text];
    }
    return [abScriptWordsDictionary objectForKey:text];
}

// TODO: determine whether this needs to be a copy and not a reference to the object within the dictionary (?)
+ (ABScriptWord *) getRandomScriptWord {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    return abScriptWordsDictionary[allKeys[arc4random_uniform([allKeys count])]];
}




/////////////
// GETTERS //
/////////////


+ (NSMutableArray *) diceForKey:(NSString *)text {
    if(![diceDictionary objectForKey:text]) return nil;
    return [diceDictionary objectForKey:text];
}

// TODO: determine whether this needs to be a copy and not a reference to the object within the dictionary (?)
+ (ABScriptWord *) randomABScriptWordFromDictionary {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    return abScriptWordsDictionary[allKeys[arc4random_uniform([allKeys count])]];
}





//////////////
// GRAFTING //
//////////////

+ (BOOL) abraKnowsThisWordAlready {
    
}

+ (void) graftNewWords:(NSArray *)words {
    
    
    // Run processes to update lookup tables
    currentGraftWords = words;
}




+ (ABScriptWord *) getWordToGraft {
    ABScriptWord *w = [currentGraftWords objectAtIndex:(arc4random() % [currentGraftWords count])];
    
    return w;
}






/////////////
// LEXICON //
/////////////


+ (void) addToDice:(NSString *)text {
    
}




+ (void) addToAllWords:(ABScriptWord *)word {
    
}







@end
