//
//  ABFlowerButton.h
//  Abra
//
//  Created by Ian Hatcher on 2/8/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABFlowerButton.h"
#import "ABConstants.h"
#import "ABState.h"

@implementation ABFlowerButton {
    BOOL isAnimating;
}

- (id)init {

    self = [super init];
    if (self) {
        
        isAnimating = NO;
        
        self.graftButton = [[UILabel alloc] initWithFrame:CGRectMake(100, 600, 100, 100)];
        self.graftButton.font = [UIFont fontWithName:ABRA_FLOWERS_FONT size:ABRA_FLOWERBED_FONT_SIZE];
        self.graftButton.text = @"n";
        self.graftButton.textAlignment = NSTextAlignmentCenter;
        self.graftButton.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gold2.jpg"]];
        self.graftButton.alpha = 0;
        
        self.playButton = [[UILabel alloc] initWithFrame:CGRectMake(900, 600, 100, 100)];
        self.playButton.font = [UIFont fontWithName:ABRA_FLOWERS_FONT size:ABRA_FLOWERBED_FONT_SIZE];
        self.playButton.text = @"a";
        self.playButton.textAlignment = NSTextAlignmentCenter;
        self.playButton.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gold1.jpg"]];
        self.playButton.alpha = 0;

    }
    return self;
}


- (void) flash {
    
    CGFloat fadeUpTo = 0.55;
    CGFloat fadeOutTo = 0.00;
    
    int mutationLevel = [ABState checkMutationLevel];

    fadeUpTo += (0.03 * mutationLevel);
    
    isAnimating = YES;
    [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION animations:^() {
        self.flowers1.alpha = fadeUpTo;
        self.flowers2.alpha = fadeUpTo;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION animations:^() {
            self.flowers1.alpha = fadeOutTo;
            self.flowers2.alpha = fadeOutTo;
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }];
}


- (void) transitionStanza:(NSNotification *) notification {
    if(isAnimating == NO) {
        CGFloat fadeTo = 0;
        int mutationLevel = [ABState checkMutationLevel];
        if(mutationLevel > 0) fadeTo = 0.1 + 0.03 * mutationLevel;

        [UIView animateWithDuration:1.8 animations:^() {
            self.flowers1.alpha = fadeTo;
            self.flowers2.alpha = fadeTo;
        }];
    }
}


- (void) show {
    [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION animations:^() {
        self.flowers1.alpha = 0.55;
        self.flowers2.alpha = 0.55;

    }];
}

- (void) hide {
    [UIView animateWithDuration:ABRA_GESTURE_FEEDBACK_FADE_DURATION animations:^() {
        self.flowers1.alpha = 0;
        self.flowers2.alpha = 0;
    }];
}


@end
