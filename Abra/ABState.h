//
//  ABState.h
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, InteractivityMode) { MUTATE, GRAFT, MAGIC, PRUNE, ERASE };
typedef NS_ENUM(NSInteger, modalType) { GRAFT_MODAL, SETTINGS_MODAL, INFO_MODAL, TIP_MODAL };


@interface ABState : NSObject


+ (NSMutableArray *) initLines;
+ (int) numberOfLinesToDisplay;
+ (NSArray *) getLines;

+ (void) changeAllLinesToLines:(NSArray *)newLines;


+ (BOOL) isRunningInBookMode;
+ (int) getCurrentStanza;
+ (NSArray *) getCurrentScriptWordLines;

+ (void) reset;
+ (void) clearMutations;
+ (void) turnPage:(int)direction;
+ (void) forward;
+ (void) backward;
+ (void) accelerate;
+ (void) decelerate;

+ (void) pause;
+ (void) resume;

//+ (void) increaseMutation;
//+ (void) addToMutationLevel:(CGFloat)num;
+ (BOOL) attemptGesture;
+ (void) disallowGestures;
+ (void) allowGestures;

+ (int) checkMutationLevel;

+ (void) applicationWillResignActive;
+ (void) applicationDidBecomeActive;

+ (void) manuallyTransitionStanzaToNumber:(int)stanzaNumber;
+ (void) manuallyTransitionStanzaWithIncrement:(int)increment;

+ (void) updateCurrentScriptWordLinesWithLine:(NSArray *)newLine atIndex:(int)lineNumber;

+ (void) absentlyMutate;

+ (void) setInteractivityModeTo:(InteractivityMode)mode;
+ (InteractivityMode) getCurrentInteractivityMode;

+ (BOOL) checkForChangedDisplayMode;



+ (void) setAutoMutation:(BOOL)value;
+ (void) setAutoplay:(BOOL)value;
+ (void) setIPhoneMode:(BOOL)value;
+ (void) setResetLexicon;



+ (void) setSpaceyMode:(BOOL)value;
+ (BOOL) checkSpaceyMode;

+ (void) setLinesAreFlipped:(BOOL)value;
+ (BOOL) checkLinesAreFlipped;

+ (void) setLinesAreWoven:(BOOL)value;
+ (BOOL) checkLinesAreWoven;


@end
