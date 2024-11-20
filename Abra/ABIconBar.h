//
//  ABIconBar.h
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PECropViewController.h"
#import "ABMainViewController.h"

@interface ABIconBar : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isAnimating;

- (id) initWithMainVC:(ABMainViewController *)main;
- (void) selectMutate;
    
@end
