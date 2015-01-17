//
//  AbraWord.h
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POPBasicAnimation;
@class ABScriptWord;
@class ABLine;

@interface ABWord : UILabel

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL marginLeft;
@property (nonatomic) BOOL marginRight;
@property (nonatomic) int sourceStanza;
@property (nonatomic) BOOL isGrafted;
@property (nonatomic) int lineNumber;
@property (nonatomic) int linePosition;
@property (nonatomic) NSString *abWordID;

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) POPBasicAnimation *animationX;
@property (nonatomic) POPBasicAnimation *animationAlpha;
@property (nonatomic) POPBasicAnimation *animationSize;
@property (nonatomic) ABScriptWord *scriptWord;

@property (nonatomic) ABLine *parentLine;
@property (nonatomic) BOOL *locked;
@property (nonatomic) BOOL *isSelfDestructing;

- (id) initWithFrame:(CGRect)frame andScriptWord:(ABScriptWord *) word;

- (void) animateIn;
- (void) moveToXPosition:(CGFloat)x;
- (void) setXPosition:(CGFloat)x;
- (void) dim;
- (void) selfDestruct;
- (void) selfDestructMorph;

@end
