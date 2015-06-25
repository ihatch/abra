//
//  ABIcon.m
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABIcon.h"
#import "ABConstants.h"
#import "ABUI.h"

@implementation ABIcon


- (id) initWithFrame:(CGRect)frame text:(NSString *)text symbol:(NSString *)symbol iconType:(iconType)type {
    
    self.iconType = type;
    
    self.labelFontSize = [ABUI scaleYWithIphone:6.5 ipad:10];
    self.symbolFontSize = [ABUI scaleYWithIphone:14 ipad:25];
    self.labelTopOffset = [ABUI scaleYWithIphone:4 ipad:10];
    
    self.iconWidth = frame.size.width;
    self.iconHeight = frame.size.height;
    
    self = [super initWithFrame:frame];
    
    if (self) {

        self.isModeControl = (self.iconType == MUTATE_ICON || self.iconType == GRAFT_ICON || self.iconType == PRUNE_ICON || self.iconType == ERASE_ICON);
        
        if(self.iconType != FLOWER_ICON) {
            self.iconLabel = [self createTextLabelWithText:text];
            self.iconLabelHighlighted = [self createTextLabelWithText:text];
            self.iconLabelHighlighted.alpha = 0;
            [self.iconLabelHighlighted setTextColor:[ABUI goldColor]];
            [self addSubview:self.iconLabel];
            [self addSubview:self.iconLabelHighlighted];
        }
        
        self.iconSymbol = [self createSymbolLabelWithText:symbol];

        [self addSubview:self.iconSymbol];
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.0]];
        [self hideInstantly];
    }
    return self;
    
    
}


- (UILabel *) createTextLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.iconWidth, self.iconHeight)];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSKernAttributeName value:@(1.0f) range:NSMakeRange(0, [text length])];
    label.attributedText = attributedString;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:ABRA_SYSTEM_FONT size:self.labelFontSize];
    [label setTextColor:[ABUI darkGoldColor2]];
    
    CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    label.frame = CGRectMake(0, self.labelTopOffset, self.iconWidth, size.height);
    return label;
}


- (UILabel *) createSymbolLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.iconWidth, self.iconHeight)];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    
    if(self.iconType == FLOWER_ICON) {
        label.font = [UIFont fontWithName:ABRA_FLOWERS_FONT size:self.symbolFontSize];
    } else {
        label.font = [UIFont fontWithName:ABRA_SYSTEM_FONT size:self.symbolFontSize];
    }
    
    [label setTextColor:[ABUI darkGoldColor2]];
    
    CGFloat y;
    if(self.iconType == FLOWER_ICON) {
        y = [ABUI scaleYWithIphone:6 ipad:6];
    } else {
        y = self.iconHeight - self.symbolFontSize - (self.labelTopOffset * [ABUI scaleYWithIphone:2.9 ipad:2]);
    }
    
    CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    CGRect frame = CGRectMake(0, y, self.iconWidth, size.height);
    label.frame = frame;
    label.alpha = 0.7;
    
    return label;
}



// [[NSNotificationCenter defaultCenter] postNotificationName:@"touchIcon" object:self];



- (void) select {
    [self highlight];
}

- (void) highlight {
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.isAnimating = YES;
        self.isSelected = YES;
        if(self.isVisible) [self show]; else [self hide];
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
    
}

- (void) lowlight {
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.isAnimating = YES;
        self.isSelected = NO;
        if(self.isVisible) [self show]; else [self hide];
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

- (void) show {
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.isAnimating = YES;
        if(self.iconType == FLOWER_ICON) [self showFlower];
        else if(self.isSelected) [self showSelected];
        else [self showUnselected];
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

- (void) hide {
    [UIView animateWithDuration:0.6 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.isAnimating = YES;
        if(self.iconType == FLOWER_ICON) [self hideFlower];
        else if(self.isSelected) [self hideSelected];
        else [self hideUnselected];
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

- (void) flash {
    [UIView animateWithDuration:0.4 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.isAnimating = YES;
        [self showSelected];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            [self showUnselected];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }];
    }];

}

- (void) hideInstantly {
    if(self.iconType == FLOWER_ICON) [self hideFlower];
    else if(self.isSelected) [self hideSelected];
    else [self hideUnselected];
}



- (void) showFlower {
    self.alpha = 1;
    self.isVisible = YES;
}
- (void) hideFlower {
    self.alpha = 0.7;
    self.isVisible = NO;
}


- (void) showUnselected {
    self.iconLabelHighlighted.alpha = 0;
    self.iconLabel.alpha = 1;
    self.iconSymbol.alpha = 0.4;
    self.isVisible = YES;
}
- (void) hideUnselected {
    self.iconLabelHighlighted.alpha = 0;
    self.iconLabel.alpha = 0;
    self.iconSymbol.alpha = 0;
    self.isVisible = NO;
}


- (void) showSelected {
    self.iconLabelHighlighted.alpha = 0.9;
    self.iconSymbol.alpha = 0.7;
    self.iconLabel.alpha = 0.3;
    self.isVisible = YES;
}
- (void) hideSelected {
    self.iconLabelHighlighted.alpha = 0;
    self.iconLabel.alpha = 0;
    self.iconSymbol.alpha = 0.35;
    self.isVisible = NO;
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
