//
//  ABModal.m
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABModal.h"
#import "ABConstants.h"
#import "ABMainViewController.h"
#import "ABUI.h"

#import <QuartzCore/QuartzCore.h>

//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
//
//@implementation UITextField (custom)
//- (CGRect)textRectForBounds:(CGRect)bounds {
//    return CGRectMake(bounds.origin.x + 15, bounds.origin.y + 8,
//                      bounds.size.width - 30, bounds.size.height - 16);
//}
//- (CGRect)editingRectForBounds:(CGRect)bounds {
//    return [self textRectForBounds:bounds];
//}
//@end
//
//#pragma clang diagnostic pop
//

@implementation ABModal

CGFloat viewMargin = 10;
ABMainViewController *mainViewController;


- (id) initWithType:(NSString *)type andMainVC:(ABMainViewController *)mainVC {

    mainViewController = mainVC;
    self.type = type;
  
    viewMargin = [ABUI scaleXWithIphone:5 ipad:10];
    
    // graft box
    self.w = [ABUI scaleXWithIphone:300 ipad:340];
    self.h = [ABUI scaleYWithIphone:80 ipad:120];
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 4;
    
    self = [super initWithFrame:CGRectMake(self.x, self.y, self.w, self.h)];
    
    if (self) {
        [self createInnerView];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        [self updateColor];
    }
    return self;
}

- (void) updateColor {
    CGColorRef colRef = [ABUI progressHueColorDark].CGColor;
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:colRef];
    
    if(self.innerView != nil) {
        [self.innerView.layer setBorderColor:[ABUI progressHueColorDarker].CGColor];
    }
}


- (void) createInnerView {
    CGRect frame = CGRectMake(viewMargin, viewMargin, self.w - (viewMargin * 2), self.h - (viewMargin * 2));
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    view.layer.cornerRadius = 8.0f;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [ABUI darkGoldColor].CGColor;
    view.layer.borderWidth = 1.0f;
    [self addSubview:view];
    self.innerView = view;
}



- (UITextField *) createTextField {
    CGRect iFrame = self.innerView.frame;
    CGFloat w = iFrame.size.width;
    CGFloat h = iFrame.size.height;
    CGRect frame = CGRectMake(viewMargin, viewMargin, w - (viewMargin * 2), h - (viewMargin * 2));
    
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor whiteColor];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"words to graft" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.24 alpha:1]}];
    textField.backgroundColor = [UIColor blackColor];
    textField.font = [UIFont fontWithName:ABRA_FONT size:[ABUI scaleXWithIphone:16 ipad:18]];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.textAlignment = NSTextAlignmentCenter;
    
    textField.keyboardAppearance = UIKeyboardAppearanceDark;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeNever;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"clear_button.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    [button addTarget:self action:@selector(clearTextView:) forControlEvents:UIControlEventTouchDown];
    textField.rightView = button;
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    self.textField = textField;
    return textField;
}

- (void) clearTextView:(id)sender{
    self.textField.text = @"";
}



@end
