//
//  ABControlPanel.h
//  Abra
//
//  Created by Ian Hatcher on 2/15/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PECropViewController.h"
#import "ABMainViewController.h"

@class POPBasicAnimation;

@interface ABControlPanel : UIView <PECropViewControllerDelegate>

- (id) initWithMainView:(ABMainViewController *)main;
- (void) triggerWithButton:(UIButton *)button;
- (void) open;
- (void) close;

- (void) setModeToMutate;

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) POPBasicAnimation *animationY;


@end
