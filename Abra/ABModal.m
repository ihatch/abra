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
#import "ABState.h"
#import <QuartzCore/QuartzCore.h>

@implementation ABModal

CGFloat viewMargin = 10;
ABMainViewController *mainViewController;


- (id) initWithType:(NSInteger)type andMainVC:(ABMainViewController *)mainVC {

    mainViewController = mainVC;
    self.type = (int)type;
  
    viewMargin = [ABUI scaleXWithIphone:5 ipad:10];
    
    if(type == GRAFT_MODAL) [self setDimensionsForGraftBox];
    if(type == SETTINGS_MODAL) [self setDimensionsForSettingsBox];
    
    self = [super initWithFrame:CGRectMake(self.x, self.y, self.w, self.h)];
    
    if (self) {
        [self createInnerView];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        [self updateColor];
        
        if(type == SETTINGS_MODAL) {
            [self createSettings];
        }

    }
    return self;
}

- (void) setDimensionsForGraftBox {
    self.w = [ABUI scaleXWithIphone:300 ipad:340];
    self.h = [ABUI scaleYWithIphone:80 ipad:120];
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 4;
}

- (void) setDimensionsForSettingsBox {
    self.w = [ABUI scaleXWithIphone:335 ipad:350];
    self.h = [ABUI scaleYWithIphone:200 ipad:210];
    if([ABUI isIphone]) self.h = 160;
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 2;
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




- (UILabel *) settingsLabelWithX:(CGFloat)x y:(CGFloat)y text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 5, 260, 20)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSKernAttributeName value:@(1.0f) range:NSMakeRange(0, [text length])];
    label.attributedText = attributedString;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:ABRA_FONT size:16];
    [label setTextColor:[ABUI darkGoldColor2]];
    return label;
}

- (UISwitch *) settingsSwitchWithX:(CGFloat)x y:(CGFloat)y {
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(250, y, 20, 15)];
    [sw setTintColor:[ABUI darkGoldColor]];
    [sw setOnTintColor:[ABUI goldColor]];
    sw.transform = CGAffineTransformMakeScale(0.8, 0.8);
    return sw;
}


- (void) createSettings {
    
    CGFloat y = 20;
    CGFloat x = 30;
    CGFloat lineHeight = 40;
    
    UILabel *amLabel = [self settingsLabelWithX:x y:y text:@"Autonomous mutation"];
    UISwitch *amSwitch = [self settingsSwitchWithX:x y:y];
    [amSwitch setOn:YES];
    [amSwitch addTarget:self action:@selector(changeAutoMutation:) forControlEvents:UIControlEventValueChanged];
    [[self innerView] addSubview:amLabel];
    [[self innerView] addSubview:amSwitch];
    y += lineHeight;

    UILabel *apLabel = [self settingsLabelWithX:x y:y text:@"Autoplay"];
    UISwitch *apSwitch = [self settingsSwitchWithX:x y:y];
    [apSwitch addTarget:self action:@selector(changeAutoplay:) forControlEvents:UIControlEventValueChanged];
    [[self innerView] addSubview:apLabel];
    [[self innerView] addSubview:apSwitch];
    y += lineHeight;

    if ([ABUI isIphone] == NO) {
        UILabel *fiveLabel = [self settingsLabelWithX:x y:y text:@"Abridge to 5 lines"];
        UISwitch *fiveSwitch = [self settingsSwitchWithX:x y:y];
        [fiveSwitch addTarget:self action:@selector(changeDisplay:) forControlEvents:UIControlEventValueChanged];
        [[self innerView] addSubview:fiveLabel];
        [[self innerView] addSubview:fiveSwitch];
        y += lineHeight;
    }
    
    UILabel *resetLabel = [self settingsLabelWithX:x y:y text:@"Reset lexicon"];
    UISwitch *resetSwitch = [self settingsSwitchWithX:x y:y];
    [resetSwitch addTarget:self action:@selector(changeReset:) forControlEvents:UIControlEventValueChanged];
    [[self innerView] addSubview:resetLabel];
    [[self innerView] addSubview:resetSwitch];
    y += lineHeight;
}


- (void)changeAutoMutation:(id)sender{
    if([sender isOn]){
        [ABState setAutoMutation:YES];
    } else{
        [ABState setAutoMutation:NO];
    }
}

- (void)changeAutoplay:(id)sender{
    if([sender isOn]){
        [ABState setAutoplay:YES];
    } else{
        [ABState setAutoplay:NO];
    }
}

- (void)changeDisplay:(id)sender{
    if([sender isOn]){
        [ABState setIPhoneMode:YES];
    } else{
        [ABState setIPhoneMode:NO];
    }
}

- (void)changeReset:(id)sender{
    if([sender isOn]){
        [sender setOn:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset lexicon"
                                                        message:@"This will erase Abra's memory of all previously grafted text. Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
        
    } else{
//        NSLog(@"Switch is OFF");
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            [ABState setResetLexicon];
            break;
    }
}



@end
