//
//  ABModal.h
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABMainViewController;
// typedef NS_ENUM(NSInteger, modalType) { GRAFT_MODAL, SETTINGS_MODAL, INFO_MODAL };


@interface ABModal : UIView

@property (nonatomic) int type;
@property (nonatomic) UIView *innerView;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) UITextField *textField;
@property (nonatomic) UIScrollView *scrollView;


- (id) initWithType:(NSInteger)type andMainVC:(ABMainViewController *)mainVC;
- (UITextField *) createTextField;

- (void) updateColor;
- (void) resetScrollViewPosition;

@end
