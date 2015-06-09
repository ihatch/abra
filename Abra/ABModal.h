//
//  ABModal.h
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABMainViewController;


@interface ABModal : UIView

@property (nonatomic) NSString *type;
@property (nonatomic) UIView *innerView;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) UITextField *textField;


- (id) initWithType:(NSString *)type andMainVC:(ABMainViewController *)mainVC;
- (UITextField *) createTextField;

- (void) updateColor;

@end
