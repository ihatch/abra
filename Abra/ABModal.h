//
//  ABModal.h
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABMainViewController;
@class ABFlow;

@interface ABModal : UIView

@property (nonatomic) int type;
@property (nonatomic) UIView *innerView;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) UITextField *textField;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) ABFlow *contentFlow;


- (id) initWithType:(NSInteger)type andMainVC:(ABMainViewController *)mainVC;
- (UITextField *) createTextField;

- (void) updateColor;
- (void) resetScrollViewPosition;

- (void) setTipContentForWelcome;
- (void) setTipContentForGraft;
- (void) setTipContentForSpellMode;
- (void) setTipContentForCadabra;


@end
