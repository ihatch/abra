//
//  ABInfoView.m
//  Abra
//
//  Created by Ian Hatcher on 5/25/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABInfoView.h"
#import "ABState.h"
#import "ABControlPanel.h"
#import "ABUI.h"
#import <pop/POP.h>

@implementation ABInfoView

CGFloat screenWidth, screenHeight;
CGRect infoContainerFrame, infoNavFrame, infoContentFrame;
CGFloat margin;
UIView *infoNav, *infoMain, *mainView, *infoNavView;
UIWebView *contentView;

ABControlPanel *controlPanel;
NSString *aboutHtml, *backgroundHtml, *paperbackHtml, *artistsBookHtml, *thxHtml;
UIButton *aboutButton, *backgroundButton, *paperbackButton, *artistsBookButton, *thxButton, *currentlySelected;


- (id) initWithMainViewReference:(UIView *)main andControlPanelReference:(ABControlPanel *)cPanel {
    
    mainView = main;
    controlPanel = cPanel;
    
    screenWidth = [ABUI screenWidth];
    screenHeight = [ABUI screenHeight];

    margin = 100;
    CGFloat containerWidth = screenWidth - (margin * 2);
    CGFloat containerHeight = screenHeight - (margin * 2);
    CGFloat navWidth = (containerWidth / 3.3);
    CGFloat contentWidth = containerWidth - navWidth;
    
    infoContainerFrame = CGRectMake(margin, margin, containerWidth, containerHeight);
    infoNavFrame = CGRectMake(0, 0, navWidth, containerHeight);
    infoContentFrame = CGRectMake(navWidth, 0, contentWidth - (margin / 2), containerHeight);

    self = [super initWithFrame:infoContainerFrame];

    if (self) {
        
        self.alpha = 1;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.hidden = NO;
        self.layer.borderColor = [ABUI goldColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        infoNavView = [[UIView alloc] initWithFrame:infoNavFrame];
        infoNavView.backgroundColor = [UIColor clearColor];
        [self addSubview:infoNavView];
        
        contentView = [[UIWebView alloc] initWithFrame:infoContentFrame];
        contentView.scrollView.scrollEnabled = YES;
        contentView.scalesPageToFit = NO;
        [contentView setBackgroundColor:[UIColor clearColor]];
        [contentView setOpaque:NO];
        [self addSubview:contentView];

        [self initButtons];
        
        [self initInfoContents];
        [self showContents:aboutHtml];
        
    }
    return self;
}


- (void) show {
    [contentView loadHTMLString:aboutHtml baseURL:nil];
    
}


- (void) initInfoContents {
    
    aboutHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info-About" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    backgroundHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info-Background" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    paperbackHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info-Paperback" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    artistsBookHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info-ArtistsBook" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    thxHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info-Acknowledgements" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];

}

- (void) showContents:(NSString *)html {
    [contentView loadHTMLString:html baseURL:nil];
}


- (void) initNav {
//    - (CGFloat) iPadToUniversalW:(CGFloat)n;
//    - (CGFloat) iPadToUniversalH:(CGFloat)n;
//    - (UIButton *) controlButtonWithText:(NSString *)text andFrame:(CGRect)frame andAddToView:(BOOL)addToView;

}





- (void) initButtons {
    
    int y = [ABUI iPadToUniversalH:20], h = [ABUI iPadToUniversalH:30];
    CGFloat x = 20;
    
    aboutButton = [controlPanel controlButtonWithText:@"🌀 about" andFrame:CGRectMake(x, y, 200, h) andAddToView:NO];
    aboutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    aboutButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [infoNavView addSubview:aboutButton];
    [aboutButton addTarget:self action:@selector(aboutPressed) forControlEvents:UIControlEventTouchUpInside];
    [aboutButton setSelected:YES];
    currentlySelected = aboutButton;
    y += 40;
    
    backgroundButton = [controlPanel controlButtonWithText:@"🌱 background" andFrame:CGRectMake(x, y, 200, h) andAddToView:NO];
    backgroundButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backgroundButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [infoNavView addSubview:backgroundButton];
    [backgroundButton addTarget:self action:@selector(backgroundPressed) forControlEvents:UIControlEventTouchUpInside];
    y += 40;
    
    paperbackButton = [controlPanel controlButtonWithText:@"🍃 paperback" andFrame:CGRectMake(x, y, 200, h) andAddToView:NO];
    paperbackButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    paperbackButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [infoNavView addSubview:paperbackButton];
    [paperbackButton addTarget:self action:@selector(paperbackPressed) forControlEvents:UIControlEventTouchUpInside];
    y += 40;
    
    artistsBookButton = [controlPanel controlButtonWithText:@"🍂 artists' book" andFrame:CGRectMake(x, y, 200, h) andAddToView:NO];
    artistsBookButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    artistsBookButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [infoNavView addSubview:artistsBookButton];
    [artistsBookButton addTarget:self action:@selector(artistsBookPressed) forControlEvents:UIControlEventTouchUpInside];
    y += 40;
    
    thxButton = [controlPanel controlButtonWithText:@"✨ acknowledgements" andFrame:CGRectMake(x, y, 200, h) andAddToView:NO];
    thxButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    thxButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [infoNavView addSubview:thxButton];
    [thxButton addTarget:self action:@selector(thxPressed) forControlEvents:UIControlEventTouchUpInside];
    
}



- (void) selectModeWithButton:(UIButton *)button {
    if(currentlySelected) {
        [currentlySelected setSelected:NO];
    }
    [button setSelected:YES];
    [button setHighlighted:YES];
    currentlySelected = button;
}

- (void) aboutPressed {
    [self selectModeWithButton:aboutButton];
    [self showContents:aboutHtml];
}

- (void) backgroundPressed {
    [self selectModeWithButton:backgroundButton];
    [self showContents:backgroundHtml];
}

- (void) paperbackPressed {
    [self selectModeWithButton:paperbackButton];
    [self showContents:paperbackHtml];
}

- (void) artistsBookPressed {
    [self selectModeWithButton:artistsBookButton];
    [self showContents:artistsBookHtml];
}

- (void) thxPressed {
    [self selectModeWithButton:thxButton];
    [self showContents:thxHtml];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
