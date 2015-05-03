//
//  ABDictionary.h
//  Abra
//
//  Created by Ian Hatcher on 2/21/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABScriptWord;

@interface ABDictionary : NSObject

+ (void) initCoreDictionary;

+ (void) setScriptWords:(NSMutableDictionary *) scriptWordsDictionary;
+ (void) addToScriptWords:(NSString *)text;
+ (ABScriptWord *) scriptWord:(NSString *)text;

+ (void) addToDice:(NSString *)text;
+ (NSMutableArray *) diceForKey:(NSString *)text;

+ (void) setAllWords:(NSMutableArray *)allWords;
+ (void) addToAllWords:(ABScriptWord *)word;
+ (ABScriptWord *) randomFromAllWords;

+ (void) graftNewWords:(NSArray *)words;
+ (ABScriptWord *) getWordToGraft;

@end
