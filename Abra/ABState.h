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

+ (int) getCurrentStanza;
+ (int) getTotalWordsVisible;
+ (int) numberOfLinesToDisplay;

+ (NSArray *) getCurrentScriptWordLines;
+ (void) updateCurrentScriptWordLinesWithLine:(NSArray *)newLine atIndex:(int)lineNumber;

+ (NSArray *) getLines;
+ (void) changeAllLinesToLines:(NSArray *)newLines;
+ (void) manuallyTransitionStanzaToNumber:(int)stanzaNumber;
+ (void) manuallyTransitionStanzaWithIncrement:(int)increment;
+ (void) absentlyMutate;

// ---------

+ (void) turnPage:(int)direction;
+ (void) forward;
+ (void) backward;
+ (void) accelerate;
+ (void) decelerate;
+ (void) pause;
+ (void) resume;
+ (void) reset;
+ (void) setInteractivityModeTo:(InteractivityMode)mode;
+ (InteractivityMode) getCurrentInteractivityMode;

+ (BOOL) attemptGesture;
+ (void) disallowGestures;
+ (void) allowGestures;

// ---------

+ (int) checkMutationLevel;
+ (void) boostMutationLevel;
+ (void) clearMutations;

// ---------

+ (void) toggleTip:(NSString *)tip;
+ (BOOL) shouldShowTip:(NSString *)tip;
+ (void) resetTips;

// ---------

+ (void) setAutoMutation:(BOOL)value;
+ (BOOL) getAutoMutation;

+ (void) setAutoplay:(BOOL)value;
+ (BOOL) getAutoplay;

+ (void) setIPhoneMode:(BOOL)value;
+ (BOOL) getIPhoneMode;
+ (BOOL) checkForChangedDisplayMode;

+ (void) setResetLexicon;

// ---------

+ (void) setSpaceyMode:(BOOL)value;
+ (BOOL) checkSpaceyMode;

+ (void) setLinesAreFlipped:(BOOL)value;
+ (BOOL) checkLinesAreFlipped;

+ (void) setLinesAreWoven:(BOOL)value;
+ (BOOL) checkLinesAreWoven;

// ---------

+ (void) applicationWillResignActive;
+ (void) applicationDidBecomeActive;


@end
