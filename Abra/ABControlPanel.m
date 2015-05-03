//
//  ABControlPanel.m
//  Abra
//
//  Created by Ian Hatcher on 2/15/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABControlPanel.h"
#import "ABState.h"
#import "ABUI.h"
#import <pop/POP.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>


// #import <QuartzCore/QuartzCore.h>

@implementation ABControlPanel

@synthesize animationY;

BOOL isOpen, isAnimating;
UIButton *barTriggerButton;
CGRect panelFrame;
ABMainViewController *mainViewController;
PECropViewController *cropViewController;

UIButton *mutateButton, *graftButton, *multiplyButton, *pruneButton, *eraseButton, *autoplayButton, *shareButton, *settingsButton, *helpButton, *currentlySelected;

- (id) initWithMainView:(ABMainViewController *)main {
    
    mainViewController = main;
    panelFrame = CGRectMake(-1, -67, 1026, 66);

    self = [super initWithFrame:panelFrame];
    if (self) {
        self.alpha = 1;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        self.hidden = NO;
        [self initButtons];
    }
    return self;
}


- (void) initButtons {
    
    int y = 20, h = 30;
    
    mutateButton = [self controlButtonWithText:@"🌀 mutate" andFrame:CGRectMake(50, y, 90, h)];
    [mutateButton addTarget:self action:@selector(mutateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [mutateButton setSelected:YES];
    currentlySelected = mutateButton;
    
    graftButton = [self controlButtonWithText:@"🌱 graft" andFrame:CGRectMake(140, y, 80, h)];
    [graftButton addTarget:self action:@selector(graftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    multiplyButton = [self controlButtonWithText:@"🌾 multiply" andFrame:CGRectMake(220, y, 100, h)];
    [multiplyButton addTarget:self action:@selector(multiplyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    pruneButton = [self controlButtonWithText:@"🍃 prune" andFrame:CGRectMake(320, y, 80, h)];
    [pruneButton addTarget:self action:@selector(pruneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    eraseButton = [self controlButtonWithText:@"🍂 erase" andFrame:CGRectMake(400, y, 80, h)];
    [eraseButton addTarget:self action:@selector(eraseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    shareButton = [self controlButtonWithText:@"🚀 share" andFrame:CGRectMake(600, y, 90, h)];
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    autoplayButton = [self controlButtonWithText:@"🌿 autoplay" andFrame:CGRectMake(700, y, 105, h)];
    [autoplayButton addTarget:self action:@selector(autoplayButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    settingsButton = [self controlButtonWithText:@"🎁 settings" andFrame:CGRectMake(815, y, 105, h)];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    helpButton = [self controlButtonWithText:@"✨ info" andFrame:CGRectMake(920, y, 60, h)];
    [helpButton addTarget:self action:@selector(infoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}


- (void) setModeToMutate {
    [self mutateButtonPressed];
}

- (void) selectModeWithButton:(UIButton *)button {
    if(currentlySelected) {
        [currentlySelected setSelected:NO];
//        [currentlySelected setHighlighted:NO];
    }
    [button setSelected:YES];
    [button setHighlighted:YES];
    currentlySelected = button;
}

- (void) mutateButtonPressed {
    [self selectModeWithButton:mutateButton];
    [ABState setInteractivityModeTo:MUTATE];
}

- (void) graftButtonPressed {
    [self selectModeWithButton:graftButton];
    [ABState setInteractivityModeTo:GRAFT];
    [mainViewController textFieldModal];
}

- (void) multiplyButtonPressed {
    [self selectModeWithButton:multiplyButton];
    [ABState setInteractivityModeTo:MULTIPLY];
}

- (void) pruneButtonPressed {
    [self selectModeWithButton:pruneButton];
    [ABState setInteractivityModeTo:PRUNE];
}

- (void) eraseButtonPressed {
    [self selectModeWithButton:eraseButton];
    [ABState setInteractivityModeTo:ERASE];
}



- (void) autoplayButtonPressed {

    if(autoplayButton.isSelected) {
        [autoplayButton setSelected:NO];
    } else {
        [autoplayButton setSelected:YES];
    }
    
}

- (void) shareButtonPressed {
    
    [barTriggerButton setHidden:YES];
    [self setHidden:YES];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    
//    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    [mainViewController.view drawViewHierarchyInRect:mainViewController.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [barTriggerButton setHidden:NO];
    [self setHidden:NO];
    
    cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = self;
    cropViewController.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [mainViewController presentViewController:navigationController animated:YES completion:nil];
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

}




- (void) settingsButtonPressed {
}

- (void) infoButtonPressed {
}


-(UIImage *)cropImage:(UIImage *)image rect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}


- (void)SavePhotoOnClick {

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    
    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    NSData * data = UIImagePNGRepresentation(image);
//    [data writeToFile:@"foo.png" atomically:YES];
    
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
//    UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
}








- (UIButton *) controlButtonWithText:(NSString *)text andFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[ABUI darkGoldColor] forState:UIControlStateNormal];
    [button setTitleColor:[ABUI darkGoldColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[ABUI goldColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:14.0f];
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:[ABUI darkGoldBackgroundColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self imageWithColor:[ABUI darkGoldBackgroundColor]] forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;

    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    [self addSubview:button];
    return button;
}



- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}





- (void) triggerWithButton:(UIButton *)button {
    barTriggerButton = button;
    if(isAnimating) return;
    if(!isOpen) {
        [self open];
    } else {
        [self close];
    }
}


- (void) open {
    
    NSLog(@"%@", @"open control");
    isAnimating = YES;
    
    [self.layer setBorderColor:[ABUI progressHueColor].CGColor];
    [ABUI moveInfoButtonDown];

    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.frame = CGRectMake(panelFrame.origin.x, panelFrame.origin.y + 65, panelFrame.size.width, panelFrame.size.height);
    } completion:^(BOOL finished) {
        isOpen = YES;
        isAnimating = NO;
    }];
}


- (void) close {
    
    NSLog(@"%@", @"close control");
    isAnimating = YES;

    [ABUI moveInfoButtonUp];

    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.frame = panelFrame;
    } completion:^(BOOL finished) {
        isOpen = NO;
        isAnimating = NO;
    }];
    
}



@end
