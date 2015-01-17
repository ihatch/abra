//
//  ABConstants.m
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#include <stdlib.h>
#import "ABConstants.h"


//////////////////////////////
// GLOBAL UTILITY FUNCTIONS //
//////////////////////////////

CGFloat ABF(CGFloat multiplier) {
    return ((float)rand() / RAND_MAX) * multiplier;
}
int ABI(int max) {
    return (int) arc4random_uniform(max);
}


///////////////
// CONSTANTS //
///////////////



@implementation ABConstants

int const ABRA_START_LINE = 0;
int const ABRA_NUMBER_OF_LINES = 11;
int const ABRA_START_STANZA = 0;

NSString *const ABRA_FONT = @"IM FELL Great Primer PRO";
NSString *const ABRA_FLOWERS_FONT = @"IM FELL FLOWERS 2";

CGFloat const ABRA_NORMAL_SPEED = 1.0;
CGFloat const ABRA_SLOWEST_SPEED = 1.5;
CGFloat const ABRA_FASTEST_SPEED = 0.2;
CGFloat const ABRA_SPEED_CHANGE_INTERVAL = 0.25;
CGFloat const ABRA_SPEED_GRAVITY_FAST = 0.01;
CGFloat const ABRA_SPEED_GRAVITY_SLOW = 0.03;

CGFloat const ABRA_BASE_STANZA_TIME = 6.0;
CGFloat const ABRA_WORD_ANIMATION_SPEED = 1100;
CGFloat const ABRA_WORD_FADE_OUT_DURATION = 400;
CGFloat const ABRA_WORD_FADE_IN_DURATION = 400;

CGFloat const ABRA_GESTURE_FEEDBACK_FADE_DURATION = 0.65;
CGFloat const ABRA_GESTURE_TIME_BUFFER = 0.75;
CGFloat const ABRA_TICKER_INTERVAL = 0.2;

@end
