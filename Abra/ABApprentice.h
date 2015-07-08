//
//  ABApprentice.h
//  Abra
//
//  Created by Ian Hatcher on 7/5/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ABScriptWord;

@interface ABApprentice : NSObject

- (NSString *) randomSpell;

////////////////////////////////////

- (NSString *) randomStringFrom:(NSString *)source;
- (ABScriptWord *) randomSWFrom:(NSString *)source;
- (int) rndIndex:(NSArray *)array;


- (BOOL) searchLines:(NSArray *)lines forWord:(NSString *)word;
- (NSArray *) locationsOfGraftsIn:(NSArray *)SWArray;
- (NSArray *) locationsOfEmojiIn:(NSArray *)SWArray;
- (NSArray *) locationsOfMutationsIn:(NSArray *)SWArray;

- (NSArray *) mapWithOddsFrom:(CGFloat)startOdds to:(CGFloat)endOdds total:(int)totalItems min:(int)min max:(int)max;
- (NSArray *) fullMapWithPercent:(CGFloat)percent andStanzaLines:(NSArray *)lines;
- (NSArray *) fullMapWithPercent:(CGFloat)percent andABLines:(NSArray *)lines;

- (int) averageSourceStanzas:(ABScriptWord *)sw1 and:(ABScriptWord *)sw2;


- (NSArray *) splitArrayInHalf:(NSArray *)wholeArray;
- (NSArray *) splitParagraphIntoLinesOfScriptWords:(NSString *)paragraph;


- (ABScriptWord *) swEmojiForConcept:(NSString *)concept;
- (ABScriptWord *) swWordFromString:(NSString *)string;
- (ABScriptWord *) swCharFromString:(NSString *)string;
- (ABScriptWord *) swSymbol;
- (NSArray *) swInsert:(ABScriptWord *)sw0 after:(ABScriptWord *)sw1 before:(ABScriptWord *)sw2;
- (NSArray *) swReplace:(ABScriptWord *)sw0 after:(ABScriptWord *)sw1 before:(ABScriptWord *)sw2;


- (NSArray *) mutateMultipleWordsInLine:(NSArray *)line withMap:(NSArray *)map;


@end
