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

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@implementation ABUI

UIView *infoView, *mainView;
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


+ (void) setMainViewReference:(UIView *)view {
    mainView = view;
}

+ (UIView *) getMainViewReference {
    return mainView;
}




+ (CGFloat) iPadToUniversalW:(CGFloat)n {
    return [ABUI screenWidth] / (1024 / n);
}

+ (CGFloat) iPadToUniversalH:(CGFloat)n {
    return [ABUI screenHeight] / (768 / n);
}




+ (CGFloat) abraFontSize {
    if(kScreenHeight < 400) return kScreenHeight / 27;
    return kScreenHeight / 36.5;   //    return 21.0;
}
+ (CGFloat) abraOptionsFontSize {
    if(kScreenHeight < 400) return kScreenHeight / 26;
    return kScreenHeight / 36.5;  //     21.0;
}
+ (CGFloat) abraFontMargin {
    if(kScreenHeight < 400) return kScreenHeight / 75;
    return kScreenHeight / 96;   //     8.0;
}
+ (CGFloat) abraLineHeight {
    if(kScreenHeight < 400) return kScreenHeight / 15;
    return kScreenHeight / 17.45;  //     44.0;
}
+ (CGFloat) abraFlowersFontSize {
    if(kScreenHeight < 400) return kScreenHeight / 10;
    return kScreenHeight / 25.6;  //     30.0;
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
    return [ABUI progressHueColorWithOffset:0.12];
}

+ (UIColor *) darkGoldColor {
    return [UIColor colorWithHue:0.07 saturation:0.4 brightness:0.45 alpha:1];
}

+ (UIColor *) darkGoldBackgroundColor {
    return [UIColor colorWithHue:0.07 saturation:0.4 brightness:0.25 alpha:1];
}







//////////////////////////////////
// CONTROL PANEL TRIGGER BUTTON //
//////////////////////////////////


+ (UIButton *) createControlPanelTriggerButtonWithFrame:(CGRect)frame {
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.frame = frame;
    infoButton.tintColor = [ABUI goldColor];
    infoButton.alpha = 0.5;
    [infoButton setImage:[UIImage imageNamed:@"ui_down_arrow.png"] forState:UIControlStateNormal];
    CGFloat m = kScreenWidth / 68.26666666666667;
    [infoButton setImageEdgeInsets:UIEdgeInsetsMake(m, m, m, m)];

    return infoButton;
}

+ (void) movePanelTriggerButtonDown {
    
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.5f];
    if( CGAffineTransformEqualToTransform( infoButton.imageView.transform, CGAffineTransformIdentity ) )
    {
        infoButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        infoButton.imageView.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];
    
    
    CGRect frame = infoButton.frame;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        infoButton.frame = CGRectMake(frame.origin.x, frame.origin.y + [ABUI iPadToUniversalH:65], frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {

    }];
}

+ (void) movePanelTriggerButtonUp {

    
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.5f];
    if( CGAffineTransformEqualToTransform( infoButton.imageView.transform, CGAffineTransformIdentity ) )
    {
        infoButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        infoButton.imageView.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];

    
    CGRect frame = infoButton.frame;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        infoButton.frame = CGRectMake(frame.origin.x, frame.origin.y - [ABUI iPadToUniversalH:65], frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
        
    }];

}



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

+ (UIView *) createCenteredModalWithWidth:(CGFloat)w andHeight:(CGFloat)h {

    CGFloat mw = w, mh = h, mx = ((1024 - mw) / 2), my = ((768 - mh) / 2);
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



///////////////////
// CONTROL PANEL //
///////////////////


+ (UIView *) createControlPanel:(CGRect)frame {
    
    UIView *modal = [[UIView alloc] initWithFrame:frame];
    [modal.layer setBorderWidth:1.0f];
    [modal.layer setBorderColor:[ABUI progressHueColor].CGColor];
    modal.userInteractionEnabled = YES;
    modal.backgroundColor = [UIColor blackColor];
    return modal;
}




///////////////////////
// SCREEN DIMENSIONS //
///////////////////////


+ (BOOL) isIpad {
    return [ABUI screenWidth] > 1023;
}

+ (BOOL) isIpadAir {
    return [ABUI screenWidth] > 1400;
}


+ (CGFloat) screenWidth {
    return kScreenWidth;
}

+ (CGFloat) screenHeight {
    return kScreenHeight;
}

+ (CGRect) currentScreenBoundsForOrientation {
    return [UIScreen mainScreen].bounds;
}






@end
