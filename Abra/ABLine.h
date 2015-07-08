//
//  ABLine.h
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABLine : UIView

@property (nonatomic) int lineNumber;
@property (nonatomic) CGFloat yPosition;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) NSMutableArray *lineWords;
@property (nonatomic) NSArray *lineScriptWords;
@property (nonatomic) NSArray *wordWidthsWithMargins;
@property (nonatomic) BOOL lossyTransitions;
@property (nonatomic) BOOL isMirrored;

- (id) initWithWords:(NSArray *)words andYPosition:(CGFloat)y andHeight:(CGFloat)lineHeight andLineNumber:(int)lineNum;

- (void) destroyAllWords;
- (void) replaceWordAtIndex:(int)index withArray:(NSArray *)newWords;
- (void) changeWordsToWords:(NSArray *) words;
- (void) absentlyMutate;

- (int) checkPoint:(CGPoint)point;
- (void) touch:(CGPoint)point;
- (void) tap:(CGPoint)point;
- (void) doubleTap:(CGPoint)point;
- (void) longPress:(CGPoint)point;

- (void) animateToYPosition:(CGFloat)y duration:(CGFloat)duration delay:(CGFloat)delay;
- (void) mirrorWithDelay:(CGFloat)delay;

- (NSString *) convertToString;
- (NSArray *) indicesOfVisibleWords;
- (BOOL) includesGraftedContent;

@end