//
//  ABUI.h
//  Abra
//
//  Created by Ian Hatcher on 2/23/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABMainViewController;
@class ABModal;

@interface ABUI : NSObject <UIWebViewDelegate>

+ (BOOL) isIphone;

+ (CGFloat) iPadToUniversalW:(CGFloat)n;
+ (CGFloat) iPadToUniversalH:(CGFloat)n;

+ (CGFloat) scaleXWithIphone:(CGFloat)iphone ipad:(CGFloat)ipad;
+ (CGFloat) scaleYWithIphone:(CGFloat)iphone ipad:(CGFloat)ipad;

+ (CGFloat) abraFontSize;
+ (CGFloat) abraFontMargin;
+ (CGFloat) abraLineHeight;
+ (CGFloat) abraFlowersFontSize;


+ (UIColor *) progressHueColor;
+ (UIColor *) progressHueColorDark;
+ (UIColor *) progressHueColorDarker;
+ (UIColor *) progressHueColorWithOffset:(CGFloat)colorOffset;
+ (UIColor *) progressHueColorPreciselyWithOffset:(CGFloat)colorOffset;
+ (UIColor *) progressHueColorForStanza:(int)stanza;
+ (UIColor *) goldColor;
+ (UIColor *) darkGoldColor;
+ (UIColor *) darkGoldColor2;
+ (UIColor *) darkGoldBackgroundColor;
+ (UIColor *) whiteTextColor;
+ (UIImage *)imageWithColor:(UIColor *)color;


+ (UIImageView *) twinsImageView;


+ (UIButton *) horizontalButtonWithText:(NSString *)text andFrame:(CGRect)frame;


@end
