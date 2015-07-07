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
@property (nonatomic) NSArray *lineScriptWords;
@property (nonatomic) NSMutableArray *lineWords;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGFloat yPosition;
@property (nonatomic) NSArray *wordWidthsWithMargins;
@property (nonatomic) BOOL lossyTransitions;
@property (nonatomic) BOOL isMirrored;

- (id) initWithWords:(NSArray *)words andYPosition:(CGFloat)y andHeight:(CGFloat)lineHeight andLineNumber:(int)lineNum;

- (void) changeWordsToWords:(NSArray *) words;
- (void) replaceWordAtIndex:(int)index withArray:(NSArray *)newWords;
- (void) destroyAllWords;
- (void) absentlyMutate;

- (void) touch:(CGPoint)point;
- (void) tap:(CGPoint)point;
- (void) longPress:(CGPoint)point;
- (void) doubleTap:(CGPoint)point;
- (int) checkPoint:(CGPoint)point;

- (void) animateToYPosition:(CGFloat)y duration:(CGFloat)duration delay:(CGFloat)delay;

- (NSString *) lineAsPlainTextString;


@end