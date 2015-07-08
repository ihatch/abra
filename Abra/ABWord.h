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

@property (nonatomic) BOOL marginLeft;
@property (nonatomic) BOOL marginRight;
@property (nonatomic) BOOL hasAnimatedIn;
@property (nonatomic) BOOL isErased;
@property (nonatomic) BOOL isGrafted;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL isMirrored;
@property (nonatomic) BOOL isRedacted;
@property (nonatomic) BOOL isSpinning;
@property (nonatomic) BOOL isSelfDestructing;

@property (nonatomic) int sourceStanza;
@property (nonatomic) ABLine *parentLine;
@property (nonatomic) ABScriptWord *scriptWord;
@property (nonatomic) NSString *wordID;

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) POPBasicAnimation *animationX;
@property (nonatomic) POPBasicAnimation *animationAlpha;
@property (nonatomic) POPBasicAnimation *animationSize;

- (id) initWithFrame:(CGRect)frame andScriptWord:(ABScriptWord *) word;

- (void) animateIn;
- (void) setXPosition:(CGFloat)x;
- (void) moveToXPosition:(CGFloat)x;

- (void) dim;
- (void) quickDim;

- (void) erase;
- (void) eraseInstantly;
- (void) eraseWithDelay:(CGFloat)delay;
- (void) uneraseWithDelay:(CGFloat)delay;

- (void) selfDestruct;
- (void) selfDestructMorph;

- (void) fadeColorToSourceStanza:(int)stanza;
- (void) redact;
- (void) spin;


@end
