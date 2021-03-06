//
//  ABScripts.h
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABScriptWord;

@interface ABScript : NSObject

+ (void) initScriptWithDataArray:(NSArray *)scriptDataArray;
+ (NSMutableDictionary *) initScriptAndParseScriptFile;

+ (id) linesAtStanzaNumber:(int)stanza;
+ (id) wordsAtStanzaNumber:(int)stanza andLineNumber:(int)line;
+ (id) emptyLine;

+ (int) scriptStanzasCount;
+ (int) totalStanzasCount;
+ (int) firstStanzaIndex;
+ (int) lastStanzaIndex;

+ (NSArray *) allWordsInLines:(NSArray *)stanza;
+ (ABScriptWord *) randomScriptWordFromSet:(NSArray *)words;
+ (ABScriptWord *) trulyRandomWord;

+ (NSArray *) mixStanzaLines:(NSArray *)oldStanzaLines withStanzaAtIndex:(int)stanzaIndex;

@end
