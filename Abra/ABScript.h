//
//  ABScripts.h
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABScript : NSObject

+ (id) linesAtStanzaNumber:(int)stanza;
+ (id) wordsAtStanzaNumber:(int)stanza andLineNumber:(int)line;
+ (id) emptyLine;

+ (int) scriptStanzasCount;
+ (int) totalStanzasCount;
+ (int) firstStanzaIndex;
+ (int) lastStanzaIndex;

+ (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t;

+ (NSArray *) parseGraftTextIntoScriptWords:(NSString *)text;
+ (NSArray *) graftText:(NSArray *)scriptWords intoStanzaLines:(NSArray *)stanzaLines;

+ (NSArray *) mutateLines:(NSArray *)stanza atMutationLevel:(int)mutationLevel;


+ (NSArray *) mutateRandomWordInLine:(NSArray *)line;
+ (NSArray *) mutateOneWordInLine:(NSArray *)line atWordIndex:(int)index;
+ (NSArray *) explodeOneWordInLine:(NSArray *)line atWordIndex:(int)index;


+ (NSArray *) mixStanzaLines:(NSArray *)oldStanzaLines withStanzaAtIndex:(int)stanzaIndex;
+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel;
+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel andLimitTo:(int)limit;


@end
