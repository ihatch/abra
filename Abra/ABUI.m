//
//  ABUI.m
//  Abra
//
//  Created by Ian Hatcher on 2/23/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABUI.h"
#import "ABState.h"
#import "ABScript.h"
#import "ABConstants.h"
#import "ABMainViewController.h"
#import "ABModal.h"


@implementation ABUI

UIView *infoView;
UIColor *normalColor, *selectedColor;
UIButton *infoButton;

static ABUI *ABUIInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABUIInstance == NULL) ABUIInstance = [[ABUI alloc] init];
    }
    
    normalColor = [ABUI goldColor];
    selectedColor = [ABUI goldColor];
}






////////////////
// DIMENSIONS //
////////////////

+ (CGFloat) iPadToUniversalW:(CGFloat)n {
    return kScreenWidth / (1024 / n);
}

+ (CGFloat) iPadToUniversalH:(CGFloat)n {
    return kScreenHeight / (768 / n);
}

+ (CGFloat) scaleXWithIphone:(CGFloat)iphone ipad:(CGFloat)ipad {
    return iphone + ((kScreenWidth - 568) / ((1024 - 568) / (ipad - iphone)));
}

+ (CGFloat) scaleYWithIphone:(CGFloat)iphone ipad:(CGFloat)ipad {
    return iphone + ((kScreenHeight - 320) / ((768 - 320) / (ipad - iphone)));
}

+ (BOOL) isIphone {
    return (kScreenWidth < 750);
}




+ (CGFloat) abraFontSize {
    return [ABUI scaleYWithIphone:17 ipad:21];
}
+ (CGFloat) abraOptionsFontSize {
    return [ABUI scaleYWithIphone:18 ipad:21];
}
+ (CGFloat) abraFontMargin {
    return [ABUI scaleYWithIphone:7 ipad:8];
}
+ (CGFloat) abraLineHeight {
    return [ABUI scaleYWithIphone:36 ipad:44];
}
+ (CGFloat) abraFlowersFontSize {
    return [ABUI scaleYWithIphone:20 ipad:30];
}






////////////
// COLORS //
////////////

+ (int) sanitizeStanzaIndex:(int)index {
    int total = [ABScript totalStanzasCount];
    if(index > total) index -= total;
    if(index < 0) index += total;
    return index;
}

+ (CGFloat) progressFloatForStanza:(int)stanza {
    stanza = [ABUI sanitizeStanzaIndex:stanza];
    return (CGFloat) stanza / ([ABScript totalStanzasCount]);
}

+ (UIColor *) progressHueColor {
    return [ABUI progressHueColorWithOffset:0.0];
}

+ (UIColor *) progressHueColorDark {
    CGFloat p = [ABUI progressFloatForStanza:[ABState getCurrentStanza]];
    CGFloat s = ABF(0.1);
    CGFloat hue = p + (0 + (ABF(0.10) - 0.05));
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:(0.4 + s) brightness:0.7 alpha:1];
}

+ (UIColor *) progressHueColorDarker {
    CGFloat p = [ABUI progressFloatForStanza:[ABState getCurrentStanza]];
    CGFloat s = ABF(0.1);
    CGFloat hue = p + (0 + (ABF(0.10) - 0.05));
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:(0.4 + s) brightness:0.2 alpha:1];
}

+ (UIColor *) progressHueColorWithOffset:(CGFloat)colorOffset {
    CGFloat p = [ABUI progressFloatForStanza:[ABState getCurrentStanza]];
    CGFloat s = ABF(0.1);
    CGFloat hue = p + (colorOffset + (ABF(0.10) - 0.05));
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:(0.4 + s) brightness:1 alpha:1];
}

+ (UIColor *) progressHueColorPreciselyWithOffset:(CGFloat)colorOffset {
    CGFloat p = [ABUI progressFloatForStanza:[ABState getCurrentStanza]];
    CGFloat hue = p + colorOffset;
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:0.5 brightness:1 alpha:1];
}

+ (UIColor *) progressHueColorForStanza:(int)stanza {
    stanza = [ABUI sanitizeStanzaIndex:stanza];
    CGFloat p = [ABUI progressFloatForStanza:stanza];
    CGFloat s = ABF(0.1);
    CGFloat hue = p + (0 + (ABF(0.10) - 0.05));
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:(0.4 + s) brightness:1 alpha:1];
}

+ (UIColor *) goldColor {
    return [UIColor colorWithHue:0.1 saturation:(0.3) brightness:1 alpha:1];
}

+ (UIColor *) darkGoldColor {
    return [UIColor colorWithHue:0.07 saturation:0.4 brightness:0.45 alpha:1];
}

+ (UIColor *) darkGoldColor2 {
    return [UIColor colorWithHue:0.07 saturation:0.55 brightness:0.7 alpha:1];
}

+ (UIColor *) darkGoldBackgroundColor {
    return [UIColor colorWithHue:0.07 saturation:0.4 brightness:0.25 alpha:1];
}

+ (UIColor *) whiteTextColor {
    return [UIColor colorWithRed:0.9 green:0.85 blue:0.78 alpha:1];
}


+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}







/////////////////////
// GENERIC BUTTONS //
/////////////////////

+ (UIButton *) horizontalButtonWithText:(NSString *)text andFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[ABUI darkGoldColor] forState:UIControlStateNormal];
    [button setTitleColor:[ABUI darkGoldColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[ABUI goldColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont fontWithName:ABRA_SYSTEM_FONT size:(kScreenWidth / 73.14)];  // 14.0f
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[ABUI imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[ABUI imageWithColor:[ABUI darkGoldBackgroundColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[ABUI imageWithColor:[ABUI darkGoldBackgroundColor]] forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    button.layer.cornerRadius = [ABUI iPadToUniversalH:10];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    button.clipsToBounds = YES;
    return button;
}








////////////////////////
// CENTERED MVC IMAGE //
////////////////////////

+ (UIImage *) imageWithImage:(UIImage *)image scaledToHeight: (float) i_height {
    float oldHeight = image.size.height;
    float scaleFactor = i_height / oldHeight;
    float newHeight = oldHeight * scaleFactor;
    float newWidth = image.size.width * scaleFactor;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImageView *) twinsImageView {
    UIImage *image = [UIImage imageNamed:@"abra_twins.png"];
    image = [ABUI imageWithImage:image scaledToHeight:kScreenHeight - 50];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake((kScreenWidth - image.size.width) / 2, 25, image.size.width, image.size.height);
    imageView.alpha = 0;
    imageView.hidden = YES;
    return imageView;
}






@end
