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
NSDate *lastDialSetTime;
int dialThrottleMs;

typedef NS_ENUM(NSInteger, ScriptDirection) { FORWARD, BACKWARD };
ScriptDirection scriptDirection;
SpellMode currentSpellMode;
CGFloat mutationLevel;

int userActionsOnThisStanza;
int autoMutationsOnThisStanza;

ABHistory *history;
NSUserDefaults *defaults;

int tipWelcome, tipGraft, tipSpellMode, tipCadabra;
BOOL settingAutonomousMutation, settingAutoplay, settingIPhoneDisplayMode, settingIPhoneDisplayModeHasChanged;
BOOL secretSettingSpaceyMode, linesAreFlipped, linesAreWoven;

BOOL DEV_PREVENT_TIPS;



static ABState *ABStateInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABStateInstance == NULL) ABStateInstance = [[ABState alloc] init];
    }
}


- (id) init {
    if(self = [super init]) {
        
        DEV_PREVENT_TIPS = YES;
        [ABState resetTips];
        [ABState initTips];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionStanza:) name:@"transitionStanza" object:nil];
        history = [ABHistory history];
        
        [ABState initSettings];
        
        isInitialized = YES;
        lastDialSetTime = [NSDate date];
        dialThrottleMs = 200;
        lastGestureTime = CACurrentMediaTime();
        preventGestures = NO;

        userActionsOnThisStanza = 0;
        autoMutationsOnThisStanza = 0;

        currentStanza = ABRA_START_STANZA;
        scriptDirection = FORWARD;
        currentSpellMode = MUTATE;

        settingIPhoneDisplayModeHasChanged = NO;
        secretSettingSpaceyMode = NO;
        linesAreFlipped = NO;
        
        [ABClock start];
        
    }
    return self;
}






///////////////////////////
// ABLINES / TRANSITIONS //
///////////////////////////


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


+ (int) getCurrentStanza {
    return currentStanza;
}


+ (int) getTotalWordsVisible {
    int i = 0;
    for(ABLine *line in ABLines) i += (int)[line.lineWords count];
    return i;
}


+ (int) numberOfLinesToDisplay {
    if([ABUI isIphone] || settingIPhoneDisplayMode == YES) return 5; else return 11;
}



+ (NSArray *) getCurrentScriptWordLines {
    NSMutableArray *lines = [NSMutableArray array];
    for(int i=0; i < MIN([ABState numberOfLinesToDisplay], [currentScriptWordLines count]); i ++) {
        [lines addObject:[currentScriptWordLines objectAtIndex:i]];
    }
    return [NSArray arrayWithArray:lines];
}


+ (void) updateCurrentScriptWordLinesWithLine:(NSArray *)newLine atIndex:(int)lineNumber {
    NSMutableArray *newStanza = [NSMutableArray array];
    for(int l=0; l < [currentScriptWordLines count]; l ++) {
        if(l == lineNumber) [newStanza addObject:newLine];
        else [newStanza addObject:[currentScriptWordLines objectAtIndex:l]];
    }
    currentScriptWordLines = [NSArray arrayWithArray:newStanza];
}


+ (NSArray *) getLines {
    return ABLines;
}


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
        else newLines = [ABCadabra spaceyLettersMagic:newLines andSpaceOut:NO inTransition:YES];
    }
    
    currentStanza = index;
    currentScriptWordLines = newLines;
    [ABState changeAllLinesToLines:newLines];
    
    userActionsOnThisStanza = 0;
    autoMutationsOnThisStanza = 0;
    
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


+ (void) manuallyTransitionStanzaToNumber:(int)stanzaNumber {
    if(stanzaNumber == currentStanza) return;
    if(currentStanza == 0 && stanzaNumber == [ABScript lastStanzaIndex] + 1) stanzaNumber = -1;
    double timePassed_ms = [lastDialSetTime timeIntervalSinceNow] * -1000.0;
    if(timePassed_ms < dialThrottleMs) return;
    lastDialSetTime = [NSDate date];
    [ABState transitionToStanza:stanzaNumber];
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


+ (void) absentlyMutate {
    if(settingAutonomousMutation == NO) return;
    if([currentScriptWordLines count] == 0) return;
    int max = MIN((int)[currentScriptWordLines count], [ABState numberOfLinesToDisplay]);
    int i = ABI(max);
    [[ABLines objectAtIndex:i] absentlyMutate];
    autoMutationsOnThisStanza ++;
}








///////////
// MODEL //
///////////


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

+ (void) setSpellModeTo:(SpellMode)mode {
    currentSpellMode = mode;
}

+ (SpellMode) getCurrentSpellMode {
    return currentSpellMode;
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




////////////////////
// MUTATION LEVEL //
////////////////////


+ (int) checkMutationLevel {
    return mutationLevel;
}

+ (void) boostMutationLevel {
    mutationLevel += 3 + ABI(3);
    if(mutationLevel > 15) mutationLevel = 15;
}

+ (void) clearMutations {
    mutationLevel = 0;
    [ABState manuallyTransitionStanzaWithIncrement:0];
}






//////////
// TIPS //
//////////


+ (void) initTips {
    defaults = [NSUserDefaults standardUserDefaults];
    
    tipWelcome = (int)[defaults integerForKey:@"tip-welcome"];
    tipGraft = (int)[defaults integerForKey:@"tip-graft"];
    tipSpellMode = (int)[defaults integerForKey:@"tip-mode"];
    tipCadabra = (int)[defaults integerForKey:@"tip-cadabra"];
    
    DDLogInfo(@"Tip values: %i %i %i %i", tipWelcome, tipGraft, tipSpellMode, tipCadabra);
}


+ (BOOL) shouldShowTip:(NSString *)tip {
    if(DEV_PREVENT_TIPS) return NO;
    if([tip isEqualToString:@"welcome"] && !tipWelcome) return YES;
    if([tip isEqualToString:@"graft"] && !tipGraft) return YES;
    if([tip isEqualToString:@"mode"] && !tipSpellMode) return YES;
    if([tip isEqualToString:@"cadabra"] && !tipCadabra) return YES;
    return NO;
}

+ (void) toggleTip:(NSString *)tip {
    if([tip isEqualToString:@"welcome"]) {
        [defaults setInteger:1 forKey:@"tip-welcome"];
        tipWelcome = 1;
    }
    if([tip isEqualToString:@"graft"]) {
        [defaults setInteger:1 forKey:@"tip-graft"];
        tipGraft = 1;
    }
    if([tip isEqualToString:@"mode"]) {
        [defaults setInteger:1 forKey:@"tip-mode"];
        tipSpellMode = 1;
    }
    if([tip isEqualToString:@"cadabra"]) {
        [defaults setInteger:1 forKey:@"tip-cadabra"];
        tipCadabra = 1;
    }
    [defaults synchronize];
}



+ (void) resetTips {
//    tipWelcome = 0;
//    tipGraft = 0;
//    tipSpellMode = 0;
//    tipCadabra = 0;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"tip-welcome"];
    [defaults setInteger:0 forKey:@"tip-graft"];
    [defaults setInteger:0 forKey:@"tip-mode"];
    [defaults setInteger:0 forKey:@"tip-cadabra"];
    [defaults synchronize];
}






//////////////
// SETTINGS //
//////////////


+ (void) initSettings {
    settingAutoplay = NO; //(BOOL)sAutoplay;
    settingAutonomousMutation = YES; // (BOOL)sAutoMutate;
    settingIPhoneDisplayMode = NO; // (BOOL)sFiveLines;
}


// Auto-mutation

+ (void) setAutoMutation:(BOOL)value {
    settingAutonomousMutation = value;
}

+ (BOOL) getAutoMutation {
    return settingAutonomousMutation;
}


// Autoplay

+ (void) setAutoplay:(BOOL)value {
    settingAutoplay = value;
    if(value == YES) [ABClock startAutoProgress];
    else [ABClock stopAutoProgress];
}

+ (BOOL) getAutoplay {
    return settingAutonomousMutation;
}


// iPhone mode

+ (void) setIPhoneMode:(BOOL)value {
    settingIPhoneDisplayMode = value;
    settingIPhoneDisplayModeHasChanged = YES;
}

+ (BOOL) getIPhoneMode {
    return settingIPhoneDisplayMode;
}

+ (BOOL) checkForChangedDisplayMode {
    if(settingIPhoneDisplayModeHasChanged == NO) return NO;
    for(ABLine *line in ABLines) [line destroyAllWords];
    settingIPhoneDisplayModeHasChanged = NO;
    return YES;
}


// Reset lexicon

+ (void) setResetLexicon {
    DDLogInfo(@"set setResetLexicon");
    [ABData resetLexicon];
    [[[UIAlertView alloc] initWithTitle:@"" message:@"“our birth is but a sleep and a forgetting...” ―wordsworth" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}






//////////////////////
// CADABRA SETTINGS //
//////////////////////


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







+ (void) incrementUserActions {
    userActionsOnThisStanza ++;
}


+ (void) copyAllTextToClipboard {

    NSMutableArray *text = [NSMutableArray array];
    for(ABLine *line in ABLines) [text addObject:[line lineAsPlainTextString]];
    NSString *copyString = [text componentsJoinedByString:@"\n"];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = copyString;
    
    DDLogInfo(@"COPY TO CLIPBOARD:\n\n%@", copyString);
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Copied text to clipboard." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

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


@end
