//
//  ABConstants.h
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CocoaLumberjack/CocoaLumberjack.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


CGFloat ABF(CGFloat multiplier);
int ABI(int max);


@interface ABConstants : NSObject

extern NSString *const ABRA_FONT;
extern NSString *const ABRA_ITALIC_FONT;
extern NSString *const ABRA_FLOWERS_FONT;
extern NSString *const ABRA_SYSTEM_FONT;

extern int const ABRA_START_LINE;
extern int const ABRA_START_STANZA;

extern CGFloat const ABRA_NORMAL_SPEED;
extern CGFloat const ABRA_FASTEST_SPEED;
extern CGFloat const ABRA_SLOWEST_SPEED;
extern CGFloat const ABRA_SPEED_CHANGE_INTERVAL;
extern CGFloat const ABRA_SPEED_GRAVITY_FAST;
extern CGFloat const ABRA_SPEED_GRAVITY_SLOW;

extern CGFloat const ABRA_BASE_STANZA_TIME;
extern CGFloat const ABRA_WORD_ANIMATION_SPEED;
extern CGFloat const ABRA_WORD_FADE_OUT_DURATION;
extern CGFloat const ABRA_WORD_FADE_IN_DURATION;

extern CGFloat const ABRA_GESTURE_FEEDBACK_FADE_DURATION;
extern CGFloat const ABRA_GESTURE_TIME_BUFFER;
extern CGFloat const ABRA_TICKER_INTERVAL;

extern NSString *const EMOJI_REGEX;

// -----

extern NSString *const SYMBOLS_CHESS;
extern NSString *const SYMBOLS_DEATH;

extern NSString *const BLOCK_BLACK_BOX;

extern NSString *const WORDS_DONE_HERE;
extern NSString *const WORDS_SPEAK;
extern NSString *const WORDS_COLOR_BARS;
extern NSString *const WORDS_ATTENTION;
extern NSString *const WORDS_SYNC_RATES;
extern NSString *const WORDS_NETWORK;
extern NSString *const WORDS_PYTHON;
extern NSString *const WORDS_PERIMETER;
extern NSString *const WORDS_STING;





@end
