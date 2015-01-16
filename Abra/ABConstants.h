//
//  ABConstants.h
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

CGFloat ABF(CGFloat multiplier);
int ABI(int max);


@interface ABConstants : NSObject

extern int const ABRA_START_LINE;
extern int const ABRA_NUMBER_OF_LINES;
extern int const ABRA_START_STANZA;

extern NSString *const ABRA_FONT;
extern CGFloat const ABRA_FONT_SIZE;
extern CGFloat const ABRA_FONT_MARGIN;
extern CGFloat const ABRA_LINE_HEIGHT;

extern NSString *const ABRA_FLOWERBED_FONT;
extern CGFloat const ABRA_FLOWERBED_FONT_SIZE;
extern NSString *const ABRA_FLOWERS_FONT;
extern CGFloat const ABRA_FLOWERS_FONT_SIZE;

extern CGFloat const ABRA_NORMAL_SPEED;
extern CGFloat const ABRA_SPEED_CHANGE_INTERVAL;
extern CGFloat const ABRA_FASTEST_SPEED;
extern CGFloat const ABRA_SLOWEST_SPEED;
extern CGFloat const ABRA_SPEED_GRAVITY_FAST;
extern CGFloat const ABRA_SPEED_GRAVITY_SLOW;

extern CGFloat const ABRA_BASE_STANZA_TIME;
extern CGFloat const ABRA_WORD_ANIMATION_SPEED;
extern CGFloat const ABRA_WORD_FADE_OUT_DURATION;
extern CGFloat const ABRA_WORD_FADE_IN_DURATION;

extern CGFloat const ABRA_GESTURE_FEEDBACK_FADE_DURATION;
extern CGFloat const ABRA_GESTURE_TIME_BUFFER;
extern CGFloat const ABRA_TICKER_INTERVAL;

@end
