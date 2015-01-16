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

@implementation ABUI

CGSize screenSize;
UIColor *normalColor;
UIColor *selectedColor;




static ABUI *ABUIInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABUIInstance == NULL) ABUIInstance = [[ABUI alloc] init];
    }
    normalColor = [ABUI goldColor];
    selectedColor = [ABUI goldColor];

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
    CGFloat p = [ABUI progressFloatForStanza:[ABState currentIndex]];
    CGFloat s = ABF(0.1);
    CGFloat hue = p + (colorOffset + (ABF(0.10) - 0.05));
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:(0.4 + s) brightness:0.92 alpha:1];
}

+ (UIColor *) progressHueColorPreciselyWithOffset:(CGFloat)colorOffset {
    CGFloat p = [ABUI progressFloatForStanza:[ABState currentIndex]];
    CGFloat hue = p + colorOffset;
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:0.5 brightness:0.92 alpha:1];
}

+ (UIColor *) progressHueColorForStanza:(int)stanza {
    stanza = [ABUI sanitizeStanzaIndex:stanza];
    CGFloat p = [ABUI progressFloatForStanza:stanza];
    CGFloat s = ABF(0.1);
    CGFloat hue = p + (0 + (ABF(0.10) - 0.05));
    if(hue > 1) hue -= 1;
    if(hue < 0) hue += 1;
    return [UIColor colorWithHue:hue saturation:(0.4 + s) brightness:0.92 alpha:1];
}

+ (UIColor *) goldColor {
    return [ABUI progressHueColorWithOffset:0.12];
}

+ (UIColor *) darkGoldColor {
    return [UIColor colorWithHue:0.07 saturation:0.2 brightness:0.25 alpha:1];
}






///////////////////////
// APP MODE SELECTOR //
///////////////////////


+ (UILabel *) createAppModeSelectorLabel {
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(587, 655, 200, 20)];
    modeLabel.textColor = [ABUI darkGoldColor];
    modeLabel.text = @"App mode:";
    modeLabel.font = [UIFont systemFontOfSize:12.0f];
    return modeLabel;
}

+ (UISegmentedControl *) createAppModeSelector {
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"standalone", @"in book"]];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    segmentedControl.frame = CGRectMake(587, 680, 160, 30);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [ABUI darkGoldColor];
    return segmentedControl;
}


/////////////////
// INFO BUTTON //
/////////////////


+ (UIButton *) createInfoButtonWithFrame:(CGRect)frame {
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = frame;
    infoButton.tintColor = [ABUI goldColor];
    infoButton.alpha = 0.5;
    return infoButton;
}

+ (UIView *) createInfoViewWithFrame:(CGRect)frame {
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(80, 0, 864, 768)];
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
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"text to graft" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.24 alpha:1]}];
    textField.backgroundColor = [UIColor blackColor];
    textField.font = [UIFont fontWithName:ABRA_FONT size:18];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.TextAlignment = NSTextAlignmentCenter;

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
    if(!screenSize.width) {
        CGRect rect = [self currentScreenBoundsForOrientation];
        screenSize = rect.size;
    }
    return screenSize.width;
}

+ (CGFloat) screenHeight {
    if(!screenSize.height) {
        CGRect rect = [self currentScreenBoundsForOrientation];
        screenSize = rect.size;
    }
    return screenSize.height;
}

+ (CGRect) currentScreenBoundsForOrientation {
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenBounds);
    CGFloat height = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    } else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds;
}






@end
