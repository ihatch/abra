//
//  ABInfoView.m
//  Abra
//
//  Created by Ian Hatcher on 5/25/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABInfoView.h"
#import "ABMainViewController.h"
#import "ABConstants.h"
#import "ABState.h"
#import "ABUI.h"
#import <pop/POP.h>

@implementation ABInfoView

CGRect infoContainerFrame, infoNavFrame, infoContentFrame;
CGFloat margin;
UIView *infoNav, *infoMain, *mainView, *infoNavView;
UIWebView *contentView;

NSString *aboutHtml, *backgroundHtml, *paperbackHtml, *artistsBookHtml, *thxHtml;
UIButton *aboutButton, *backgroundButton, *paperbackButton, *artistsBookButton, *thxButton, *currentlySelected;


- (id) init {
    
    margin = 100;
    CGFloat containerWidth = kScreenWidth - (margin * 2);
    CGFloat containerHeight = kScreenHeight - (margin * 2);
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

- (NSString *) loadContents:(NSString *)htmlPath {
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:htmlPath ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
}

- (void) initInfoContents {
    aboutHtml = [self loadContents:@"info-About"];
    backgroundHtml = [self loadContents:@"info-Background"];
    paperbackHtml = [self loadContents:@"info-Paperback"];
    artistsBookHtml = [self loadContents:@"info-ArtistsBook"];
    thxHtml = [self loadContents:@"info-Acknowledgements"];
}

- (void) showContents:(NSString *)html {
    [contentView loadHTMLString:html baseURL:nil];
}






- (void) initButtons {
    
    int y = [ABUI iPadToUniversalH:20], h = [ABUI iPadToUniversalH:30];
    CGFloat x = 20;

    aboutButton = [ABUI horizontalButtonWithText:@"🌀 about" andFrame:CGRectMake(x, y, 200, h)];
    [infoNavView addSubview:aboutButton];
    [aboutButton addTarget:self action:@selector(aboutPressed) forControlEvents:UIControlEventTouchUpInside];
    [aboutButton setSelected:YES];
    currentlySelected = aboutButton;
    y += 40;
    
    backgroundButton = [ABUI horizontalButtonWithText:@"🌱 background" andFrame:CGRectMake(x, y, 200, h)];
    [infoNavView addSubview:backgroundButton];
    [backgroundButton addTarget:self action:@selector(backgroundPressed) forControlEvents:UIControlEventTouchUpInside];
    y += 40;
    
    paperbackButton = [ABUI horizontalButtonWithText:@"🍃 paperback" andFrame:CGRectMake(x, y, 200, h)];
    [infoNavView addSubview:paperbackButton];
    [paperbackButton addTarget:self action:@selector(paperbackPressed) forControlEvents:UIControlEventTouchUpInside];
    y += 40;
    
    artistsBookButton = [ABUI horizontalButtonWithText:@"🍂 artists' book" andFrame:CGRectMake(x, y, 200, h)];
    [infoNavView addSubview:artistsBookButton];
    [artistsBookButton addTarget:self action:@selector(artistsBookPressed) forControlEvents:UIControlEventTouchUpInside];
    y += 40;
    
    thxButton = [ABUI horizontalButtonWithText:@"✨ acknowledgements" andFrame:CGRectMake(x, y, 200, h)];
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







@end
