////////////
//
//  ABState.m
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ABConstants.h"
#import "ABUI.h"
#import "ABScript.h"
#import "ABState.h"
#import "ABClock.h"
#import "ABLine.h"
#import "ABWord.h"
#import "ABMutate.h"
#import "ABData.h"
#import "ABCadabra.h"
#import "ABHistory.h"

@implementation ABState

NSArray *currentScriptWordLines;
NSMutableArray *ABLines;

BOOL isInitialized, isAnimating, preventGestures;

int currentStanza;
double lastGestureTime;
CGFloat mutationLevel;

typedef NS_ENUM(NSInteger, ScriptDirection) { FORWARD, BACKWARD };
ScriptDirection scriptDirection;
InteractivityMode currentInteractivityMode;


NSDate *lastDialSetTime;
int dialThrottleMs;

BOOL settingAutonomousMutation;
BOOL settingAutoplay;
BOOL settingIPhoneDisplayMode;
BOOL settingIPhoneDisplayModeHasChanged;

BOOL secretSettingSpaceyMode;
BOOL linesAreFlipped;
BOOL linesAreWoven;

ABHistory *history;
NSUserDefaults *defaults;

static ABState *ABStateInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABStateInstance == NULL) ABStateInstance = [[ABState alloc] init];
    }
}


- (id) init {
    if(self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionStanza:) name:@"transitionStanza" object:nil];
        history = [ABHistory history];
        
        [ABState initUserDefaults];
        
        isInitialized = YES;
        lastDialSetTime = [NSDate date];
        dialThrottleMs = 200;
        lastGestureTime = CACurrentMediaTime();
        preventGestures = NO;

        currentStanza = ABRA_START_STANZA;
        scriptDirection = FORWARD;

        currentInteractivityMode = MUTATE;

        settingIPhoneDisplayModeHasChanged = NO;
        secretSettingSpaceyMode = NO;
        linesAreFlipped = NO;
        
        [ABClock start];
        
    }
    return self;
}




///////////////////////
// APPLICATION STATE //
///////////////////////

+ (void) applicationWillResignActive {
    [ABClock deactivate];
}

+ (void) applicationDidBecomeActive {
    if(!isInitialized) return;
    [ABClock reactivate];
}


+ (void) initUserDefaults {
//    
//    defaults = [NSUserDefaults standardUserDefaults];
//    
//    int sAutoplay = (int)[defaults integerForKey:@"setting-autoplay"];
//    int sAutoMutate = (int)[defaults integerForKey:@"setting-automutate"];
//    int sFiveLines = (int)[defaults integerForKey:@"setting-fivelines"];
//
//    DDLogInfo(@"Setting: Autoplay %i", sAutoplay);
//    DDLogInfo(@"Setting: Auto-mutate %i", sAutoMutate);
//    DDLogInfo(@"Setting: Five lines %i", sFiveLines);
    
    settingAutoplay = NO; //(BOOL)sAutoplay;
    settingAutonomousMutation = YES; // (BOOL)sAutoMutate;
    settingIPhoneDisplayMode = NO; // (BOOL)sFiveLines;
    
}






////////////////
// INIT LINES //
////////////////


+ (NSMutableArray *) initLines {
    
    NSArray *stanza = [ABScript linesAtStanzaNumber:currentStanza];
    currentScriptWordLines = stanza;
    
    int lineHeight = [ABUI abraLineHeight];
    CGFloat heightOffset = (kScreenHeight - (lineHeight * [ABState numberOfLinesToDisplay])) / 2;
    
    ABLines = [NSMutableArray array];
    
    int p = 0;
    for(int s = ABRA_START_LINE; s < ABRA_START_LINE + [ABState numberOfLinesToDisplay]; s ++) {
        NSArray *words = (s < [stanza count]) ? stanza[s] : [ABScript emptyLine];
        CGFloat y = heightOffset + (p++ * lineHeight);
        [ABLines addObject:[[ABLine alloc] initWithWords:words andYPosition:y andHeight:lineHeight andLineNumber:s]];
    }
    
    return ABLines;
}

+ (int) numberOfLinesToDisplay {
    if([ABUI isIphone] || settingIPhoneDisplayMode == YES) return 5; else return 11;
}

+ (NSArray *) getLines {
    return ABLines;
}




///////////
// MODEL //
///////////

+ (void) setInteractivityModeTo:(InteractivityMode)mode {
    currentInteractivityMode = mode;
}

+ (InteractivityMode) getCurrentInteractivityMode {
    return currentInteractivityMode;
}

+ (BOOL) isRunningInBookMode {
    return settingAutoplay;
}

+ (int) getCurrentStanza {
    return currentStanza;
}

+ (void) reset {
    mutationLevel = 0;
    if(settingAutoplay) {
        currentStanza = -1;
        scriptDirection = FORWARD;
    } else {
        currentStanza = 0;
        [ABState manuallyTransitionStanzaWithIncrement:0];
    }
}

+ (void) clearMutations {
    mutationLevel = 0;
    [ABState manuallyTransitionStanzaWithIncrement:0];
}

+ (void) turnPage:(int)direction {
    if(settingAutoplay) {
        if(direction == 1) scriptDirection = FORWARD;
        if(direction == -1) scriptDirection = BACKWARD;
    } else {
        [ABState manuallyTransitionStanzaWithIncrement:direction];
    }
}

+ (void) forward {
    if(settingAutoplay) scriptDirection = FORWARD;
    else [ABState manuallyTransitionStanzaWithIncrement:1];
}

+ (void) backward {
    if(settingAutoplay) scriptDirection = BACKWARD;
    else [ABState manuallyTransitionStanzaWithIncrement:-1];
}

+ (void) accelerate {
    [ABClock accelerate];
}

+ (void) decelerate {
    [ABClock decelerate];
}

+ (void) pause {
    [ABClock pause];
}

+ (void) resume {
    [ABClock resume];
}

+ (void) normalSpeed {
    [ABClock setSpeedTo:ABRA_NORMAL_SPEED];
}


+ (int) checkMutationLevel {
    return mutationLevel;
}



+ (void) updateCurrentScriptWordLinesWithLine:(NSArray *)newLine atIndex:(int)lineNumber {
    
    NSMutableArray *newStanza = [NSMutableArray array];
    
    for(int l=0; l < [currentScriptWordLines count]; l ++) {
        if(l == lineNumber) [newStanza addObject:newLine];
        else [newStanza addObject:[currentScriptWordLines objectAtIndex:l]];
    }
    
    currentScriptWordLines = [NSArray arrayWithArray:newStanza];
}

+ (NSArray *) getCurrentScriptWordLines {
    NSMutableArray *lines = [NSMutableArray array];
    for(int i=0; i < MIN([ABState numberOfLinesToDisplay], [currentScriptWordLines count]); i ++) {
        [lines addObject:[currentScriptWordLines objectAtIndex:i]];
    }
    return [NSArray arrayWithArray:lines];
}






/////////////////
// TRANSITIONS //
/////////////////


+ (void) changeAllLinesToLines:(NSArray *)newLines {
    int c = 0;
    for(int s = ABRA_START_LINE; s < ABRA_START_LINE + [ABState numberOfLinesToDisplay]; s++) {
        if(c >= [ABLines count]) continue;
        NSArray *newWords = (s < [newLines count]) ? newLines[s] : [ABScript emptyLine];
        [[ABLines objectAtIndex:c++] changeWordsToWords:newWords];
    }
}


+ (void) transitionToStanza:(int)index {
    
    int firstIndex = [ABScript firstStanzaIndex];
    int lastIndex = [ABScript lastStanzaIndex];
    int loopStanza = (lastIndex + 1);
    NSArray *newLines;

    if(currentStanza == -1 && index == loopStanza) {
        currentStanza = loopStanza;
        return;
    }
    
    DDLogInfo(@"Stanza transition: %i -> %i (%i %i)", currentStanza, index, firstIndex, lastIndex);

    
    if(index == firstIndex - 1) {
        newLines = [ABScript mixStanzaLines:currentScriptWordLines withStanzaAtIndex:lastIndex];
        
    } else if(index == lastIndex + 1) {
        newLines = [ABScript mixStanzaLines:currentScriptWordLines withStanzaAtIndex:firstIndex];
        
    } else {
        newLines = [ABScript linesAtStanzaNumber:index];
    }
    
    if(mutationLevel > 0) {
        newLines = [ABMutate remixStanza:newLines andOldStanza:currentScriptWordLines atMutationLevel:mutationLevel];
        mutationLevel --;
    }
    
    if([newLines count] > [ABState numberOfLinesToDisplay]) {
        newLines = [newLines subarrayWithRange:NSMakeRange(0, [ABState numberOfLinesToDisplay])];
    }

    // Chance to turn off spacey mode, if it's on
    if(secretSettingSpaceyMode == YES) {
        if(ABI(3) == 0) secretSettingSpaceyMode = NO;
        else newLines = [ABCadabra spaceyLettersMagic:newLines];
    }
    
    currentStanza = index;
    currentScriptWordLines = newLines;
    [ABState changeAllLinesToLines:newLines];

}



- (void) transitionStanza:(NSNotification *) notification {
    
    if (!([[notification name] isEqualToString:@"transitionStanza"])) return;
    int index = currentStanza;
    
    if(scriptDirection == FORWARD) index ++;
    if(scriptDirection == BACKWARD) index --;
    
    int firstIndex = [ABScript firstStanzaIndex];
    int lastIndex  = [ABScript lastStanzaIndex];
    
    // Loop script forward / backward
    if(index > lastIndex + 1) index = firstIndex;
    if(index < firstIndex - 1) index = lastIndex;


    [ABState transitionToStanza:index];
}



+ (void) manuallyTransitionStanzaWithIncrement:(int)increment {
    
    int index = currentStanza;
    index += increment;
    
    int firstIndex  = [ABScript firstStanzaIndex];
    int lastIndex   = [ABScript lastStanzaIndex];
    int stanzaCount = [ABScript scriptStanzasCount];
    
    if(index > lastIndex + 1) index = index - stanzaCount - 1;
    if(index < firstIndex - 1) index = index + stanzaCount + 1;
    
    // Loop script forward / backward
    if(index > lastIndex + 1) index = firstIndex;
    if(index < firstIndex - 1) index = lastIndex;
    
    [ABState transitionToStanza:index];
}


+ (void) manuallyTransitionStanzaToNumber:(int)stanzaNumber {
    if(stanzaNumber == currentStanza) return;
    if(currentStanza == 0 && stanzaNumber == [ABScript lastStanzaIndex] + 1) stanzaNumber = -1;
    double timePassed_ms = [lastDialSetTime timeIntervalSinceNow] * -1000.0;
    if(timePassed_ms < dialThrottleMs) return;
    lastDialSetTime = [NSDate date];
    [ABState transitionToStanza:stanzaNumber];
}


+ (void) absentlyMutate {
    if(settingAutonomousMutation == NO) return;
    if([currentScriptWordLines count] == 0) return;
    int max = MIN((int)[currentScriptWordLines count], [ABState numberOfLinesToDisplay]);
    int i = ABI(max);
    [[ABLines objectAtIndex:i] absentlyMutate];
}


+ (int) getTotalWordsVisible {
    int i = 0;
    for(ABLine *line in ABLines) i += (int)[line.lineWords count];
    return i;
}




///////////////////
// GESTURE CHECK //
///////////////////

+ (BOOL) attemptGesture {
    if(preventGestures) return NO;
    double currentTime = CACurrentMediaTime();

    if(currentTime < (lastGestureTime + ABRA_GESTURE_TIME_BUFFER)) {
        return NO;
    } else {
        lastGestureTime = currentTime;
        return YES;
    }
}

+ (void) disallowGestures {
    preventGestures = YES;
}

+ (void) allowGestures {
    preventGestures = NO;
}








//////////////
// SETTINGS //
//////////////

+ (void) setAutoMutation:(BOOL)value {
    DDLogInfo(@"set setAutoMutation %d", value);
    settingAutonomousMutation = value;
//    [defaults setInteger:(int)value forKey:@"setting-automutate"];
//    [defaults synchronize];
}

+ (BOOL) getAutoMutation {
    return settingAutonomousMutation;
}

+ (void) setAutoplay:(BOOL)value {
    DDLogInfo(@"set setAutoplay %d", value);
    settingAutoplay = value;
    if(value == YES) [ABClock startAutoProgress];
    else [ABClock stopAutoProgress];
//    [defaults setInteger:(int)value forKey:@"setting-autoplay"];
//    [defaults synchronize];
}

+ (BOOL) getAutoplay {
    return settingAutonomousMutation;
}

+ (void) setIPhoneMode:(BOOL)value {
    DDLogInfo(@"set setIPhoneMode %d", value);
    settingIPhoneDisplayMode = value;
    settingIPhoneDisplayModeHasChanged = YES;
//    [defaults setInteger:(int)value forKey:@"setting-fivelines"];
//    [defaults synchronize];
}

+ (BOOL) getIPhoneMode {
    return settingIPhoneDisplayMode;
}


+ (void) setResetLexicon {
    DDLogInfo(@"set setResetLexicon");
    [ABData resetLexicon];
    [[[UIAlertView alloc] initWithTitle:@"" message:@"“our birth is but a sleep and a forgetting...” ―wordsworth" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}



+ (void) setSpaceyMode:(BOOL)value {
    secretSettingSpaceyMode = value;
}
+ (BOOL) checkSpaceyMode {
    return secretSettingSpaceyMode;
}

+ (void) setLinesAreFlipped:(BOOL)value {
    linesAreFlipped = value;
}
+ (BOOL) checkLinesAreFlipped {
    return linesAreFlipped;
}


+ (void) setLinesAreWoven:(BOOL)value {
    linesAreWoven = value;
}
+ (BOOL) checkLinesAreWoven {
    return linesAreWoven;
}




+ (BOOL) checkForChangedDisplayMode {
    if(settingIPhoneDisplayModeHasChanged == NO) return NO;
    for(ABLine *line in ABLines) [line destroyAllWords];
    settingIPhoneDisplayModeHasChanged = NO;
    return YES;
}


@end
