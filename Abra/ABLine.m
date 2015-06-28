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
#import "ABUI.h"


@implementation ABLine {
    ABMatch *abMatcher;
}



///////////////////////////
// CREATE / DELETE WORDS //
///////////////////////////


- (id) initWithWords:(NSArray *)words andYPosition:(CGFloat)y andHeight:(CGFloat)lineHeight andLineNumber:(int)lineNum {
    
    if(self = [super init]) {

        self.lineNumber = lineNum;
        self.yPosition = y;
        self.lineWords = [NSMutableArray array];
        [self setFrame:CGRectMake(0, y, kScreenWidth, lineHeight)];
        abMatcher = [[ABMatch alloc] init];
  
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

    ABScriptWord *pw = [self.lineScriptWords objectAtIndex:index];
    
    if(pw == nil) {
        DDLogError(@"ERROR: replaceWordAtIndex did not find a word at index: %i", index);
        return;
    }

    NSMutableArray *newWords = [NSMutableArray array];
    NSMutableArray *newScriptWords = [NSMutableArray array];
    NSArray *pastWordsText = [self getTextArrayFromScriptWords:@[pw]];
    NSArray *futureWordsText = [self getTextArrayFromScriptWords:futureWords];
    NSArray *map = [abMatcher matchWithPast:pastWordsText andFuture:futureWordsText];
    
    
    BOOL foundMatchForWord = NO;
    
    for(int i=0, l=(int)[map count]; i<l; i++) {
        
        ABWord *word;
        
        // Create new word object
        if([[map objectAtIndex:i] isEqual: @(-1)]) {
            word = [self newWordWithFrame:CGRectMake(0, 0, 100, 50) andScriptWord:futureWords[i]];
            word.parentLine = self;
            [newScriptWords addObject:futureWords[i]];
            
        // Use existing word object
        } else {
            word = [self.lineWords objectAtIndex:index];
            [newScriptWords addObject:pw];
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

    NSArray *map = [abMatcher matchWithPast:pastWordsText andFuture:futureWordsText];
    
    for(int i=0, l=(int)[map count]; i<l; i++) {

        ABWord *word;

        // Create new word object
        if([[map objectAtIndex:i] isEqual: @(-1)]) {
            word = [self newWordWithFrame:CGRectMake(0, 0, 100, 50) andScriptWord:futureWords[i]];
            word.parentLine = self;

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






////////////////
// MOVE WORDS //
////////////////


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


- (NSArray *) currentWordsTextArray {
    NSMutableArray *words = [NSMutableArray array];
    for(int i=0; i<[self.lineWords count]; i++) {
        [words addObject:[self.lineWords[i] text]];
    }
    return [words copy];
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







/////////////////////////////////////////
// INTERACTIVITY AND MUTATION TRIGGERS //
/////////////////////////////////////////


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
        if(targetWord.locked) target = -1;
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
    
    InteractivityMode mode = [ABState getCurrentInteractivityMode];
    ABWord *w = self.lineWords[index];
    ABScriptWord *sw = self.lineScriptWords[index];
    
    if(mode == ERASE) {
        if(w.isErased) return;
        [self.lineWords[index] erase];
        return;
    }

    if(mode == PRUNE) {
        [self replaceWordAtIndex:index withArray:@[]];
    }

    if(mode == MUTATE) {
        if(w.isErased) return;
        [self replaceWordAtIndex:index withArray:[ABMutate mutateWord:sw inLine:self.lineScriptWords]];
    }
    
    if(mode == GRAFT) {
        [self replaceWordAtIndex:index withArray:[ABMutate graftWord:sw]];
    }

    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];
}






- (void) doubleTap:(CGPoint)point {

    int index = [self checkPoint:point];
    if(index == -1) return;
    ABScriptWord *sw = self.lineScriptWords[index];
    
    [self replaceWordAtIndex:index withArray:[ABMutate multiplyWord:sw]];
    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];
}



- (void) longPress:(CGPoint)point {
    
    int index = [self checkPoint:point];
    if(index == -1) return;
    ABScriptWord *sw = self.lineScriptWords[index];
    
    [self replaceWordAtIndex:index withArray:[ABMutate explodeWord:sw]];
    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];
}




- (void) absentlyMutate {
    
    if([self.lineScriptWords count] == 0) return;
    int index = ABI((int)[self.lineScriptWords count]);
    ABScriptWord *sw = [self.lineScriptWords objectAtIndex:index];
    
    NSArray *newSWs = [ABMutate mutateWord:sw inLine:self.lineScriptWords];
    NSMutableArray *newTexts = [NSMutableArray array];
    for(ABScriptWord *nsw in newSWs) {
        // don't allow morphCount to increment much when absently mutating
        if(nsw.morphCount > 2) nsw.morphCount = ABI(2);
        [newTexts addObject:nsw.text];
    }

    DDLogInfo(@"Absently mutate (line %i): %@ -> %@", self.lineNumber, sw.text, [newTexts componentsJoinedByString:@" "]);

    [self replaceWordAtIndex:index withArray:newSWs];
    [ABState updateCurrentScriptWordLinesWithLine:self.lineScriptWords atIndex:self.lineNumber];
}





- (void) animateToYPosition:(CGFloat)y duration:(CGFloat)duration delay:(CGFloat)delay {
    CGRect newFrame = self.frame;
    newFrame.origin.y = y;
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^() {
        self.frame = newFrame;
    } completion:^(BOOL finished) {}];
}



- (BOOL) includesGraftedContent {
    if([self.lineScriptWords count] == 0) return NO;
    for(ABScriptWord *sw in self.lineScriptWords) {
        if(sw.isGrafted) return YES;
    }
    return NO;
}

//
//- (CGFloat) excessHorizontalWidth {
//    if(self.lineWidth < kScreenWidth) return 0;
//    
//    
//}
//

- (BOOL) cutDownLineToScreenWidth {
    return NO;
}





@end
