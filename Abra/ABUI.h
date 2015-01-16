//
//  ABUIElements.h
//  Abra
//
//  Created by Ian Hatcher on 2/23/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABUI : NSObject <UIWebViewDelegate>

+ (UIColor *) progressHueColor;
+ (UIColor *) progressHueColorWithOffset:(CGFloat)colorOffset;
+ (UIColor *) progressHueColorPreciselyWithOffset:(CGFloat)colorOffset;
+ (UIColor *) progressHueColorForStanza:(int)stanza;
+ (UIColor *) goldColor;
+ (UIColor *) darkGoldColor;

+ (UILabel *) createAppModeSelectorLabel;
+ (UISegmentedControl *) createAppModeSelector;

+ (UIButton *) createInfoButtonWithFrame:(CGRect)frame;
+ (UIButton *) createInfoViewWithFrame:(CGRect)frame;
+ (UITextField *) createTextFieldWithFrame:(CGRect)frame;

+ (UIButton *) createButtonWithFrame:(CGRect)frame title:(NSString *)title;
+ (UIView *) createCenteredModalWithWidth:(CGFloat)w andHeight:(CGFloat)h;
+ (UIView *) createModalWithFrame:(CGRect)frame;

+ (BOOL) isIpadAir;
+ (BOOL) isIpad;
+ (CGFloat) screenWidth;
+ (CGFloat) screenHeight;
+ (CGRect) currentScreenBoundsForOrientation;



@end
