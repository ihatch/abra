//
//  ABDice.h
//  Abra
//
//  Created by Ian Hatcher on 2/15/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABDice : NSObject

+ (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t;

+ (void) initCacheWithLexicon:(NSArray *)lexicon;

+ (NSArray *) topMatchesForTerm:(NSString *)term inLexicon:(NSArray *)lexicon;

+ (NSDictionary *) topCoreMatchesForLexicon:(NSArray *)lexicon;

@end
