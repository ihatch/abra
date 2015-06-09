//
//  ABUIElements.m
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
+ (int) abraNumberOfLines {
    if(kScreenWidth < 900) return 5; else return 11;
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
    return [ABUI progressHueColorWithOffset:0.10];
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








///////////////
// INFO VIEW //
///////////////


+ (UIView *) createInfoViewWithFrame:(CGRect)frame {
    infoView = [[UIView alloc] initWithFrame:CGRectMake(80, 0, 864, 768)];
    infoView.backgroundColor = [UIColor blackColor];
    UIWebView *infoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 864, 768)]; //  self.view.bounds
    infoWebView.backgroundColor = [UIColor blackColor];
    NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"abraInfo" ofType:@"html"];
    if (infoPath) {
        NSData *htmlData = [NSData dataWithContentsOfFile:infoPath];
        [infoWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[[NSBundle mainBundle] bundleURL]];
    }
    infoWebView.scrollView.scrollEnabled = NO;
    infoWebView.scrollView.bounces = NO;

    [infoWebView setHidden:YES];
    [infoWebView setDelegate:ABUIInstance];
    
    [infoView addSubview:infoWebView];
    return infoView;
}


- (void) webViewDidFinishLoad:(UIWebView *)webView{
    [self performSelector:@selector(showInfoWebView:) withObject:webView afterDelay:0.1];
}

- (void) showInfoWebView:(UIWebView *)webView {
    [webView setHidden:NO];
}





////////////////
// TEXT FIELD //
////////////////

+ (UITextField *) createTextFieldWithFrame:(CGRect)frame {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor whiteColor];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"words to graft" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.24 alpha:1]}];
    textField.backgroundColor = [UIColor blackColor];
    textField.font = [UIFont fontWithName:ABRA_FONT size:18];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.textAlignment = NSTextAlignmentCenter;

    textField.keyboardAppearance = UIKeyboardAppearanceDark;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    textField.layer.cornerRadius = 8.0f;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = [ABUI goldColor].CGColor;
    textField.layer.borderWidth = 1.0f;
    
    return textField;
}




////////////////////
// GENERIC BUTTON //
////////////////////

+ (UIButton *) createButtonWithFrame:(CGRect)frame title:(NSString *)title {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:ABRA_FONT size:16];
    
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    [button setClipsToBounds:YES];
    [button setTitleEdgeInsets:UIEdgeInsetsZero];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:normalColor.CGColor];
    [button.layer setCornerRadius:8.0f];
    return button;
}




////////////
// MODALS //
////////////

+ (ABModal *) createGraftModalWithMainVC:(ABMainViewController *)mainVC {
    ABModal *graftModal = [[ABModal alloc] initWithType:@"graft" andMainVC:mainVC];
    return graftModal;
}



+ (UIView *) createCenteredModalWithWidth:(CGFloat)w andHeight:(CGFloat)h {

    CGFloat mw = w, mh = h, mx = ((kScreenWidth - mw) / 2), my = ((kScreenHeight - mh) / 3);
    UIView *modal = [ABUI createModalWithFrame:CGRectMake(mx, my, mw, mh)];
    return modal;
}


+ (UIView *) createModalWithFrame:(CGRect)frame {

    UIView *modal = [[UIView alloc] initWithFrame:frame];
    [modal.layer setBorderWidth:1.0f];
    [modal.layer setBorderColor:[ABUI progressHueColor].CGColor];
    modal.userInteractionEnabled = YES;
    modal.backgroundColor = [UIColor blackColor];
    return modal;
}







@end
