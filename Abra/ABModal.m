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
#import "ABVerticalContentFlow.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"

@implementation ABModal

CGFloat viewMargin = 10;
ABMainViewController *mainViewController;

CGRect infoContainerFrame, infoTitlesFrame, infoContentFrame;
CGFloat margin;
UIView *infoNav, *infoMain, *mainView, *infoTitlesView;



- (id) initWithType:(NSInteger)type andMainVC:(ABMainViewController *)mainVC {

    mainViewController = mainVC;
    self.type = (int)type;
  
    viewMargin = [ABUI scaleXWithIphone:5 ipad:10];
    
    if(type == GRAFT_MODAL) [self setDimensionsForGraftBox];
    if(type == SETTINGS_MODAL) [self setDimensionsForSettingsBox];
    if(type == TIP_MODAL) [self setDimensionsForTip];
    if(type == INFO_MODAL) [self setDimensionsForInfoView];
    
    self = [super initWithFrame:CGRectMake(self.x, self.y, self.w, self.h)];
    
    if (self) {
        [self createInnerView];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        [self updateColor];
        if(type == SETTINGS_MODAL) [self createSettings];
        if(type == INFO_MODAL) [self createInfoView];
    }
    return self;
}




/////////////
// GENERAL //
/////////////

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




///////////
// GRAFT //
///////////


- (void) setDimensionsForGraftBox {
    self.w = [ABUI scaleXWithIphone:300 ipad:340];
    self.h = [ABUI scaleYWithIphone:80 ipad:120];
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 4;
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






//////////////
// SETTINGS //
//////////////


- (void) setDimensionsForSettingsBox {
    self.w = [ABUI scaleXWithIphone:335 ipad:350];
    self.h = [ABUI scaleYWithIphone:200 ipad:210];
    if([ABUI isIphone]) self.h = 160;
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 2;
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


- (void)changeAutoMutation:(id)sender{
    if([sender isOn]) [ABState setAutoMutation:YES];
    else [ABState setAutoMutation:NO];
}

- (void)changeAutoplay:(id)sender{
    if([sender isOn]) [ABState setAutoplay:YES];
    else [ABState setAutoplay:NO];
}

- (void)changeDisplay:(id)sender{
    if([sender isOn]) [ABState setIPhoneMode:YES];
    else [ABState setIPhoneMode:NO];
}

- (void)changeReset:(id)sender{
    if([sender isOn]) {
        [sender setOn:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset lexicon" message:@"This will erase Abra's memory of all previously grafted text. Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) [ABState setResetLexicon];
}









///////////////
// INFO VIEW //
///////////////


- (void) setDimensionsForInfoView {
    self.w = kScreenWidth - [ABUI scaleXWithIphone:90 ipad:120];
    self.h = kScreenHeight - [ABUI scaleYWithIphone:60 ipad:200];
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 2;
}


- (void) createInfoView {
    
    CGFloat containerWidth = self.innerView.frame.size.width;
    CGFloat containerHeight = self.innerView.frame.size.height;
    CGFloat contentWidth = containerWidth / 1.618;
    CGFloat navWidth = (containerWidth - contentWidth);
    
    infoContainerFrame = CGRectMake(margin, margin, containerWidth, containerHeight);
    infoTitlesFrame = CGRectMake(0, 0, navWidth, containerHeight);
    infoContentFrame = CGRectMake(navWidth, 0, contentWidth - (margin / 2), containerHeight - (margin / 2));
    
    // Titles
    infoTitlesView = [[UIView alloc] initWithFrame:infoTitlesFrame];
    infoTitlesView.backgroundColor = [UIColor clearColor];
    CGRect titlesFrame = CGRectMake([ABUI scaleXWithIphone:15 ipad:30], 0, infoTitlesFrame.size.width - [ABUI scaleXWithIphone:60 ipad:100], containerHeight);
    ABVerticalContentFlow *titleLogosFlow = [[ABVerticalContentFlow alloc] initWithFrame:titlesFrame];
    [self addContentToTitleLogosFlow:titleLogosFlow];
    [infoTitlesView addSubview:titleLogosFlow];
    [self.innerView addSubview:infoTitlesView];
    
    // Content
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:infoContentFrame];
    scrollView.userInteractionEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    CGRect contentFrame = CGRectMake(0, 0, infoContentFrame.size.width - [ABUI scaleXWithIphone:15 ipad:30], 3000);
    ABVerticalContentFlow *contentFlow = [[ABVerticalContentFlow alloc] initWithFrame:contentFrame];
    [self addContentToInfoContentFlow:contentFlow];
    [scrollView addSubview:contentFlow];
    scrollView.contentSize = contentFlow.frame.size;
    [self.innerView addSubview:scrollView];
    self.scrollView = scrollView;
}


- (void) addContentToTitleLogosFlow:(ABVerticalContentFlow *)flow {
    [flow addImage:@"abra_emboss.png"];
    [flow addAuthors:@"     by Amaranth Borsuk\n            Kate Durbin\n                  Ian Hatcher\n                          & You"];
    [flow addSectionMargin];
    [flow addImageToBottom:@"abra_logos_4.png"];
    [flow refreshFrame];
}


- (void) addContentToInfoContentFlow:(ABVerticalContentFlow *)flow {
    
    [flow addHeading:@"INTRODUCTION"];
    [flow addParagraph:@"The Abra app is a poetry instrument/spellbook that responds to touch. Caress the words and watch them shift under your fingers."];
    [flow addParagraph:@"At the bottom of the screen is a rotary dial, by which you can navigate to different poems in the Abra cycle. Touch the top of the screen to reveal a toolbar."];
    [flow addParagraph:@"There are many ways to interact with Abra. Read, write, and experiment to discover Abra's secrets and make her poems your own."];
    [flow addSectionMargin];
    
    [flow addHeading:@"OVERVIEW"];
    [flow addParagraph:@"Abra is a multifaceted project supported by an Expanded Artists’ Books grant from the Center for Book and Paper Arts (Columbia College Chicago). Its two main manifestations are this app, available free for iPad and iPhone, and a limited-edition clothbound artists’ book. The two can be read separately or together, with an iPad inserted into a slot in the back of the book."];
    [flow addParagraph:@"Abra's text was composed by Amaranth Borsuk and Kate Durbin. This app was designed and coded by Ian Hatcher. Art direction and decision-making for both artists’ book and app were undertaken in tandem as a team."];
//    [flow addImage:@"abra_twins_spread.png"];
    [flow addParagraph:@"For information on the conceptual framework and background of the project, please see our site:"];
    [flow addLink:@"http://a-b-r-a.com"];
    [flow addSectionMargin];
    
    [flow addHeading:@"ARTISTS' BOOK"];
    [flow addParagraph:@"The Abra artists' book features blind letterpress impressions, heat-sensitive disappearing ink, foil-stamping, and laser-cut openings. These last can serve as windows, revealing the screen of an embedded iPad running this app, conjoining the analog and digital into a single reading experience."];
    [flow addImage:@"artists_book_spread_4.png"];
    [flow addParagraph:@"The artists' book was fabricated by Amy Rabas at the Center for Book and Paper Arts, with help from graduate students in Inter-Arts."];
    [flow addParagraph:@"To learn more about this edition or order a copy:"];
    [flow addLink:@"http://a-b-r-a.com/artists-book"];
    [flow addSectionMargin];
    
    [flow addHeading:@"PAPERBACK"];
    [flow addParagraph:@"In addition to this app and the limited-edition artist’s book, Abra is available widely as a trade paperback from 1913 Press."];
    [flow addParagraph:@"In this edition, the poem’s stanzas meld one into the next, each recycling language from the preceding and animating as the reader turns the page. Illustrations by visual artist Zach Kleyn grow and mutate on facing pages, eventually reaching across the book’s gutter to meld with the text."];
    [flow addLink:@"http://www.journal1913.org/publications/abra/"];
    [flow addSectionMargin];
    
    [flow addHeading:@"ACKNOWLEDGEMENTS"];
    [flow addParagraph:@"We are grateful to the Center for Book and Paper Arts at Columbia College Chicago for their support of this work: Stephen Woodall, tireless mentor; Amy Rabas, visionary paper artist; and Clif Meador, Jessica Cochran, April Sheridan, Michelle Citron, and Paul Catanese, generous interlocutors."];
    [flow addParagraph:@"Additional thanks to Abraham Avnisan, Steven Baughman, Danny Cannizaro, Samantha Gorman, Stephanie Strickland, Chris Wegman, and Paula Wegman for support and feedback on the app."];
    [flow addSpecialItalicizedParagraph:@"Some of Abra's text appeared in slightly different form in Action, Yes!; The &Now Awards 3; Black Warrior Review; Bone Bouquet; The Collagist; Joyland Poetry; Lana Turner: A Journal of Poetry and Opinion; Lit; Peep/Show; SPECS; Spoon River Poetry Review; and VLAK."];
    [flow addSectionMargin];
    
    [flow refreshFrame];
}


- (void) resetScrollViewPosition {
    [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:NO];
}





//////////
// TIPS //
//////////


- (void) setDimensionsForTip {
    self.w = [ABUI scaleXWithIphone:335 ipad:350];
    self.h = [ABUI scaleYWithIphone:200 ipad:210];
    if([ABUI isIphone]) self.h = 160;
    self.x = (kScreenWidth - self.w) / 2;
    self.y = (kScreenHeight - self.h) / 2;
}






@end
