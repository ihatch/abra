//
//  ABCadabra.h
//  Abra
//
//  Created by Ian Hatcher on 6/9/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABCadabra : NSObject

+ (void) castSpell;
+ (void) castSpell:(NSString *)spell;
+ (void) castSpell:(NSString *)spell magicWord:(NSString *)magicWord;

+ (void) revealCadabraWords;

+ (NSArray *) spaceyLetters:(NSArray *)lines andSpaceOut:(BOOL)spaceOut inTransition:(BOOL)inTransition;


@end
