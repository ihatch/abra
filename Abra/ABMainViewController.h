//
//  abraViewController.h
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABInfoViewController;

@interface ABMainViewController : UIViewController <UITextFieldDelegate>

@property(strong,nonatomic)ABInfoViewController *infoViewController;

- (void) textFieldModal;

@end
