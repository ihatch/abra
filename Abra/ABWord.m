//
//  AbraWord.m
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABConstants.h"
#import "ABState.h"
#import "ABScriptWord.h"
#import "ABWord.h"
#import "ABClock.h"
#import "ABLine.h"
#import "ABUI.h"
#import <pop/POP.h>
#import <QuartzCore/QuartzCore.h>

@implementation ABWord

@synthesize width, height, isNew, startPoint, marginLeft, marginRight, sourceStanza, isGrafted, animationX, animationAlpha, animationSize, wordID, locked, isSelfDestructing;


- (id) initWithFrame:(CGRect)frame andScriptWord:(ABScriptWord *) word {
    
    if(self = [super initWithFrame:frame]) {

        self.text = word.text;
        
        self.isGrafted = word.isGrafted;
        self.marginLeft = word.marginLeft;
        self.marginRight = word.marginRight;
        self.sourceStanza = word.sourceStanza;
        
        self.isNew = YES;
        self.locked = YES;
        self.isSelfDestructing = NO;
        self.isErased = NO;
        self.isRedacted = NO;
        self.hasAnimatedIn = NO;
        self.isSpinning = NO;
        
        self.font = [UIFont fontWithName:ABRA_FONT size:[ABUI abraFontSize]];
        [self resizeFrameToFitString];

        self.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
        self.alpha = 0;
        
        self.userInteractionEnabled = NO;
        self.wordID = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}


- (void) resizeFrameToFitString {
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    CGRect frame = self.frame;
    frame.size = size;
    frame.size.height = frame.size.height + 10;
    self.frame = frame;
    self.width = size.width;
    self.height = size.height;
    
}


- (CGFloat) speed {
    return [ABClock currentSpeed];
}


- (CGFloat) convertLeftToCenter:(CGFloat)x {
    CGFloat r = x + (self.width / 2);
    return r;
}



- (void) animateIn {

    CGFloat speed = [self speed];
    CGFloat randomSize = 0.95f + ABF(0.1);
    CGFloat delay = speed * (0.2 + ABF(0.3));
    CGFloat duration = speed * (2.25 + ABF(2.5));

    if(sourceStanza == -1) {
        self.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.6 alpha:1];
    } else if(self.isGrafted) {
        self.textColor = [ABUI progressHueColorForStanza:self.sourceStanza + ABI(5) - ABI(3)];
    } else {
        self.textColor = [ABUI progressHueColorForStanza:self.sourceStanza];
    }
    
    CGFloat unlockTime = (duration + delay) * .25;
    [self performSelector:@selector(unlock) withObject:nil afterDelay:unlockTime];
    
    [UIView animateWithDuration:duration delay:delay options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = (self.isErased) ? 0.0 : 1.0;
        self.transform = CGAffineTransformMakeScale(randomSize, randomSize);
        self.hasAnimatedIn = YES;
    } completion:^(BOOL finished) {}];
    
}


- (void) unlock {
    self.locked = NO;
}



- (void) dim {
    if(self.isErased) return;
    CGFloat speed = [self speed];
    [UIView animateWithDuration:(speed * 1.5) delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0.85;
    } completion:^(BOOL finished) {}];
}


- (void) quickDim {
    if(self.isErased) return;
    if(self.hasAnimatedIn == NO) return;
    CGFloat prevAlpha = self.alpha;
    [UIView animateWithDuration:0.8 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.8 delay:0.9 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.alpha = prevAlpha;
        } completion:^(BOOL finished) {}];

    }];
}



- (void) setXPosition:(CGFloat)x {
    startPoint = self.center;
    CGPoint newPoint = CGPointMake([self convertLeftToCenter:x], self.center.y);
    self.center = newPoint;
}

- (void) setXPositionToCenter {
    startPoint = self.center;
    CGFloat x = (kScreenWidth / 2) - ([self width] / 2);
    CGPoint newPoint = CGPointMake([self convertLeftToCenter:x], self.center.y);
    self.center = newPoint;
}

- (void) moveToXPosition:(CGFloat)x {
    
    startPoint = self.center;
    CGFloat speed = [self speed];
    CGFloat duration = speed * (2.0 + ABF(2.5));
    
    self.animationX = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    self.animationX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.animationX.duration = duration;
    self.animationX.toValue = @([self convertLeftToCenter:x]);
    
    [self pop_addAnimation:self.animationX forKey:[NSString stringWithFormat:@"%@%@", @"x-", [self wordID]]];
}



- (void) eraseInstantly {
    self.isErased = YES;
    self.alpha = 0;
}


- (void) quickHide {
    self.alpha = 0;
}

- (void) quickShow {
    self.alpha = 1.0;
}


- (void) erase {
    self.isErased = YES;
    CGFloat speed = [self speed];
    [UIView animateWithDuration:(speed * 1.5) delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {}];
}

- (void) eraseWithDelay:(CGFloat)delay {
    self.isErased = YES;
    CGFloat speed = [self speed];
    [UIView animateWithDuration:(speed * ABF(1.5) + 0.4) delay:delay options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {}];
}



- (void) selfDestruct {

    self.isSelfDestructing = YES;
    self.locked = YES;
    
    CGFloat speed = ([self speed] + 2) / 3;
    CGFloat delay = speed * ABF(0.5);
    CGFloat duration = speed * (2.0 + ABF(3.0));

    [UIView animateWithDuration:duration delay:delay options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) selfDestructMorph {
    
    self.isSelfDestructing = YES;
    self.locked = YES;
    
    CGFloat speed = ([self speed] + 2) / 3;
    CGFloat delay = 0;
    CGFloat duration = speed * (2.0 + ABF(3.0));
    
    [UIView animateWithDuration:duration delay:delay options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



- (void) fadeColorToSourceStanza:(int)stanza {
    self.sourceStanza = stanza;
    UIColor *color = [ABUI progressHueColorForStanza:stanza];
    [UIView transitionWithView:self duration:2.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setTextColor:color];
        if(self.isRedacted) [self setBackgroundColor:color];
    } completion:nil];
}


- (void) redact {
    if(self.isErased) return;
    self.isRedacted = YES;
    [UIView transitionWithView:self duration:2.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setBackgroundColor:[self textColor]];
    } completion:nil];
}


// TODO
- (void) mirror {
    if(self.isErased) return;
    CGFloat scale = self.isMirrored ? 1.0 : -1.0;
    self.isMirrored = !self.isMirrored;
    [UIView transitionWithView:self duration:1.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1, scale);
    } completion:nil];
}





- (void) spin {
    self.isSpinning = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ABF(0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runSpinAnimationOnView:self duration:0.55 + ABF(1.75) rotations:1 repeat:INFINITY];
    });
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end


