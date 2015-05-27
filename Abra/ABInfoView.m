//
//  ABInfoView.m
//  Abra
//
//  Created by Ian Hatcher on 5/25/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABInfoView.h"
#import "ABState.h"
#import "ABUI.h"
#import <pop/POP.h>

@implementation ABInfoView

CGFloat screenWidth, screenHeight;
CGRect panelFrame;
ABMainViewController *mainViewController;


- (id) initWithMainView:(ABMainViewController *)main {
    
    screenWidth = [ABUI screenWidth];
    screenHeight = [ABUI screenHeight];

    mainViewController = main;
    panelFrame = CGRectMake(20, 20, screenWidth - 40, screenHeight - 40);

    self = [super initWithFrame:panelFrame];

    if (self) {
        self.alpha = 1;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        self.hidden = NO;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[self frame]];
        scrollView.scrollEnabled = YES;
        scrollView.userInteractionEnabled = YES;
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.backgroundColor = [UIColor colorWithRed:100 green:150 blue:200 alpha:1];
        scrollView.contentSize = CGSizeMake(2000, 2000);
        [self addSubview:scrollView];
        
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
