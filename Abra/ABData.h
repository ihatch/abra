//
//  ABData.h
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABData : NSObject

+ (void) saveCoreMutationsIndex:(NSDictionary *)dataDict;
+ (void) saveModifiedMutationsIndex:(NSDictionary *)dataDict;
+ (NSMutableDictionary *) loadCoreMutationsIndex;
+ (NSMutableDictionary *) loadModifiedMutationsIndex;
+ (NSDictionary *) loadPrecompiledCoreData;

+ (NSArray *) loadRawStanzas;
+ (NSArray *) loadWordList;
+ (NSMutableDictionary *) loadDiceAdditionsAndAddToDictionary:(NSMutableDictionary *)diceDictionary;




@end
