//
//  ABDice.h
//  Abra
//
//  Created by Ian Hatcher on 2/15/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABDice : NSObject

+ (void) setDiceDictionary:(NSMutableDictionary *)dict;
+ (void) setDiceAdditions:(NSDictionary *)dict;
+ (void) addNonEnglishLanguageDiceDictionary:(NSDictionary *)dict andLangString:(NSString *)langString;

+ (void) generateDiceDictionary;

+ (NSMutableArray *) diceForKey:(NSString *)text;

+ (void) updateDiceDictionaryWithStrings:(NSArray *)strings;
+ (NSDictionary *) createDiceDictionaryToBeSavedWithStrings:(NSArray *)strings;
+ (void) resetLexicon;

@end
