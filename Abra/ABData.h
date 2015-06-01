//
//  ABData.h
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ABScriptWord;

@interface ABData : NSObject

+ (void) initAbraData;

+ (NSArray *) loadWordList;

+ (void) initCoreDictionary;

+ (void) setABScriptWordsDictionary:(NSMutableDictionary *) scriptWordsDictionary;
+ (void) addToScriptWords:(NSString *)text;
+ (ABScriptWord *) getRandomScriptWord;
+ (ABScriptWord *) getScriptWord:(NSString *)text;

+ (void) graftNewWords:(NSArray *)words;
+ (ABScriptWord *) getWordToGraft;
+ (ABScriptWord *) getPastGraftWord;  // TODO: integrate

@end
