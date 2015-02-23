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

@implementation ABDictionary

NSMutableDictionary *diceDictionary;
NSMutableDictionary *abScriptWordsDictionary;
NSMutableArray *allWordObjs;

NSMutableArray *userScriptWordsDictionary;   //  <<------ TODO
NSMutableArray *graftsHistory;
NSArray *currentUserGraftWords;

static ABDictionary *ABDictionaryInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABDictionaryInstance == NULL) ABDictionaryInstance = [[ABDictionary alloc] init];
        diceDictionary = [ABData loadCoreMutationsIndex];
        diceDictionary = [ABData loadDiceAdditionsAndAddToDictionary:diceDictionary];
    }
}



+ (void) setScriptWords:(NSMutableDictionary *) scriptWordsDictionary {
    abScriptWordsDictionary = scriptWordsDictionary;
}

// Add new words to lexicon
+ (void) addToScriptWords:(NSString *)text {
    ABScriptWord *sw = [[ABScriptWord alloc] initWithText:text sourceStanza:0];
    [allWordObjs addObject:sw];
    [abScriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];
}

+ (ABScriptWord *) scriptWord:(NSString *)text {
    if(![abScriptWordsDictionary objectForKey:text]) return nil;
    return [abScriptWordsDictionary objectForKey:text];
}




+ (void) addToDice:(NSString *)text {
    
}

+ (NSMutableArray *) diceForKey:(NSString *)text {
    if(![diceDictionary objectForKey:text]) return nil;
    return [diceDictionary objectForKey:text];
}




+ (void) setAllWords:(NSMutableArray *)allWords {
    allWordObjs = allWords;
}

+ (void) addToAllWords:(ABScriptWord *)word {
    
}

+ (ABScriptWord *) randomFromAllWords {
    int randomIndex = arc4random() % [allWordObjs count];
    return [allWordObjs objectAtIndex:randomIndex];
}



+ (void) graftNewWords:(NSArray *)words {
    currentUserGraftWords = words;
}

+ (ABScriptWord *) getWordToGraft {
    return [currentUserGraftWords objectAtIndex:(arc4random() % [currentUserGraftWords count])];
}




@end
