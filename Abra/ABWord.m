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


@implementation ABWord

@synthesize width, height, isNew, startPoint, marginLeft, marginRight, sourceStanza, lineNumber, isGrafted, animationX, animationAlpha, animationSize, abWordID, locked, isSelfDestructing;



- (id) initWithFrame:(CGRect)frame andScriptWord:(ABScriptWord *) word {
    if(self = [super initWithFrame:frame]) {

        self.lineNumber = 0;
        self.text = word.text;

        self.isGrafted = word.isGrafted;
        self.marginLeft = word.marginLeft;
        self.marginRight = word.marginRight;
        self.sourceStanza = word.sourceStanza;
        
        self.isNew = YES;
        self.locked = YES;
        self.isSelfDestructing = NO;
        self.isErased = NO;
        
        self.font = [UIFont fontWithName:ABRA_FONT size:[ABUI abraFontSize]];
        [self resizeFrameToFitString];

        self.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
        self.alpha = 0;
        
        self.userInteractionEnabled = NO;
        
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
    CGFloat delay = speed * (0.2 + ABF(0.5));
    CGFloat duration = speed * (2.25 + ABF(2.8));

    if(isGrafted || sourceStanza == -1) {
        self.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.6 alpha:1];
    } else {
        self.textColor = [ABUI progressHueColorForStanza:self.sourceStanza];
    }
    
    [UIView animateWithDuration:duration delay:delay options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformMakeScale(randomSize, randomSize);
    } completion:^(BOOL finished) {
        self.locked = NO;
    }];
    
}


- (void) dim {
    if(self.isErased) return;
    CGFloat speed = [self speed];
    [UIView animateWithDuration:(speed * 1.5) delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0.8;
    } completion:^(BOOL finished) {}];
}




- (void) setXPosition:(CGFloat)x {
    startPoint = self.center;
    CGPoint newPoint = CGPointMake([self convertLeftToCenter:x], self.center.y);
    self.center = newPoint;
}


- (void) setXPositionToCenter {
    startPoint = self.center;
    CGFloat x = ([ABUI screenWidth] / 2) - ([self width] / 2);
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
    
    [self pop_addAnimation:self.animationX forKey:[NSString stringWithFormat:@"%@%@", @"x-", [self abWordID]]];
}



- (void) erase {
    self.isErased = YES;
    CGFloat speed = [self speed];
    [UIView animateWithDuration:(speed * 1.5) delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
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




@end


