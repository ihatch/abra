//
//  ABGestureArrow.m
//  Abra
//
//  Created by Ian Hatcher on 2/5/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABGestureArrow.h"
#import "ABConstants.h"
#import "ABState.h"
#import "ABUI.h"

@implementation ABGestureArrow {
    BOOL isAnimating;
    CGFloat colorOffset;
    CGFloat fontSize;
    BOOL offsetIsStanzaSpecific;
}


- (id)initWithType:(NSString *)type {
    
    CGRect frame;
    NSString *text;

    if([type isEqualToString:@"forward"]) {
        frame = CGRectMake(950, 300, 50, 50);
        colorOffset = 0.1;
        text = @"1";
        fontSize = ABRA_FLOWERS_FONT_SIZE;
    }

    else if([type isEqualToString:@"backward"]) {
        frame = CGRectMake(24, 300, 50, 50);
        colorOffset = 0.9;
        text = @"2";
        fontSize = ABRA_FLOWERS_FONT_SIZE;
    }

    else if([type isEqualToString:@"accelerate"]) {
        frame = CGRectMake(490, 40, 50, 50);
        colorOffset = 0;
        text = @"X";
        fontSize = ABRA_FLOWERS_FONT_SIZE;
    }

    else if([type isEqualToString:@"decelerate"]) {
        frame = CGRectMake(490, 620, 50, 50);
        colorOffset = 0;
        text = @"x";
        fontSize = ABRA_FLOWERS_FONT_SIZE;
    }

    else if([type isEqualToString:@"reset"]) {
        frame = CGRectMake(80, 48, 50, 50);
        colorOffset = 0;
        text = @"v";
        fontSize = ABRA_FLOWERS_FONT_SIZE * 1.2;
        offsetIsStanzaSpecific = YES;
    }

    
    self = [super initWithFrame:frame];
    if (self) {
        self.text = text;
        self.font = [UIFont fontWithName:ABRA_FLOWERS_FONT size:fontSize];
        self.textColor = [ABUI progressHueColorPreciselyWithOffset:0];
        self.alpha = 0;
        [self resizeFrameToFitString];
    }
    return self;
}


- (void) resizeFrameToFitString {
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


- (void) flash {
    
    CGFloat fadeUpTo = 0.85;
    CGFloat fadeOutTo = 0.00;
    
    self.textColor = [ABUI progressHueColorPreciselyWithOffset:0];
    isAnimating = YES;

    UIColor *newColor;
    
    if(offsetIsStanzaSpecific) {
        newColor = [ABUI progressHueColorForStanza:colorOffset];
    } else {
        newColor = [ABUI progressHueColorPreciselyWithOffset:colorOffset];
    }

    [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION * 2 animations:^() {
        self.textColor = newColor;
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION animations:^() {
        self.alpha = fadeUpTo;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION animations:^() {
            self.alpha = fadeOutTo;
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }];
}


@end
