//
//  ABClock.m
//  Abra
//
//  Created by Ian Hatcher on 1/7/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABConstants.h"
#import "ABState.h"
#import "ABClock.h"

@implementation ABClock

typedef NS_ENUM(NSInteger, ClockState) {
    RUNNING,
    PAUSED,
    DEACTIVATED
};

BOOL autoProgress;

NSTimer *timer;
ClockState clockState;

CGFloat speed;
CGFloat stanzaInterval;
double lastStanzaTime;
double nextStanzaTime;
double lastInteractionTime;
double initTime;

static ABClock *ABClockInstance = NULL;

+ (void) initialize {
    @synchronized(self) {
        if (ABClockInstance == NULL) {
            ABClockInstance = [[self alloc] init];
            speed = ABRA_NORMAL_SPEED;
            initTime = CACurrentMediaTime();
        }
    }
}


+ (void) start {
    [ABClock startTimer];
}

+ (void) startAutoProgress {
    autoProgress = YES;
    [ABClock updateLastStanzaTime];
    [ABClock updateNextStanzaTime];
}

+ (void) stopAutoProgress {
    autoProgress = NO;
}

+ (void) startTimer {
    clockState = RUNNING;
    timer = [NSTimer scheduledTimerWithTimeInterval:ABRA_TICKER_INTERVAL target:ABClockInstance selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void) tick: (NSTimer *) timer {
    
    // If any state other than running, do nothing
    if(clockState != RUNNING) return;
    
    // If not next scheduled transition time yet, do nothing
    double currentTime = CACurrentMediaTime();    
    
    if (autoProgress) {
        if ((float)currentTime > (float)nextStanzaTime) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"transitionStanza" object:self];
            [ABClock updateLastStanzaTime];
            [ABClock updateNextStanzaTime];
        }
    }


    int modifier = (int)[ABState checkMutationLevel];
    if(modifier > 20) modifier = 20;

    if(ABRA_ABSENTLY_MUTATE) {
        if ((float)currentTime - (float)lastInteractionTime > 5 &&
            (float)currentTime - (float)initTime > 15 && ABI(25 - (modifier)) == 0) {
            [ABState absentlyMutate];
        }
    }
    
}



+ (CGFloat) stanzaTime {
    return (ABRA_BASE_STANZA_TIME * speed);
}

+ (void) updateLastStanzaTime {
    lastStanzaTime = CACurrentMediaTime();
}

+ (void) updateNextStanzaTime {
    nextStanzaTime = lastStanzaTime + [ABClock stanzaTime];
}

+ (void) updateLastInteractionTime {
    lastInteractionTime = CACurrentMediaTime();
}

+ (CGFloat) currentSpeed {
    return speed;
}

+ (void) setSpeedTo:(CGFloat)newSpeed {
    speed = newSpeed;
}

+ (void) accelerate {
    CGFloat newSpeed = speed - ABRA_SPEED_CHANGE_INTERVAL;
    if(newSpeed < ABRA_FASTEST_SPEED) return;
    if(speed > ABRA_NORMAL_SPEED + ABRA_SPEED_CHANGE_INTERVAL) {
        newSpeed = ABRA_NORMAL_SPEED;
    }
    speed = newSpeed;
}

+ (void) decelerate {
    CGFloat newSpeed = speed + ABRA_SPEED_CHANGE_INTERVAL;
    if(newSpeed > ABRA_SLOWEST_SPEED) return;
    if(speed < ABRA_NORMAL_SPEED - ABRA_SPEED_CHANGE_INTERVAL) {
        newSpeed = ABRA_NORMAL_SPEED;
    }
    speed = newSpeed;
}



+ (void) pause {
    clockState = PAUSED;
}

+ (void) resume {
    clockState = RUNNING;
}

+ (void) deactivate {
    if(!timer) return;
    clockState = DEACTIVATED;
    [timer invalidate];
    timer = nil;
}

+ (void) reactivate {
    if(timer || clockState != DEACTIVATED) return;
    [ABClock startTimer];
}



@end
