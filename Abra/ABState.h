//
//  ABState.h
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABState : NSObject

+ (NSMutableArray *) initLines;

+ (BOOL) isRunningInBookMode;
+ (int) currentIndex;

+ (void) reset;
+ (void) clearMutations;
+ (void) forward;
+ (void) backward;
+ (void) accelerate;
+ (void) decelerate;

+ (void) graftText:(NSString *)text;

+ (void) pause;
+ (void) resume;

+ (void) increaseMutation;
+ (void) addToMutationLevel:(CGFloat)num;
+ (BOOL) attemptGesture;
+ (void) disallowGestures;
+ (void) allowGestures;

+ (int) checkMutationLevel;

+ (void) applicationWillResignActive;
+ (void) applicationDidBecomeActive;

+ (void) manuallyTransitionStanzaToNumber:(int)stanzaNumber;
+ (void) manuallyTransitionStanzaWithIncrement:(int)increment;
+ (void) setModeToStandalone;
+ (void) setModeToAutoplayMode;

+ (void) absentlyMutate;

+ (void) updatePrevStanzaLinesWithLine:(NSArray *)newLine atIndex:(int)lineNumber;


@end
