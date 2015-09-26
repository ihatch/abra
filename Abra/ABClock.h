//
//  ABClock.h
//  Abra
//
//  Created by Ian Hatcher on 1/7/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABClock : NSObject

+ (void) start;
+ (void) startAutoProgress;
+ (void) stopAutoProgress;

+ (CGFloat) speed;
+ (void) setSpeedTo:(CGFloat)speed;

+ (void) accelerate;
+ (void) decelerate;
+ (void) pause;
+ (void) resume;
+ (void) deactivate;
+ (void) reactivate;
+ (void) updateLastInteractionTime;

@end
