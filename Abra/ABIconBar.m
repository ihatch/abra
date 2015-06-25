//
//  ABIconBar.m
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABIconBar.h"
#import "ABConstants.h"
#import "ABIcon.h"
#import "ABUI.h"
#import "ABState.h"
#import "ABCadabra.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation ABIconBar

ABMainViewController *mainViewController;
PECropViewController *cropViewController;

CGFloat barWidth, barHeight;
CGFloat iconWidth, iconHeight, iconBufferWidth, totalIconsWidth, currentXDrawPos;

ABIcon *mutateIcon, *graftIcon, *pruneIcon, *eraseIcon, *cadabraIcon, *shareIcon, *settingsIcon, *infoIcon, *flowerIcon;
ABIcon *currentModeIcon;

NSArray *icons;


- (id) initWithMainVC:(ABMainViewController *)main {
    
    barWidth = kScreenWidth;
    barHeight = [ABUI scaleYWithIphone:45 ipad:75];
    
    self = [super initWithFrame:CGRectMake(0, [ABUI scaleXWithIphone:0 ipad:15], barWidth, barHeight)];
    if (self) {
        
        mainViewController = main;
        
        self.alpha = 1;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        
        [self initIcons];
        
    }
    
    return self;
}


- (CGFloat) xPos:(CGFloat)w {
    CGFloat x = currentXDrawPos;
    currentXDrawPos += w;
    return x;
}

- (CGRect) iconFrame {
    return CGRectMake([self xPos:iconWidth], 0, iconWidth, iconHeight);
}


- (void) initIcons {
    
    self.isVisible = NO;
    
    iconWidth = [ABUI scaleXWithIphone:45 ipad:70];
    iconHeight = barHeight;
    
    iconBufferWidth = 40 + ((kScreenWidth - 568) / 7.5);
    totalIconsWidth = (iconWidth * 9) + (iconBufferWidth * 2);
    
    currentXDrawPos = (barWidth - totalIconsWidth) / 2;
    currentXDrawPos -= 2; // hack -- why the off-center??
    
    mutateIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"MUTATE" symbol:@"🌀" iconType:MUTATE_ICON];
    graftIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"GRAFT" symbol:@"🌱" iconType:GRAFT_ICON];
    pruneIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"PRUNE" symbol:@"🍃" iconType:PRUNE_ICON];
    eraseIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"ERASE" symbol:@"🍂" iconType:ERASE_ICON];

    [self xPos:iconBufferWidth];

    cadabraIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"CADABRA" symbol:@"✨" iconType:CADABRA_ICON];

    [self xPos:iconBufferWidth];
 
    shareIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"SHARE" symbol:@"🎁" iconType:SHARE_ICON];
    settingsIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"SETTINGS" symbol:@"🌰" iconType:SETTINGS_ICON];
    infoIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"INFO" symbol:@"🔮" iconType:INFO_ICON];
    flowerIcon = [[ABIcon alloc] initWithFrame:[self iconFrame] text:@"" symbol:@"L" iconType:FLOWER_ICON];
    
    
    icons = @[mutateIcon, graftIcon, pruneIcon, eraseIcon, cadabraIcon, shareIcon, settingsIcon, infoIcon, flowerIcon];

    [mutateIcon setIsSelected:YES];
    currentModeIcon = mutateIcon;
    
    for(ABIcon *icon in icons) {
        [icon hideInstantly];
        [self addSubview:icon];
    }

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];

    self.hidden = NO;
}




- (IBAction) tap:(UITapGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView:self];
    int target = [self checkPoint:point];
    ABIcon *icon = target > -1 ? [icons objectAtIndex:target] : nil;

    DDLogInfo(@"Target: %i", target);
    
    if(icon == nil || self.isVisible == NO) {
        
        if(currentModeIcon && currentModeIcon == icon && icon.iconType == GRAFT_ICON) {
            [self triggerGraft];
            return;
        }
        
        [self showIcons];
        return;
    }
    
    iconType type = icon.iconType;
    

    if(type == FLOWER_ICON && self.isVisible == YES) {
        [self hideIcons];
        return;
    }


    if(type == CADABRA_ICON) {
        [icon flash];
        [ABCadabra castSpell];
        return;
    }

    
    if(type == SHARE_ICON) {
        [icon flash];
        [self hideBarThenShare];
        return;
    }
    
    
    if(type == SETTINGS_ICON) {
        [icon flash];
        [mainViewController showSettingsModal];
        return;
    }

    
    if(type == INFO_ICON) {
        [icon flash];
        [mainViewController showInfoView];
        return;
    }
    
    
    if(type == MUTATE_ICON || type == GRAFT_ICON || type == PRUNE_ICON || type == ERASE_ICON) {
        
        if(currentModeIcon && currentModeIcon == icon) {
            if(type == GRAFT_ICON) [self triggerGraft];
            else return;
        }
        if(currentModeIcon && currentModeIcon == icon) return;
        if(currentModeIcon) [currentModeIcon lowlight];
        
        [icon highlight];
        
        if(type == MUTATE_ICON) [ABState setInteractivityModeTo:MUTATE];
        if(type == PRUNE_ICON) [ABState setInteractivityModeTo:PRUNE];
        if(type == ERASE_ICON) [ABState setInteractivityModeTo:ERASE];
        if(type == GRAFT_ICON) [self triggerGraft];
        
        currentModeIcon = icon;
    }
}


- (void) triggerGraft {
    [ABState setInteractivityModeTo:GRAFT];
    [mainViewController showGraftModal];
}


- (void) selectMutate {
    if(currentModeIcon && currentModeIcon != mutateIcon) [currentModeIcon lowlight];
    currentModeIcon = mutateIcon;
    [mutateIcon highlight];
    [ABState setInteractivityModeTo:MUTATE];

}



- (void) showIcons {
    for(ABIcon *icon in icons) [icon show];
    self.isVisible = YES;
}

- (void) hideIcons {
    for(ABIcon *icon in icons) [icon hide];
    self.isVisible = NO;
}


- (void) hideBarThenShare {
    [UIView animateWithDuration:0.6 delay:0.4 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.isAnimating = YES;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self share];
        [self hideIcons];
        self.isVisible = NO;
    }];
}

- (void) showBarAfterShare {
    [UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}





- (int) checkPoint:(CGPoint)point {
    
    int target = -1;
    
    for(int i=0; i<[icons count]; i++) {
        ABIcon *icon = [icons objectAtIndex:i];
        if(CGRectContainsPoint(icon.frame, point)) {
            target = i;
            break;
        }
    }
    
    if(target > -1) {
//        ABIcon *targetIcon = [icons objectAtIndex:target];
        // if(targetWord.locked) target = -1;
    }
    
    return target;
}













///////////
// SHARE //
///////////


- (void) share {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    
    //    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // CGRect mainBounds = mainViewController.view.bounds;
    CGRect cropBounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [mainViewController.view drawViewHierarchyInRect:cropBounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setHidden:NO];
    
    cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = self;
    cropViewController.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [mainViewController presentViewController:navigationController animated:YES completion:^(void) {
        [self showBarAfterShare];
    }];
    
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
