//
//  ABDictionary.m
//  Abra
//
//  Created by Ian Hatcher on 2/21/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABDictionary.h"
#import "ABScriptWord.h"
#import "ABData.h"
#import "ABDice.h"

@implementation ABDictionary

NSMutableDictionary *diceDictionary;
NSMutableDictionary *abScriptWordsDictionary;
NSMutableArray *allWordObjs;
NSMutableArray *graftScriptWords;   //  <<------ TODO
NSMutableArray *graftsHistory;
NSArray *currentGraftWords;

static ABDictionary *ABDictionaryInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABDictionaryInstance == NULL) ABDictionaryInstance = [[ABDictionary alloc] init];
    }
}



///////////////////////////
// INIT LISTS AND TABLES //
///////////////////////////

+ (void) setAllWords:(NSMutableArray *)allWords {
    allWordObjs = allWords;
}

+ (void) setScriptWords:(NSMutableDictionary *) scriptWordsDictionary {
    abScriptWordsDictionary = scriptWordsDictionary;
}


+ (void) initCoreDictionary {
    diceDictionary = [ABData loadCoreMutationsIndex];
    if(!diceDictionary) {
        NSLog(@"%@", @">> ERROR: CORE MUTATIONS TABLE NOT FOUND");
        // [ABDictionary generateCoreDictionary];
    } else {
        diceDictionary = [ABData loadDiceAdditionsAndAddToDictionary:diceDictionary];
    }
    
}

// Only used in dev, and needs to be manually triggered
// Thereafter saved as a local file
+ (void) generateCoreDictionary {
    NSLog(@"%@", @"Generating dictionary ...");
    diceDictionary = [NSMutableDictionary dictionaryWithDictionary:[ABDice topCoreMatchesForLexicon:[ABData loadWordList]]];
    [ABData saveCoreMutationsIndex:diceDictionary];
}




/////////////
// GETTERS //
/////////////

+ (ABScriptWord *) scriptWord:(NSString *)text {
    if(![abScriptWordsDictionary objectForKey:text]) return nil;
    return [abScriptWordsDictionary objectForKey:text];
}

+ (NSMutableArray *) diceForKey:(NSString *)text {
    if(![diceDictionary objectForKey:text]) return nil;
    return [diceDictionary objectForKey:text];
}

+ (ABScriptWord *) randomFromAllWords {
    int randomIndex = arc4random() % [allWordObjs count];
    return [allWordObjs objectAtIndex:randomIndex];
}





//////////////
// GRAFTING //
//////////////

+ (void) graftNewWords:(NSArray *)words {
    // Run processes to update lookup tables
    currentGraftWords = words;
}

+ (ABScriptWord *) getWordToGraft {
    return [currentGraftWords objectAtIndex:(arc4random() % [currentGraftWords count])];
}






/////////////
// LEXICON //
/////////////



// Add new words to scriptWords list temporarily (not persistently)
+ (void) addToScriptWords:(NSString *)text {
    ABScriptWord *sw = [[ABScriptWord alloc] initWithText:text sourceStanza:0];
    [allWordObjs addObject:sw];
    [abScriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];
}

+ (void) addToDice:(NSString *)text {
    
}




+ (void) addToAllWords:(ABScriptWord *)word {
    
}





@end
