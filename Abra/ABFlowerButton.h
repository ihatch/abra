//
//  ABFlowerBed.h
//  Abra
//
//  Created by Ian Hatcher on 2/8/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABFlowerButton : UILabel

@property (nonatomic) UILabel *flowers1;
@property (nonatomic) UILabel *flowers2;

@property (nonatomic) UILabel *playButton;
@property (nonatomic) UILabel *graftButton;

- (void) flash;
- (void) show;
- (void) hide;

@end
