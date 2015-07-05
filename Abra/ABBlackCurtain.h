//
//  ABBlackCurtain.h
//  Abra
//
//  Created by Ian Hatcher on 2/22/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABIconBar;
@class ABMainViewController;

@interface ABBlackCurtain : UIView

@property (nonatomic) BOOL destroyOnFadeOut;
@property (nonatomic) BOOL isGraftCurtain;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL ready;
@property (nonatomic) ABIconBar *iconBar;
@property (nonatomic) ABMainViewController *mainVC;

- (id) initWithIconBar:(ABIconBar *)bar andMainVC:(ABMainViewController *)main;
- (void) show;
- (void) hide;
- (void) hideWithSuccess:(BOOL)success;

@end
