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

@implementation ABState

NSArray *prevStanzaLines;
NSMutableArray *ABLines;

BOOL isInitialized, isInAutoplayMode, isAnimating, preventGestures;

int currentStanza;
double lastGestureTime;
CGFloat mutationLevel;

typedef enum { FORWARD, BACKWARD } ScriptDirection;
ScriptDirection scriptDirection;

typedef enum { REMIX, NORMAL } TransitionType;
InteractivityMode currentInteractivityMode;

NSDate *lastDialSetTime;
int dialThrottleMs;



static ABState *ABStateInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABStateInstance == NULL) ABStateInstance = [[ABState alloc] init];
    }
}


- (id) init {
    if(self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionStanza:) name:@"transitionStanza" object:nil];
        
        lastDialSetTime = [NSDate date];
        dialThrottleMs = 200;
        
        isInAutoplayMode = NO;
        currentStanza = ABRA_START_STANZA;
        scriptDirection = FORWARD;
        lastGestureTime = CACurrentMediaTime();
        isInitialized = YES;
        preventGestures = NO;
        
        currentInteractivityMode = MUTATE;
        
        [ABClock start];
        
    }
    return self;
}




///////////////////////
// APPLICATION STATE //
///////////////////////

+ (void) setModeToStandalone {
    isInAutoplayMode = NO;
    [ABClock stopAutoProgress];
}

+ (void) setModeToAutoplayMode {
    isInAutoplayMode = YES;
    [ABClock startAutoProgress];
}

+ (void) applicationWillResignActive {
    [ABClock deactivate];
}

+ (void) applicationDidBecomeActive {
    if(!isInitialized) return;
    [ABClock reactivate];
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
    return isInAutoplayMode;
}

+ (int) getCurrentStanza {
    return currentStanza;
}

+ (void) reset {
    mutationLevel = 0;
    if(isInAutoplayMode) {
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
    if(isInAutoplayMode) {
        if(direction == 1) scriptDirection = FORWARD;
        if(direction == -1) scriptDirection = BACKWARD;
    } else {
        [ABState manuallyTransitionStanzaWithIncrement:direction];
    }
}

+ (void) forward {
    if(isInAutoplayMode) scriptDirection = FORWARD;
    else [ABState manuallyTransitionStanzaWithIncrement:1];
}

+ (void) backward {
    if(isInAutoplayMode) scriptDirection = BACKWARD;
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


//
//+ (void) increaseMutation {
//    if(!isInAutoplayMode) {
//        [ABState addToMutationLevel:1.2];
//        [ABState manuallyTransitionStanzaWithIncrement:0];
//    } else {
//        [ABState addToMutationLevel:2.2];
//    }
//}

//+ (void) addToMutationLevel:(CGFloat)num {
//    //    if(mutationLevel > 20) return;
//    mutationLevel = mutationLevel + num;
//}

+ (int) checkMutationLevel {
    return mutationLevel;
}



+ (void) updatePrevStanzaLinesWithLine:(NSArray *)newLine atIndex:(int)lineNumber {
    
    NSMutableArray *newStanza = [NSMutableArray array];
    
    for(int l=0; l < [prevStanzaLines count]; l ++) {
        if(l == lineNumber) [newStanza addObject:newLine];
        else [newStanza addObject:[prevStanzaLines objectAtIndex:l]];
    }
    
    prevStanzaLines = [NSArray arrayWithArray:newStanza];
}






////////////////
// INIT LINES //
////////////////


+ (NSMutableArray *) initLines {
    
    NSArray *stanza = [ABScript linesAtStanzaNumber:currentStanza];
    prevStanzaLines = stanza;
    
    int lineHeight = [ABUI abraLineHeight];
    CGFloat heightOffset = (kScreenHeight - (lineHeight * ABRA_NUMBER_OF_LINES)) / 2;
    if(kScreenHeight < 400) heightOffset = heightOffset / 1.5;
    
    ABLines = [NSMutableArray array];
    
    int p = 0;
    for(int s = ABRA_START_LINE; s < ABRA_START_LINE + ABRA_NUMBER_OF_LINES; s ++) {
        NSArray *words = (s < [stanza count]) ? stanza[s] : [ABScript emptyLine];
        CGFloat y = heightOffset + (p++ * lineHeight);
        [ABLines addObject:[[ABLine alloc] initWithWords:words andYPosition:y andHeight:lineHeight andLineNumber:s]];
    }
    
    return ABLines;
}







/////////////////
// TRANSITIONS //
/////////////////


+ (void) changeAllLinesToLines:(NSArray *)newLines {
    int c = 0;
    for(int s = ABRA_START_LINE; s < ABRA_START_LINE + ABRA_NUMBER_OF_LINES; s++) {
        if(c >= [ABLines count]) continue;
        NSArray *newWords = (s < [newLines count]) ? newLines[s] : [ABScript emptyLine];
        [[ABLines objectAtIndex:c++] changeWordsToWords:newWords];
    }
}


+ (void) transitionToStanza:(int)index {
    
    NSArray *newLines;
    
    int firstIndex = [ABScript firstStanzaIndex];
    int lastIndex = [ABScript lastStanzaIndex];

    DDLogInfo(@"Stanza transition: %i -> %i (%i %i)", currentStanza, index, firstIndex, lastIndex);

    
    if(index == firstIndex - 1) {
        newLines = [ABScript mixStanzaLines:prevStanzaLines withStanzaAtIndex:lastIndex];
        
    } else if(index == lastIndex + 1) {
        newLines = [ABScript mixStanzaLines:prevStanzaLines withStanzaAtIndex:firstIndex];
        
    } else {
        newLines = [ABScript linesAtStanzaNumber:index];
    }
    
    if(mutationLevel > 0) {
        newLines = [ABMutate remixStanza:newLines andOldStanza:prevStanzaLines atMutationLevel:mutationLevel];
        mutationLevel --;
    }
    
    if([newLines count] > ABRA_NUMBER_OF_LINES) {
        newLines = [newLines subarrayWithRange:NSMakeRange(0, ABRA_NUMBER_OF_LINES)];
    }

    
    currentStanza = index;
    prevStanzaLines = newLines;
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
    if([prevStanzaLines count] == 0) return;
    int max = MIN([prevStanzaLines count], ABRA_NUMBER_OF_LINES);
    int i = ABI(max);
    [[ABLines objectAtIndex:i] absentlyMutate];
}





////////////////
// GRAFT TEXT //
////////////////

+ (BOOL) graftText:(NSString *)text {
    return [ABData graftText:text];
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




@end
