//
//  ABState.h
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SpellMode) { MUTATE, GRAFT, MAGIC, PRUNE, ERASE };
typedef NS_ENUM(NSInteger, modalType) { GRAFT_MODAL, SETTINGS_MODAL, INFO_MODAL, TIP_MODAL };
typedef NS_ENUM(NSInteger, mutationType) { DICE, RANDOM, GRAFTWORD, EXPLODE, CLONE };

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
+ (void) setSpellModeTo:(SpellMode)mode;
+ (SpellMode) getCurrentSpellMode;

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

// ---------

+ (void) setFx:(NSString *)fx to:(BOOL)value;
+ (BOOL) fx:(NSString *)fx;

// ---------

+ (void) incrementUserActions;
+ (void) copyAllTextToClipboard;

+ (void) applicationWillResignActive;
+ (void) applicationDidBecomeActive;


@end
