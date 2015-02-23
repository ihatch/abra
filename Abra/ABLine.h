//
//  ABLine.h
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABLine : UIView

- (id) initWithWords:(NSArray *)words andYPosition:(CGFloat)y andHeight:(CGFloat)lineHeight andLineNumber:(int)lineNum;
- (void) changeWordsToWords:(NSArray *) words;
- (void) touch:(CGPoint)point;
- (void) tap:(CGPoint)point;
- (void) longPress:(CGPoint)point;
- (void) doubleTap:(CGPoint)point;
- (int) checkPoint:(CGPoint)point;

@property (nonatomic) int lineNumber;

@end