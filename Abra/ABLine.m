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
#import "ABScript.h"
#import "ABScriptWord.h"
#import "ABUI.h"
#import "TestFlight.h"


@implementation ABLine {
    NSArray *lineScriptWords;
    NSMutableArray *lineWords;
    CGFloat lineWidth;
    CGFloat yPosition;
    NSMutableArray *grafts;
    BOOL isMorphing;
}


@synthesize lineNumber;

- (id) initWithWords:(NSArray *)words andYPosition:(CGFloat)y andHeight:(CGFloat)lineHeight andLineNumber:(int)lineNum {
    
    if(self = [super init]) {

        self.lineNumber = lineNum;
        yPosition = y;
        lineWords = [[NSMutableArray alloc] init];
        [self setFrame:CGRectMake(0,y,1024,lineHeight)];
        isMorphing = NO;
  
        // For position testing
        // self.backgroundColor = [UIColor colorWithHue:0.2 saturation:0.3 brightness:0.4 alpha:0.3];
        
        if([words count] == 0) return self;
        [self createAllNewWords:words];
    
    }
    return self;
}


- (void) createAllNewWords:(NSArray *)words {

    lineScriptWords = words;

    for(int i=0; i<[words count]; i++) {
        ABWord *word = [self newWordWithFrame:CGRectMake(100, 0, 100, 100) andScriptWord:words[i]];
        word.lineNumber = self.lineNumber;
        word.parentLine = self;
        word.linePosition = i;
        [lineWords addObject:word];
    }
    
    [self moveWordsToNewPositions];

    for(int i=0; i<[lineWords count]; i++) {
        [lineWords[i] animateIn];
    }
}


- (void) destroyAllWords {

    for(int i=0, l=(int)[lineWords count]; i<l; i++) {
        [lineWords[i] selfDestruct];
    }
    
    [lineWords removeAllObjects];
    lineScriptWords = @[];
    lineWidth = 0;
}


- (NSArray *) getTextArrayFromScriptWords:(NSArray *)scriptWords {
    NSMutableArray *texts = [[NSMutableArray alloc] init];
    for(int i=0; i<[scriptWords count]; i++){
        ABScriptWord *o = scriptWords[i];
        [texts addObject:o.text];
    }
    return [NSArray arrayWithArray:texts];
}


- (void) changeWordsToWords:(NSArray *)futureWords {
    
    NSArray *pastWords = lineScriptWords;

    if([pastWords count] == 0 && [futureWords count] == 0) return;
    if([pastWords count] == 0) {
        [self createAllNewWords:futureWords];
        return;
    }
    if([futureWords count] == 0) {
        [self destroyAllWords];
        return;
    }
    
    NSMutableArray *newWords = [[NSMutableArray alloc] init];
    NSMutableArray *foundIndices = [[NSMutableArray alloc] init];
    
    NSArray *pastWordsText = [self getTextArrayFromScriptWords:pastWords];
    NSArray *futureWordsText = [self getTextArrayFromScriptWords:futureWords];

    NSArray *map = [[[ABMatch alloc] init] matchWithPast:pastWordsText andFuture:futureWordsText];
    
    for(int i=0, l=(int)[map count]; i<l; i++) {

        ABWord *word;

        // Create new word object
        if([[map objectAtIndex:i] isEqual: @(-1)]) {
            word = [self newWordWithFrame:CGRectMake(100, 0, 100, 50) andScriptWord:futureWords[i]];
            word.lineNumber = self.lineNumber;
            word.parentLine = self;
            word.linePosition = i;

        // Use existing word object
        } else {
            int oldIndex = [map[i] intValue];
            if(![lineWords objectAtIndex:oldIndex]) return;
            word = [lineWords objectAtIndex:oldIndex];
            [foundIndices addObject:@(oldIndex)];
            word.linePosition = i;
            [word dim];
        }
        [newWords addObject:word];
    }
    
    for(int i=0, l=(int)[pastWords count]; i<l; i++) {
        if (![foundIndices containsObject:@(i)]) {
            if(isMorphing) {
                [lineWords[i] selfDestructMorph];
            } else {
                [lineWords[i] selfDestruct];
            }
        }
    }
    
    lineScriptWords = futureWords;
    lineWords = newWords;

    [self moveWordsToNewPositions];
}


- (void) moveWordsToNewPositions {
    
    NSArray *xPositions = [self wordsXPositions];
    
    for(int i=0; i<[lineWords count]; i++) {
        ABWord *word = lineWords[i];

        if([word isNew]) {
            [word setXPosition:[xPositions[i] floatValue]];
            [word setIsNew:NO];
            [word animateIn];
        }
        
        word.linePosition = i;
        [word moveToXPosition:[xPositions[i] floatValue]];
    }
}


- (NSArray *) currentWordsTextArray {
    NSMutableArray *words = [[NSMutableArray alloc] init];
    for(int i=0; i<[lineWords count]; i++) {
        [words addObject:[lineWords[i] text]];
    }
    return [words copy];
}


- (NSArray *) wordsXPositions {

    CGFloat total = 0;
    NSMutableArray *xPositions = [[NSMutableArray alloc] initWithCapacity:[lineWords count]];

    BOOL prevMarginRight = NO;
    
    for(int i=0; i<[lineWords count]; i++){
        
        ABWord *w = [lineWords objectAtIndex:i];
        CGFloat wordWidth = [w width];
        if(!w.marginLeft && prevMarginRight) {
            if(prevMarginRight) total -= [ABUI abraFontMargin];
        }
        
        [xPositions addObject:[NSNumber numberWithFloat:total]];

        if(w.marginRight) {
            total += [ABUI abraFontMargin];
            prevMarginRight = YES;
        } else {
            prevMarginRight = NO;
        }
        
        total += wordWidth;
    }
    
    lineWidth = total;
    
    CGFloat windowOffset = [ABUI screenWidth] / 2;
    CGFloat lineOffset = windowOffset - (lineWidth / 2);

    for(int i=0; i<[xPositions count]; i++){
        CGFloat x = [xPositions[i] floatValue];
        xPositions[i] = [NSNumber numberWithFloat:(x + lineOffset)];
    }

    NSArray *result = [xPositions copy];
    return result;
}


- (ABWord *) newWordWithFrame: (CGRect)frame andScriptWord:(ABScriptWord *) scriptWord {
    ABWord *word = [[ABWord alloc] initWithFrame:frame andScriptWord:scriptWord];
    [self addSubview:word];
//    [word setupGestures];
    return word;
}





- (void) mutateChildAtLinePosition:(int)linePosition {
    NSLog(@"%@ %i", @"Mutate at position ", linePosition);
    NSArray *newLine = [ABScript mutateOneWordInLine:lineScriptWords atWordIndex:linePosition];
    [self changeWordsToWords:newLine];
    [ABState updatePrevStanzaLinesWithLine:newLine atIndex:self.lineNumber];
}


- (int) checkPoint:(CGPoint)point {
    
    int target = -1;
    
    for(int i=0; i<[lineWords count]; i++) {
        ABLine *w = [lineWords objectAtIndex:i];
        if(CGRectContainsPoint(w.frame, point)) {
            target = i;
        }
    }
    
    if(target > -1) {
        ABWord *targetWord = [lineWords objectAtIndex:target];
        if(targetWord.locked) target = -1;
    }
    
    return target;
}


- (NSArray *) shuffleArray:(NSArray *)array {
    
    NSMutableArray *am = [NSMutableArray arrayWithArray:array];
    int count = (int)[am count];
    for (int i = 0; i < count; ++i) {
        int remainingCount = count - i;
        int exchangeIndex = (i + arc4random_uniform(remainingCount));
        [am exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    return [NSArray arrayWithArray:am];
}



- (void) touch:(CGPoint)point {
    [self touchOrTap:point];

}



- (void) tap:(CGPoint)point {
    [self touchOrTap:point];
}




- (void) touchOrTap:(CGPoint)point {
    
    int target = [self checkPoint:point];
    if(target == -1) return;
    
    InteractivityMode mode = [ABState getCurrentInteractivityMode];
    ABWord *w = lineWords[target];
    
    if(mode == MUTATE) {
        if(w.isErased) return;
        NSArray *newLine = [ABScript mutateOneWordInLine:lineScriptWords atWordIndex:target];
        isMorphing = YES;
        [self changeWordsToWords:newLine];
        isMorphing = NO;
        [ABState updatePrevStanzaLinesWithLine:newLine atIndex:self.lineNumber];
    }
    
    if(mode == PRUNE) {
        NSArray *newLine = [ABScript pruneOneWordInLine:lineScriptWords atWordIndex:target];
        isMorphing = YES;
        [self changeWordsToWords:newLine];
        isMorphing = NO;
        [ABState updatePrevStanzaLinesWithLine:newLine atIndex:self.lineNumber];
    }

    if(mode == MULTIPLY) {
        if(w.isErased) return;
        NSArray *newLine = [ABScript multiplyOneWordInLine:lineScriptWords atWordIndex:target];
        isMorphing = YES;
        [self changeWordsToWords:newLine];
        isMorphing = NO;
        [ABState updatePrevStanzaLinesWithLine:newLine atIndex:self.lineNumber];
    }
 
    if(mode == ERASE) {
        if(w.isErased) return;
        [lineWords[target] erase];
    }
    

    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@: line %i", @"touch", self.lineNumber]];
}






- (void) doubleTap:(CGPoint)point {

    int target = [self checkPoint:point];
    if(target == -1) return;
    
    NSArray *newLine = [ABScript explodeOneWordInLine:lineScriptWords atWordIndex:target];
    
    isMorphing = YES;
    [self changeWordsToWords:newLine];
    isMorphing = NO;
    [ABState updatePrevStanzaLinesWithLine:newLine atIndex:self.lineNumber];

    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@: line %i", @"doubleTap", self.lineNumber]];
}



- (void) longPress:(CGPoint)point {
    
    int target = [self checkPoint:point];
    if(target == -1) return;
    
    NSArray *newLine = [ABScript explodeOneWordInLine:lineScriptWords atWordIndex:target];

    isMorphing = YES;
    [self changeWordsToWords:newLine];
    isMorphing = NO;
    [ABState updatePrevStanzaLinesWithLine:newLine atIndex:self.lineNumber];

    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@: line %i", @"longPress", self.lineNumber]];
}



@end
