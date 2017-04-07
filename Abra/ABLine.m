//
//  ABLine.m
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABConstants.h"
#import "ABState.h"
#import "ABMatch.h"
#import "ABWord.h"
#import "ABLine.h"
#import "ABScriptWord.h"
#import "ABMutate.h"
#import "ABClock.h"
#import "ABUI.h"
#import "ABCadabra.h"

@implementation ABLine {
    ABMatch *matcher;
}



///////////////////////////
// CREATE / DELETE WORDS //
///////////////////////////

- (id) initWithWords:(NSArray *)words andYPosition:(CGFloat)y andHeight:(CGFloat)lineHeight andLineNumber:(int)lineNum {
    
    if(self = [super init]) {

        self.lineNumber = lineNum;
        self.yPosition = y;
        self.lineWords = [NSMutableArray array];
        self.lossyTransitions = NO;
        
        [self setFrame:CGRectMake(0, y, kScreenWidth, lineHeight)];
        
        matcher = [[ABMatch alloc] init];
  
        // For position testing
        // self.backgroundColor = [UIColor colorWithHue:0.2 saturation:0.3 brightness:0.4 alpha:0.3];
        
        if([words count] == 0) return self;
        [self createAllNewWords:words];
    
    }
    return self;
}


- (ABWord *) newWordWithFrame:(CGRect)frame andScriptWord:(ABScriptWord *) sw {
    ABWord *word = [[ABWord alloc] initWithFrame:frame andScriptWord:sw];
    [self addSubview:word];
    return word;
}


- (void) createAllNewWords:(NSArray *)words {

    self.lineScriptWords = words;

    for(int i=0; i<[words count]; i++) {
        ABWord *word = [self newWordWithFrame:CGRectMake(0, 0, 100, 100) andScriptWord:words[i]];
        word.parentLine = self;
        [self.lineWords addObject:word];
    }
    
    [self moveWordsToNewPositions];

    for(int i=0; i<[self.lineWords count]; i++) {
        [self.lineWords[i] animateIn];
    }
}


- (void) destroyAllWords {
    
    for(int i=0, l=(int)[self.lineWords count]; i<l; i++) {
        [self.lineWords[i] selfDestruct];
    }
    
    [self.lineWords removeAllObjects];
    self.lineScriptWords = @[];
    self.lineWidth = 0;
}




//////////////////
// CHANGE WORDS //
//////////////////


- (NSArray *) getTextArrayFromScriptWords:(NSArray *)scriptWords {
    NSMutableArray *texts = [NSMutableArray array];
    for(int i=0; i<[scriptWords count]; i++){
        ABScriptWord *o = scriptWords[i];
        [texts addObject:o.text];
    }
    return [NSArray arrayWithArray:texts];
}


- (void) replaceWordAtIndex:(int)index withArray:(NSArray *)futureWords {

    ABScriptWord *psw = [self.lineScriptWords objectAtIndex:index];
    ABWord *pw = self.lineWords[index];
    
    if(psw == nil) {
        DDLogError(@"ERROR: replaceWordAtIndex did not find a word at index: %i", index);
        return;
    }

    NSMutableArray *newWords = [NSMutableArray array];
    NSMutableArray *newScriptWords = [NSMutableArray array];
    NSArray *pastWordsText = [self getTextArrayFromScriptWords:@[psw]];
    NSArray *futureWordsText = [self getTextArrayFromScriptWords:futureWords];
    NSArray *map = [matcher matchWithPast:pastWordsText andFuture:futureWordsText];
    
    
    BOOL foundMatchForWord = NO;
    
    for(int i=0, l=(int)[map count]; i<l; i++) {
        
        ABWord *word;
        
        // Create new word object
        if([[map objectAtIndex:i] isEqual: @(-1)]) {
            word = [self newWordWithFrame:CGRectMake(0, 0, 100, 50) andScriptWord:futureWords[i]];
            word.parentLine = self;
            
            if(pw.isRedacted && ABI(4) > 0) [word redact];
            if(pw.isSpinning && ABI(10) > 0) [word spin];
            
            [newScriptWords addObject:futureWords[i]];
            
        // Use existing word object
        } else {
            word = [self.lineWords objectAtIndex:index];
            [newScriptWords addObject:psw];
            foundMatchForWord = YES;
            [word dim];
        }
        
        [newWords addObject:word];
    }
    
    
    NSMutableArray *newLineWords = [NSMutableArray array];
    NSMutableArray *newLineScriptWords = [NSMutableArray array];

    for(int i=0, l=(int)[self.lineWords count]; i<l; i++) {
        if(i == index) {
            [newLineWords addObjectsFromArray:newWords];
            [newLineScriptWords addObjectsFromArray:newScriptWords];
        } else {
            [newLineWords addObject:[self.lineWords objectAtIndex:i]];
            [newLineScriptWords addObject:[self.lineScriptWords objectAtIndex:i]];
        }
    }
    
    
    if(foundMatchForWord == NO) {
        [self.lineWords[index] selfDestructMorph];
    }

    self.lineScriptWords = newLineScriptWords;
    self.lineWords = newLineWords;
    
    [self moveWordsToNewPositions];
}



- (void) changeWordsToWords:(NSArray *)futureWords {
    
    NSArray *pastWords = self.lineScriptWords;

    if([pastWords count] == 0 && [futureWords count] == 0) return;
    if([pastWords count] == 0) {
        [self createAllNewWords:futureWords];
        return;
    }
    if([futureWords count] == 0) {
        [self destroyAllWords];
        return;
    }
    
    NSMutableArray *newWords = [NSMutableArray array];
    NSMutableArray *foundIndices = [NSMutableArray array];
    
    NSArray *pastWordsText = [self getTextArrayFromScriptWords:pastWords];
    NSArray *futureWordsText = [self getTextArrayFromScriptWords:futureWords];

    NSArray *map = [matcher matchWithPast:pastWordsText andFuture:futureWordsText];
    
    for(int i=0, l=(int)[map count]; i<l; i++) {

        ABWord *word;

        // Create new word object
        if([[map objectAtIndex:i] isEqual: @(-1)]) {
            word = [self newWordWithFrame:CGRectMake(0, 0, 100, 50) andScriptWord:futureWords[i]];
            word.parentLine = self;
            if(self.lossyTransitions && ABI(9) < 3) [word eraseInstantly];
            else if([ABState checkMutationLevel] > 0 && ABI(18 - [ABState checkMutationLevel]) < 4) [word eraseInstantly];
            
        // Use existing word object
        } else {
            int oldIndex = [map[i] intValue];
            if(![self.lineWords objectAtIndex:oldIndex]) return;
            word = [self.lineWords objectAtIndex:oldIndex];
            [foundIndices addObject:@(oldIndex)];
            [word dim];
        }
        [newWords addObject:word];
    }
    
    for(int i=0, l=(int)[pastWords count]; i<l; i++) {
        if (![foundIndices containsObject:@(i)]) {
            [self.lineWords[i] selfDestruct];
        }
    }
    
    self.lineScriptWords = futureWords;
    self.lineWords = newWords;

    [self moveWordsToNewPositions];
}



- (void) absentlyMutate {
    
    if([self.lineScriptWords count] == 0) return;
    NSArray *indices = [self indicesOfVisibleWords];
    int index = 0;
    
    // Occasionally choose any old word
    if(ABI(8) == 0 || [indices count] == 0) {
        index = ABI((int)[self.lineScriptWords count]);
        
        // But usually, only select from among visible ones
    } else {
        NSUInteger randomIndex = arc4random() % [indices count];
        index = [[indices objectAtIndex:randomIndex] intValue];
    }
    
    if(ABI(15) < 2 && [indices count] > 1) {
        [[self.lineWords objectAtIndex:index] erase];
        return;
    }
    
    ABScriptWord *sw = [self.lineScriptWords objectAtIndex:index];
    
    NSArray *newSWs = [ABMutate mutateWord:sw inLine:self.lineScriptWords];
    NSMutableArray *newTexts = [NSMutableArray array];
    for(ABScriptWord *nsw in newSWs) {
        if(ABI(17) < 2) continue;
        // don't allow morphCount to increment much when absently mutating
        if(nsw.morphCount > 2) nsw.morphCount = ABI(2);
        [newTexts addObject:nsw.text];
    }
    
    DDLogInfo(@"Absently mutate (line %i): %@ -> %@", self.lineNumber, sw.text, [newTexts componentsJoinedByString:@" "]);
    
    [self replaceWordAtIndex:index withArray:newSWs];
    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];
}









///////////////////
// WORD MOVEMENT //
///////////////////


- (void) moveWordsToNewPositions {
    
    NSArray *xPositions = [self wordsXPositions];
    
    for(int i=0; i<[self.lineWords count]; i++) {
        ABWord *word = self.lineWords[i];

        if([word isNew]) {
            [word setXPosition:[xPositions[i] floatValue]];
            [word setIsNew:NO];
            [word animateIn];
        }
        
        [word moveToXPosition:[xPositions[i] floatValue]];
    }
}


- (NSArray *) wordsXPositions {
    
    // Hack to fix weird slight off center phenomenon
    CGFloat total = [ABUI scaleXWithIphone:2 ipad:4];
    
    CGFloat fontMargin = [ABUI abraFontMargin];
    
    NSMutableArray *xPositions = [[NSMutableArray alloc] initWithCapacity:[self.lineWords count]];
    NSMutableArray *xWidths = [NSMutableArray array];
    
    BOOL prevMarginRight = NO;
    
    for(int i=0; i<[self.lineWords count]; i++){
        
        ABWord *w = [self.lineWords objectAtIndex:i];
        
        CGFloat wordWidth = [w width];
        CGFloat wordWidthWithMargins = wordWidth;
        
        if(!w.marginLeft && prevMarginRight) {
            if(prevMarginRight) total -= fontMargin;
            wordWidthWithMargins -= fontMargin;
        }
        
        [xPositions addObject:[NSNumber numberWithFloat:total]];
        
        if(w.marginRight) {
            total += fontMargin;
            wordWidthWithMargins += fontMargin;
            prevMarginRight = YES;
        } else {
            prevMarginRight = NO;
        }
        
        total += wordWidth;
        [xWidths addObject:[NSNumber numberWithFloat:wordWidthWithMargins]];
        
    }
    
    self.lineWidth = total;
    self.wordWidthsWithMargins = xWidths;
    
    CGFloat windowOffset = kScreenWidth / 2;
    CGFloat lineOffset = windowOffset - (self.lineWidth / 2);

    for(int i=0; i<[xPositions count]; i++){
        CGFloat x = [xPositions[i] floatValue];
        xPositions[i] = [NSNumber numberWithFloat:(x + lineOffset)];
    }

    NSArray *result = [xPositions copy];
    return result;
}






/////////////
// ACTIONS //
/////////////


- (int) checkPoint:(CGPoint)point {
    
    int target = -1;

    for(int i=0; i<[self.lineWords count]; i++) {
        ABLine *w = [self.lineWords objectAtIndex:i];
        if(CGRectContainsPoint(w.frame, point)) {
            target = i;
        }
    }
    
    if(target > -1) {
        ABWord *targetWord = [self.lineWords objectAtIndex:target];
        if(targetWord.isLocked) target = -1;
    }
    
    return target;
}



- (void) touch:(CGPoint)point {
    [self touchOrTap:point];
}
- (void) tap:(CGPoint)point {
    [self touchOrTap:point];
}
- (void) touchOrTap:(CGPoint)point {
    int index = [self checkPoint:point];
    if(index == -1) return;
    SpellMode mode = [ABState getCurrentSpellMode];
    [self lineAction:mode index:index byLiveUser:YES];
}


- (void) lineAction:(SpellMode)mode index:(int)index byLiveUser:(BOOL)liveUser {
    
    if(index > [self.lineWords count]) return;
    if(index > [self.lineScriptWords count]) return;
    
    ABWord *w = self.lineWords[index];
    ABScriptWord *sw = self.lineScriptWords[index];
    
    if(mode == MUTATE) {
        if(w.isErased) return;
        if(w.isRedacted) return;
        [self replaceWordAtIndex:index withArray:[ABMutate mutateWord:sw inLine:self.lineScriptWords]];
    }
    
    if(mode == GRAFT) {
        NSArray *graftArray = [ABMutate graftWord:sw];
        [self replaceWordAtIndex:index withArray:graftArray];
    }

    if(mode == PRUNE) {
        [self replaceWordAtIndex:index withArray:@[]];
    }
    
    if(mode == ERASE) {
        if(w.isErased) return;
        [self.lineWords[index] erase];
    }
    
    
    if(liveUser) {
        [ABState incrementUserActions];
    }

    if(mode == ERASE) return; // No update for erasures
    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];

}


- (void) doubleTap:(CGPoint)point {

    int index = [self checkPoint:point];
    if(index == -1) return;
    ABScriptWord *sw = self.lineScriptWords[index];
    
    [self replaceWordAtIndex:index withArray:[ABMutate multiplyWord:sw]];
    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];
}


// cadabra check
- (void) longPress:(CGPoint)point {
    
    int index = [self checkPoint:point];
    if(index == -1) return;
    ABScriptWord *sw = self.lineScriptWords[index];
    ABWord *w = self.lineWords[index];
    if(w.isErased) return;
    
    if(sw.cadabra == nil) {
        [ABCadabra revealCadabraWords];
    } else {
        [ABCadabra castSpell:sw.cadabra magicWord:sw.text];
    }
    
}




///////////////////
// LINE MOVEMENT //
///////////////////


- (void) animateToYPosition:(CGFloat)y duration:(CGFloat)duration delay:(CGFloat)delay {
    CGFloat speed = [ABClock speed];
    CGRect newFrame = self.frame;
    newFrame.origin.y = y;
    [UIView animateWithDuration:speed * duration delay:speed * delay options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^() {
        self.frame = newFrame;
    } completion:^(BOOL finished) {}];
}


- (void) mirrorWithDelay:(CGFloat)delay {
    CGFloat speed = [ABClock speed];
    CGFloat scale = self.isMirrored ? 1.0 : -1.0;
    self.isMirrored = !self.isMirrored;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, speed * delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self duration:(speed * (1.5f + ABF(0.12f) + delay)) options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(scale, scale);
        } completion:nil];
    });
}






///////////////////
// EXTERNAL INFO //
///////////////////


- (NSString *) convertToString {
    
    NSMutableArray *plainText = [NSMutableArray array];
    BOOL prevMarginRight = NO;
    
    for(int i=0; i<[self.lineWords count]; i++){
        
        ABWord *w = [self.lineWords objectAtIndex:i];
        ABScriptWord *sw = [self.lineScriptWords objectAtIndex:i];
        
        if(!w.marginLeft && prevMarginRight) {
            if([plainText count] > 0 && [[plainText lastObject] isEqualToString:@" "]) {
                [plainText removeObjectAtIndex:[plainText count] - 1];
            }
        }
        
        if(w.isErased) {
            for(int j=0; j < [sw.charArray count]; j ++) [plainText addObject:@" "];
        } else if(w.isRedacted) {
            for(int j=0; j < [sw.charArray count]; j ++) [plainText addObject:@"█"];
        } else {
            [plainText addObject:w.text];
        }
        
        if(w.marginRight) {
            [plainText addObject:@" "];
        } else {
            prevMarginRight = NO;
        }
    }
    
    return [plainText componentsJoinedByString:@""];
}



- (NSArray *) indicesOfVisibleWords {
    NSMutableArray *locs = [NSMutableArray array];
    for(int i=0; i<[self.lineWords count]; i ++) {
        ABWord *w = [self.lineWords objectAtIndex:i];
        if(w.isErased) continue;
        if(w.isRedacted) continue;
        [locs addObject:@(i)];
    }
    return locs;
}


- (BOOL) includesGraftedContent {
    if([self.lineScriptWords count] == 0) return NO;
    for(ABScriptWord *sw in self.lineScriptWords) {
        if(sw.isGrafted) return YES;
    }
    return NO;
}


// TODO
//- (CGFloat) excessHorizontalWidth {
//    if(self.lineWidth < kScreenWidth) return 0;
//}
//- (BOOL) cutDownLineToScreenWidth {
//    return NO;
//}




@end
