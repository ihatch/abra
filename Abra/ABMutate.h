//
//  ABMutate.h
//  Abra
//
//  Created by Ian Hatcher on 2/21/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABMutate : NSObject

typedef enum { DICE, RANDOM, GRAFTWORD, EXPLODE, CUT, CLONE } mutationType;


+ (NSArray *) mutateLines:(NSArray *)stanza atMutationLevel:(int)mutationLevel;

+ (NSArray *) mutateRandomWordInLine:(NSArray *)line;
+ (NSArray *) mutateOneWordInLine:(NSArray *)line atWordIndex:(int)index;
+ (NSArray *) pruneOneWordInLine:(NSArray *)line atWordIndex:(int)index;
+ (NSArray *) graftOneWordInLine:(NSArray *)line atWordIndex:(int)index;
+ (NSArray *) multiplyOneWordInLine:(NSArray *)line atWordIndex:(int)index;
+ (NSArray *) explodeOneWordInLine:(NSArray *)line atWordIndex:(int)index;

+ (NSArray *) alterOneWordInLine:(NSArray *)line atIndex:(int)index withMutationType:(mutationType)type;

+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel;
+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel andLimitTo:(int)limit;



@end
