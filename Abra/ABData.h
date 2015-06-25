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

+ (void) initData;

+ (NSArray *) loadWordList;

+ (void) initCoreDictionary;
+ (void) saveDiceAdditions:(NSMutableDictionary *) diceAdditions;
+ (void) setABScriptWordsDictionary:(NSMutableDictionary *) scriptWordsDictionary;


+ (ABScriptWord *) getScriptWord:(NSString *)text;
+ (ABScriptWord *) getScriptWordAndRunChecks:(NSString *)text;
+ (ABScriptWord *) getScriptWord:(NSString *)text withSourceStanza:(int)sourceStanza;
+ (ABScriptWord *) scriptWord:(NSString *)text stanza:(int)stanza fam:(NSArray *)family leftSis:(NSString *)leftSis rightSis:(NSString *)rightSis graft:(BOOL)graft check:(BOOL)check;
+ (ABScriptWord *) getRandomScriptWord;


+ (void) graftNewWords:(NSArray *)words;
+ (BOOL) graftText:(NSString *)text;
+ (ABScriptWord *) getWordToGraft;
+ (ABScriptWord *) getPastGraftWord;


+ (void) resetLexicon;




@end