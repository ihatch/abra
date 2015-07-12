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

+ (void) initCoreDictionary;
+ (void) saveDiceAdditions:(NSMutableDictionary *) diceAdditions;
+ (void) setABScriptWordsDictionary:(NSMutableDictionary *) scriptWordsDictionary;
+ (void) resetLexicon;

+ (NSArray *) loadWordList;



+ (ABScriptWord *) getScriptWord:(NSString *)text;
+ (ABScriptWord *) getScriptWordAndRunChecks:(NSString *)text;

+ (ABScriptWord *) getScriptWord:(NSString *)text withSourceStanza:(int)sourceStanza;

+ (ABScriptWord *) scriptWord:(NSString *)text stanza:(int)stanza fam:(NSArray *)family leftSis:(NSString *)leftSis rightSis:(NSString *)rightSis graft:(BOOL)graft check:(BOOL)check;

+ (ABScriptWord *) scriptWord:(NSString *)text stanza:(int)stanza fam:(NSArray *)family leftSisters:(NSArray *)leftSis rightSisters:(NSArray *)rightSis graft:(BOOL)graft check:(BOOL)check;

+ (ABScriptWord *) getRandomScriptWord;



+ (BOOL) graftText:(NSString *)text;
+ (ABScriptWord *) getWordToGraft;
+ (ABScriptWord *) getPastGraftWord;

+ (NSString *) checkMagicWord:(NSString *)word;


@end