//
//  ABInfoView.h
//  Abra
//
//  Created by Ian Hatcher on 5/25/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABMainViewController.h"

@class ABControlPanel;

@interface ABInfoView : UIView

- (id) initWithMainViewReference:(UIView *)mainView andControlPanelReference:(ABControlPanel *)cPanel;


@end
