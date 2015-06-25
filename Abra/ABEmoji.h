//
//  ABEmoji.h
//  Abra
//
//  Created by Ian Hatcher on 6/22/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABEmoji : NSObject

+ (void) initEmoji;

+ (NSString *) getRandomEmojiStringWithColor:(NSString *)color;
+ (NSString *) getRandomEmojiStringWithConcept:(NSString *)concept;
+ (NSString *) getEmojiOfSameColorAsEmoji:(NSString *)emoji;


+ (BOOL) isEmoji:(NSString *)charString;
+ (NSString *) getEmojiForStanza:(int)stanza;

+ (NSString *) emojiWordTransform:(NSString *)string;

@end
