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

NSMutableArray *pastGrafts;               // as strings
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
        
        // TODO!

    
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
    [ABDice generateDiceDictionary];
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

// TODO: determine whether this needs to be a copy and not a reference to the object within the dictionary (?)
+ (ABScriptWord *) getRandomScriptWord {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    return abScriptWordsDictionary[allKeys[arc4random_uniform([allKeys count])]];
}




/////////////
// GETTERS //
/////////////


// TODO: determine whether this needs to be a copy and not a reference to the object within the dictionary (?)
+ (ABScriptWord *) randomABScriptWordFromDictionary {
    NSArray *allKeys = [abScriptWordsDictionary allKeys];
    return abScriptWordsDictionary[allKeys[arc4random_uniform([allKeys count])]];
}





//////////////
// GRAFTING //
//////////////

+ (void) graftNewWords:(NSArray *)words {
    
    // Run processes to update lookup tables

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

    [pastGrafts addObjectsFromArray:words];
    
    currentGraftWords = scriptWords;
    graftIndex = 0;
    
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







@end
