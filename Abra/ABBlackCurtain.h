//
//  ABBlackCurtain.h
//  Abra
//
//  Created by Ian Hatcher on 2/22/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABBlackCurtain : UIView

@property BOOL destroyOnFadeOut;

- (id) init;
- (void) show;
- (void) hide;

@end
