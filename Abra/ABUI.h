//
//  ABUIElements.h
//  Abra
//
//  Created by Ian Hatcher on 2/23/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABUI : NSObject <UIWebViewDelegate>

+ (void) setMainViewReference:(UIView *)view;
+ (UIView *) getMainViewReference;


+ (UIColor *) progressHueColor;
+ (UIColor *) progressHueColorWithOffset:(CGFloat)colorOffset;
+ (UIColor *) progressHueColorPreciselyWithOffset:(CGFloat)colorOffset;
+ (UIColor *) progressHueColorForStanza:(int)stanza;
+ (UIColor *) goldColor;
+ (UIColor *) darkGoldColor;
+ (UIColor *) darkGoldBackgroundColor;

+ (UIButton *) createControlPanelTriggerButtonWithFrame:(CGRect)frame;
+ (UIButton *) createInfoViewWithFrame:(CGRect)frame;
+ (UITextField *) createTextFieldWithFrame:(CGRect)frame;

+ (void) movePanelTriggerButtonDown;
+ (void) movePanelTriggerButtonUp;

+ (UIButton *) createButtonWithFrame:(CGRect)frame title:(NSString *)title;
+ (UIView *) createCenteredModalWithWidth:(CGFloat)w andHeight:(CGFloat)h;
+ (UIView *) createModalWithFrame:(CGRect)frame;


+ (CGFloat) abraFontSize;
+ (CGFloat) abraFontMargin;
+ (CGFloat) abraLineHeight;
+ (CGFloat) abraFlowersFontSize;


+ (CGFloat) iPadToUniversalW:(CGFloat)n;
+ (CGFloat) iPadToUniversalH:(CGFloat)n;


+ (BOOL) isIpadAir;
+ (BOOL) isIpad;
+ (CGFloat) screenWidth;
+ (CGFloat) screenHeight;
+ (CGRect) currentScreenBoundsForOrientation;



@end
