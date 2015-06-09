//
//  ABUIElements.h
//  Abra
//
//  Created by Ian Hatcher on 2/23/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABMainViewController;
@class ABModal;

@interface ABUI : NSObject <UIWebViewDelegate>

+ (CGFloat) abraFontSize;
+ (CGFloat) abraFontMargin;
+ (CGFloat) abraLineHeight;
+ (CGFloat) abraFlowersFontSize;
+ (int) abraNumberOfLines;

+ (CGFloat) iPadToUniversalW:(CGFloat)n;
+ (CGFloat) iPadToUniversalH:(CGFloat)n;

+ (CGFloat) scaleXWithIphone:(CGFloat)iphone ipad:(CGFloat)ipad;
+ (CGFloat) scaleYWithIphone:(CGFloat)iphone ipad:(CGFloat)ipad;


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
+ (UIImage *)imageWithColor:(UIColor *)color;


+ (UIButton *) createInfoViewWithFrame:(CGRect)frame;
+ (UITextField *) createTextFieldWithFrame:(CGRect)frame;


+ (UIButton *) createButtonWithFrame:(CGRect)frame title:(NSString *)title;
+ (UIView *) createCenteredModalWithWidth:(CGFloat)w andHeight:(CGFloat)h;
+ (UIView *) createModalWithFrame:(CGRect)frame;


+ (ABModal *) createGraftModalWithMainVC:(ABMainViewController *)mainVC;

@end
