//
//  ABBlackCurtain.m
//  Abra
//
//  Created by Ian Hatcher on 2/22/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABBlackCurtain.h"
#import "ABIconBar.h"
#import "ABConstants.h"
#import "ABState.h"
#import "ABMainViewController.h"

@implementation ABBlackCurtain


- (id) initWithIconBar:(ABIconBar *)bar andMainVC:(ABMainViewController *)main {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    if (self) {
        self.alpha = 0;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.hidden = YES;
        self.isVisible = NO;
        self.destroyOnFadeOut = YES;
        self.isGraftCurtain = NO;
        self.mainVC = main;
        self.iconBar = bar;
    }
    return self;
}


- (void) show {

    [ABState disallowGestures];
    
    self.hidden = NO;
    self.isVisible = YES;
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        self.ready = YES;
    }];
}


- (void) hide {
    
    if(!self.isVisible) return;
    self.isVisible = NO;
    
    [self endEditing:YES];

    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self.mainVC blackCurtainDidDisappear];
        if(self.destroyOnFadeOut) {
            [self removeFromSuperview];
        } else {
            self.hidden = YES;
        }
    }];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];

    if (![touch.view isKindOfClass:[ABBlackCurtain class]]) return;
    if(self.ready && self.isVisible) {
        if(self.isGraftCurtain) {
            // switch to mutate mode in case of unsuccessful graft
            if(![self.mainVC userDidTouchOutsideGraftBox]) [self.iconBar selectMutate];
        } else {
            [self hide];
        }
    }
}



// called from main VC to close graft modal
- (void) hideWithSuccess:(BOOL)success {
    if(success == NO && self.isGraftCurtain) [self.iconBar selectMutate];
    [self hide];
}



@end
