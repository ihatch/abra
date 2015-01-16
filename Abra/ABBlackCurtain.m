//
//  ABBlackCurtain.m
//  Abra
//
//  Created by Ian Hatcher on 2/22/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABBlackCurtain.h"
#import "ABState.h"

@implementation ABBlackCurtain

@synthesize destroyOnFadeOut;

BOOL ready;


- (id) init {
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    if (self) {
        self.alpha = 0;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.hidden = YES;
        self.destroyOnFadeOut = YES;
    }
    return self;
}


- (void) show {
    [ABState disallowGestures];
    self.hidden = NO;
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        ready = YES;
    }];
}


- (void) hide {
    [self endEditing:YES];
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [ABState allowGestures];
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
    if(ready) [self hide];
}


@end
