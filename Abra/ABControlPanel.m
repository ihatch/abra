//
//  ABControlPanel.m
//  Abra
//
//  Created by Ian Hatcher on 2/15/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABControlPanel.h"
#import "ABConstants.h"
#import "ABState.h"
#import "ABUI.h"
#import "ABInfoView.h"
#import <pop/POP.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation ABControlPanel

@synthesize animationY;

BOOL isOpen, isAnimating;
UIButton *arrowButton;
CGRect panelFrame;
ABMainViewController *mainViewController;
PECropViewController *cropViewController;
ABInfoView *infoView;


UIButton *arrowButton, *mutateButton, *graftButton, *magicButton, *pruneButton, *eraseButton, *autoplayButton, *shareButton, *settingsButton, *helpButton, *currentlySelected;

ABControlPanel *controlPanelInstance;

+ (ABControlPanel *) instance {
    return controlPanelInstance;
}

+ (void) initialize {
    @synchronized(self) {
        if (controlPanelInstance == NULL) controlPanelInstance = [[ABControlPanel alloc] init];
    }
}


- (id) initWithMainVC:(ABMainViewController *)main {
    
    self = [super initWithFrame:panelFrame];
    if (self) {

        mainViewController = main;
        panelFrame = CGRectMake(-1, [self iPadToUniversalH:-67], [self iPadToUniversalW:1026], [self iPadToUniversalH:66]);

        self.alpha = 1;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        self.hidden = YES;
        
        [self initButtons];
        
        // Avoids a peculiar bug
        [self close];
    }

    return self;
}


- (CGFloat) iPadToUniversalW:(CGFloat)n {
    return kScreenWidth / (1024 / n);
}

- (CGFloat) iPadToUniversalH:(CGFloat)n {
    return kScreenHeight / (768 / n);
}


- (void) initButtons {
    
    int y = [ABUI iPadToUniversalH:20];
    int h = [ABUI iPadToUniversalH:30];
    
    
    
    CGFloat x1 = [self iPadToUniversalW:50];
    CGFloat w1 = [self iPadToUniversalW:90];

    CGFloat x2 = [self iPadToUniversalW:145];
    CGFloat w2 = [self iPadToUniversalW:80];
    
    CGFloat x3 = [self iPadToUniversalW:230];
    CGFloat w3 = [self iPadToUniversalW:80];
    
    CGFloat x4 = [self iPadToUniversalW:315];
    CGFloat w4 = [self iPadToUniversalW:80];
    
    CGFloat x5 = [self iPadToUniversalW:400];
    CGFloat w5 = [self iPadToUniversalW:100];
    
    CGFloat x7 = [self iPadToUniversalW:720];
    CGFloat w7 = [self iPadToUniversalW:90];

    CGFloat x8 = [self iPadToUniversalW:810];
    CGFloat w8 = [self iPadToUniversalW:95];
    
    CGFloat x9 = [self iPadToUniversalW:910];
    CGFloat w9 = [self iPadToUniversalW:70];
    
    
    mutateButton = [self controlButtonWithText:@"🌀 mutate" andFrame:CGRectMake(x1, y, w1, h) andAddToView:YES];
    [mutateButton addTarget:self action:@selector(selectMutate) forControlEvents:UIControlEventTouchUpInside];
    [mutateButton setSelected:YES];
    currentlySelected = mutateButton;
    
    graftButton = [self controlButtonWithText:@"🌱 graft" andFrame:CGRectMake(x2, y, w2, h) andAddToView:YES];
    [graftButton addTarget:self action:@selector(selectGraft) forControlEvents:UIControlEventTouchUpInside];
    
    pruneButton = [self controlButtonWithText:@"🍃 prune" andFrame:CGRectMake(x3, y, w3, h) andAddToView:YES];
    [pruneButton addTarget:self action:@selector(selectPrune) forControlEvents:UIControlEventTouchUpInside];
    
    eraseButton = [self controlButtonWithText:@"🍂 erase" andFrame:CGRectMake(x4, y, w4, h) andAddToView:YES];
    [eraseButton addTarget:self action:@selector(selectErase) forControlEvents:UIControlEventTouchUpInside];
    
    magicButton = [self controlButtonWithText:@"✨ cadabra" andFrame:CGRectMake(x5, y, w5, h) andAddToView:YES];
    [magicButton addTarget:self action:@selector(selectMagic) forControlEvents:UIControlEventTouchUpInside];
    
    shareButton = [self controlButtonWithText:@"🎁 share" andFrame:CGRectMake(x7, y, w7, h) andAddToView:YES];
    [shareButton addTarget:self action:@selector(selectShare) forControlEvents:UIControlEventTouchUpInside]; // 🚀📷📡

    settingsButton = [self controlButtonWithText:@"🌰 settings" andFrame:CGRectMake(x8, y, w8, h) andAddToView:YES];
    [settingsButton addTarget:self action:@selector(selectSettings) forControlEvents:UIControlEventTouchUpInside]; // 🔩🎁🔩🎒🍎📦🌰
    
    helpButton = [self controlButtonWithText:@"🔮 info" andFrame:CGRectMake(x9, y, w9, h) andAddToView:YES];
    [helpButton addTarget:self action:@selector(selectInfo) forControlEvents:UIControlEventTouchUpInside];
}








- (void) selectModeWithButton:(UIButton *)button {
    if(currentlySelected) [currentlySelected setSelected:NO];
    [button setSelected:YES];
    [button setHighlighted:YES];
    currentlySelected = button;
}

- (void) selectMutate {
    [self selectModeWithButton:mutateButton];
    [ABState setInteractivityModeTo:MUTATE];
}

- (void) selectGraft {
    [self selectModeWithButton:graftButton];
    [ABState setInteractivityModeTo:GRAFT];
    [mainViewController showGraftModal];
}

- (void) selectPrune {
    [self selectModeWithButton:pruneButton];
    [ABState setInteractivityModeTo:PRUNE];
}

- (void) selectErase {
    [self selectModeWithButton:eraseButton];
    [ABState setInteractivityModeTo:ERASE];
}

- (void) selectMagic {
    // TODO
}

- (void) selectSettings {
    // TODO
}

- (void) selectInfo {
    [mainViewController showInfoView];
}










- (UIButton *) controlButtonWithText:(NSString *)text andFrame:(CGRect)frame andAddToView:(BOOL)addToView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[ABUI darkGoldColor] forState:UIControlStateNormal];
    [button setTitleColor:[ABUI darkGoldColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[ABUI goldColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:(kScreenWidth / 73.14)];  // 14.0f
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[ABUI imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[ABUI imageWithColor:[ABUI darkGoldBackgroundColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[ABUI imageWithColor:[ABUI darkGoldBackgroundColor]] forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    button.layer.cornerRadius = [self iPadToUniversalH:10];
    button.clipsToBounds = YES;
    if(addToView) [self addSubview:button];
    return button;
}





- (void) openOrClose {
    if(isAnimating) return;
    if(!isOpen) [self open]; else [self close];
}

- (void) open {
    isAnimating = YES;
    self.hidden = NO;
    [self.layer setBorderColor:[ABUI progressHueColor].CGColor];
    [self moveArrowButtonDown];
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.frame = CGRectMake(panelFrame.origin.x, panelFrame.origin.y + [ABUI iPadToUniversalH:65], panelFrame.size.width, panelFrame.size.height);
    } completion:^(BOOL finished) {
        isOpen = YES;
        isAnimating = NO;
    }];
}

- (void) close {
    isAnimating = YES;
    [self moveArrowButtonUp];
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.frame = panelFrame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        isOpen = NO;
        isAnimating = NO;
    }];
}








/////////////////////////
// CONTROL PANEL ARROW //
/////////////////////////

- (UIButton *) createArrowButton {
    
    CGFloat x = kScreenWidth / 1.066;
    CGFloat y = 10;
    CGFloat d = kScreenWidth / 19.32;
    
    arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowButton.frame = CGRectMake(x, y, d, d);
    
    arrowButton.tintColor = [ABUI goldColor];
    arrowButton.alpha = 0.5;
    [arrowButton setImage:[UIImage imageNamed:@"ui_down_arrow.png"] forState:UIControlStateNormal];
    CGFloat m = kScreenWidth / 68.26666666666667;
    [arrowButton setImageEdgeInsets:UIEdgeInsetsMake(m, m, m, m)];
    
    return arrowButton;
}

- (void) movePanelTriggerWithDirection:(int)direction {
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:.5f];
    if(CGAffineTransformEqualToTransform(arrowButton.imageView.transform, CGAffineTransformIdentity))
        arrowButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    else arrowButton.imageView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    CGRect frame = arrowButton.frame;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        arrowButton.frame = CGRectMake(frame.origin.x, frame.origin.y + (direction * [ABUI iPadToUniversalH:65]), frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {}];
}

- (void) moveArrowButtonDown {
    [self movePanelTriggerWithDirection:1];
}

- (void) moveArrowButtonUp {
    [self movePanelTriggerWithDirection:-1];
}









///////////
// SHARE //
///////////


- (void) selectShare {
    
    [arrowButton setHidden:YES];
    [self setHidden:YES];
    
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
//        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
//    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    
    //    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // CGRect mainBounds = mainViewController.view.bounds;
    CGRect cropBounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [mainViewController.view drawViewHierarchyInRect:cropBounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [arrowButton setHidden:NO];
    [self setHidden:NO];
    
    cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = self;
    cropViewController.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [mainViewController presentViewController:navigationController animated:YES completion:nil];
    
}


- (UIImage *) cropImage:(UIImage *)image rect:(CGRect)cropRect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}


- (void) SavePhotoOnClick {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else UIGraphicsBeginImageContext(self.window.bounds.size);
    
    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = self;
    cropViewController.image = image;
    //controller.image = self.imageView.image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [mainViewController presentViewController:navigationController animated:YES completion:nil];
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}



- (void) cropViewControllerDidCancel:(PECropViewController *)controller {
    [cropViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void) cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    [cropViewController dismissViewControllerAnimated:YES completion:NULL];
}






@end
