//
//  ABBlackCurtain.h
//  Abra
//
//  Created by Ian Hatcher on 2/22/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABIconBar;


@interface ABBlackCurtain : UIView

@property BOOL destroyOnFadeOut;
@property BOOL setToMutateOnCancel;

- (id) initWithIconBar:(ABIconBar *)bar;
- (void) show;
- (void) hide;
- (void) hideWithSuccess:(BOOL)success;

@end
