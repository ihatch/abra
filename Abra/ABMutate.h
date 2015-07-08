//
//  ABMutate.h
//  Abra
//
//  Created by Ian Hatcher on 2/21/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ABScriptWord;

@interface ABMutate : NSObject

+ (NSArray *) explodeWord:(ABScriptWord *)sw;
+ (NSArray *) multiplyWord:(ABScriptWord *)sw;
+ (NSArray *) graftWord:(ABScriptWord *)sw;
+ (NSArray *) mutateWord:(ABScriptWord *)sw inLine:(NSArray *)line;

+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel;
+ (NSArray *) remixStanza:(NSArray *)stanza andOldStanza:(NSArray *)oldStanza atMutationLevel:(int)mutationLevel andLimitTo:(int)limit;

+ (NSArray *) splitWordIntoLetters:(ABScriptWord *)word andSpaceOut:(BOOL)spaceOut;


+ (NSArray *) mutateLines:(NSArray *)stanza atMutationLevel:(int)mutationLevel;


@end
