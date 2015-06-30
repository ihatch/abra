//
//  ABCadabra.h
//  Abra
//
//  Created by Ian Hatcher on 6/9/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABCadabra : NSObject


+ (void) castSpell:(NSString *)spell;

+ (NSArray *) spaceyLettersMagic:(NSArray *)lines;

+ (void) revealCadabraWords;

@end
