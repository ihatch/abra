//
//  abraViewController.m
//  Abra
//
//  Created by Ian Hatcher on 12/1/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABMainViewController.h"
#import "ABConstants.h"
#import "ABState.h"
#import "ABScript.h"
#import "ABClock.h"
#import "ABLine.h"
#import "ABData.h"
#import "ABUI.h"
#import "ABModal.h"
#import "ABGestureArrow.h"
#import "ABBlackCurtain.h"
#import "ABIconBar.h"
#import "ABCadabra.h"
#import "iCarousel.h"
#import "PECropViewController.h"
#import "emojis.h"

@interface ABMainViewController () <iCarouselDataSource, iCarouselDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UINavigationItem *navItem;

@end


@implementation ABMainViewController

NSMutableArray *ABLines;
ABGestureArrow *feedbackForward, *feedbackBackward, *feedbackReset;

ABIconBar *iconBar;
ABBlackCurtain *graftCurtain, *settingsCurtain, *infoCurtain;
ABBlackCurtain *tipCurtain;
ABModal *graftModal, *settingsModal, *infoModal;
ABModal *welcomeTip, *graftTip, *cadabraTip, *spellModeTip;
UITextField *graftTextField;
NSString *currentTip;

BOOL carouselIsAnimating, preventInput;
CGPoint touchStart;



- (void) viewDidLoad {
    [super viewDidLoad];

    [self initScreen];
    [ABData initData];
    [self initLines];
    [self initGestures];
    [self initInfoView];
    [self initSettingsModal];
    [self initGraftModal];
    [self initIconBar];
    [self initCarousel];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showTip:@"welcome"];
    });
}





- (void) initScreen {
    DDLogInfo(@"Screen: %f x %f", kScreenWidth, kScreenHeight);
    self.view.backgroundColor = [UIColor blackColor];
    self.view.userInteractionEnabled = YES;
}


- (void) initLines {
    ABLines = [ABState initLines];
    for(ABLine *line in ABLines) [self.view addSubview:line];
}


- (void) initIconBar {
    iconBar = [[ABIconBar alloc] initWithMainVC:self];
    [self.view addSubview:iconBar];
}





///////////////////////////
// NAVIGATION / GESTURES //
///////////////////////////

- (void) initGestures {

    preventInput = NO;
    
    feedbackForward = [[ABGestureArrow alloc] initWithType:@"forward"];
    feedbackBackward = [[ABGestureArrow alloc] initWithType:@"backward"];
    feedbackReset = [[ABGestureArrow alloc] initWithType:@"reset"];
    
    [self.view addSubview:feedbackForward];
    [self.view addSubview:feedbackBackward];
    [self.view addSubview:feedbackReset];

    
    // Double tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];

    // Tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [tap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:tap];

    // Left swipe
    UIScreenEdgePanGestureRecognizer *leftEdge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdgeSwipe:)];
    leftEdge.edges = UIRectEdgeLeft;
    leftEdge.delegate = self;
    [self.view addGestureRecognizer:leftEdge];

    // Right swipe
    UIScreenEdgePanGestureRecognizer *rightEdge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdgeSwipe:)];
    rightEdge.edges = UIRectEdgeRight;
    rightEdge.delegate = self;
    [self.view addGestureRecognizer:rightEdge];

    // Long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];
    
    // Rotate
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [self.view addGestureRecognizer:rotate];
    
    // Pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    
    // Flash prev/next
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prevNextFeedbackFlash) name:@"prevNextFeedbackFlash" object:nil];


}


- (ABLine *) checkLinesForPoint:(CGPoint) point {
    for(int i=0; i<[ABLines count]; i++) {
        ABLine *line = [ABLines objectAtIndex:i];
        if(CGRectContainsPoint(line.frame, point)) {
            [ABClock updateLastInteractionTime];
            return line;
        }
    }
    return nil;
}

- (void) pan:(UIPanGestureRecognizer *)gesture {
    if(preventInput) return;
    CGPoint point = [gesture locationInView:self.view];
    ABLine *line = [self checkLinesForPoint:point];
    if(line == nil) return;
    [line touch:[self.view convertPoint:point toView:line]];
}


- (IBAction) tap:(UITapGestureRecognizer *)gesture {
    if(preventInput) return;
    CGPoint point = [gesture locationInView:self.view];
    ABLine *line = [self checkLinesForPoint:point];
    if(line == nil) return;
    [line tap:[self.view convertPoint:point toView:line]];
}

- (IBAction) doubleTap:(UITapGestureRecognizer *)gesture {
    if(preventInput) return;
    CGPoint point = [gesture locationInView:self.view];
    ABLine *line = [self checkLinesForPoint:point];
    if(line == nil) return;
    [line doubleTap:[self.view convertPoint:point toView:line]];
}

- (IBAction) rotate:(UIRotationGestureRecognizer *)gesture {
    if(preventInput) return;
    [ABClock updateLastInteractionTime];
    if(gesture.state == UIGestureRecognizerStateEnded) {
        if(gesture.rotation > 0.3 || gesture.rotation < -0.3 ) {
            [feedbackReset flash];
            [ABState clearMutations];
        }
    }
}


- (IBAction) longPress:(UILongPressGestureRecognizer *)gesture {
    
    if(preventInput) return;
    [ABClock updateLastInteractionTime];
    if(gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.view];
        ABLine *line = [self checkLinesForPoint:point];
        if(line == nil) return;
        [line longPress:[self.view convertPoint:point toView:line]];
    }
}


- (void) turnPage:(int)direction {
    [self.carousel scrollByNumberOfItems:direction duration:1.4f];
    [self carouselFlash];
    if(direction == -1) [feedbackBackward flash];
    if(direction == 1) [feedbackForward flash];
    [ABState turnPage:direction];
}

- (void) edgeSwipeCheckWithGesture:(UIScreenEdgePanGestureRecognizer *)gesture andDirection:(int)direction {
    if(preventInput) return;
    if(gesture.state == UIGestureRecognizerStateBegan) {
        touchStart = [gesture locationInView:self.view];
        
    } else if(gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint touchEnd = [gesture locationInView:self.view];
        CGFloat xDist = (touchEnd.x - touchStart.x);
        CGFloat yDist = (touchEnd.y - touchStart.y);
        if(yDist < 100 && ((xDist < -40 && direction == 1) || (xDist > 40 && direction == -1))) {
            if(carouselIsAnimating) return;
            [ABClock updateLastInteractionTime];
            [self turnPage:direction];
        }
    }
}

- (IBAction) leftEdgeSwipe:(UIScreenEdgePanGestureRecognizer *)gesture {
    [self edgeSwipeCheckWithGesture:gesture andDirection:-1];
}

- (IBAction) rightEdgeSwipe:(UIScreenEdgePanGestureRecognizer *)gesture {
    [self edgeSwipeCheckWithGesture:gesture andDirection:1];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) prevNextFeedbackFlash {
    [feedbackBackward flash];
    [feedbackForward flash];
}





///////////////////////
// MODALS / CONTROLS //
///////////////////////



- (void) blackCurtainDidDisappear {

    [ABState resume];

    if([ABState checkForChangedDisplayMode] == YES) {
        ABLines = [ABState initLines];
        for(int i=0; i < [ABLines count]; i ++) [self.view addSubview:ABLines[i]];
        [self performSelector:@selector(allowGestures) withObject:self afterDelay:2];
    } else {
        [self allowGestures];
    }
    
    if(currentTip != nil) {
        if([currentTip isEqualToString:@"graft"]) [self showGraftModal];
        if([currentTip isEqualToString:@"cadabra"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerCadabra" object:self];
            [ABCadabra castSpell:nil withMagicWord:nil];
        }
        currentTip = nil;
    }
}


- (void) allowGestures {
    [ABState allowGestures];
    preventInput = NO;
}



// GRAFT

- (void) initGraftModal {
    graftModal = [[ABModal alloc] initWithType:GRAFT_MODAL andMainVC:self];
    graftTextField = [graftModal createTextField];
    graftTextField.delegate = self;
    [graftModal.innerView addSubview:graftTextField];
    graftCurtain = [[ABBlackCurtain alloc] initWithIconBar:iconBar andMainVC:self];
    graftCurtain.destroyOnFadeOut = NO;
    graftCurtain.isGraftCurtain = YES;
    [graftCurtain addSubview:graftModal];
    [self.view addSubview:graftCurtain];
}

- (void) pressedGraftButton {
    if([ABState shouldShowTip:@"graft"] == 0) {
        [self showGraftModal];
    } else {
        [self showTip:@"graft"];
    }
}


- (void) showGraftModal {
    preventInput = YES;
    [graftModal updateColor];
    [graftCurtain show];
    [graftTextField becomeFirstResponder];
}

- (BOOL) userDidTouchOutsideGraftBox {
    return [self textFieldShouldReturn:graftTextField];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [graftTextField resignFirstResponder];
    BOOL successfulGraft = [ABData graftText:graftTextField.text];
    if(successfulGraft == NO) [iconBar selectMutate];
    [graftCurtain hideWithSuccess:successfulGraft];
    preventInput = NO;
    return YES;
}




// SETTINGS

- (void) initSettingsModal {
    ABModal *modal = [[ABModal alloc] initWithType:SETTINGS_MODAL andMainVC:self];
    ABBlackCurtain *curtain = [[ABBlackCurtain alloc] initWithIconBar:iconBar andMainVC:self];
    curtain.destroyOnFadeOut = NO;
    [curtain addSubview:modal];
    [self.view addSubview:curtain];
    settingsCurtain = curtain;
    settingsModal = modal;
}

- (void) showSettingsModal {
    preventInput = YES;
    [settingsModal updateColor];
    [settingsCurtain show];
}




// INFO

- (void) initInfoView {
    infoModal = [[ABModal alloc] initWithType:INFO_MODAL andMainVC:self];
    ABBlackCurtain *curtain = [[ABBlackCurtain alloc] initWithIconBar:iconBar andMainVC:self];
    curtain.destroyOnFadeOut = NO;
    [curtain addSubview:infoModal];
    [self.view addSubview:curtain];
    infoCurtain = curtain;
}

- (void) showInfoView {
    preventInput = YES;
    [infoModal resetScrollViewPosition];
    [infoModal updateColor];
    [infoCurtain show];
}





// TIPS

- (void) showTip:(NSString *)tip {
    
    if(![ABState shouldShowTip:tip]) return;
    [ABState toggleTip:tip];
    currentTip = tip;

    [ABState pause];
    preventInput = YES;
    
    ABModal *tipModal = [[ABModal alloc] initWithType:TIP_MODAL andMainVC:self];
    if([tip isEqualToString:@"welcome"]) [tipModal setTipContentForWelcome];
    if([tip isEqualToString:@"mode"]) [tipModal setTipContentForSpellMode];
    if([tip isEqualToString:@"graft"]) [tipModal setTipContentForGraft];
    if([tip isEqualToString:@"cadabra"]) [tipModal setTipContentForCadabra];
    
    ABBlackCurtain *curtain = [[ABBlackCurtain alloc] initWithIconBar:iconBar andMainVC:self];
    curtain.destroyOnFadeOut = YES;
    [curtain addSubview:tipModal];
    [self.view addSubview:curtain];
    tipCurtain = curtain;
    
    [tipCurtain show];
}











//////////////
// CAROUSEL //
//////////////


- (void) dealloc {
    self.carousel.delegate = nil;
    self.carousel.dataSource = nil;
}

- (void) viewDidUnload {
    [super viewDidUnload];
    self.carousel = nil;
    self.navItem = nil;
}

- (void) initCarousel {

    CGFloat carouselWidth = kScreenWidth / 1.64;
    CGFloat carouselHeight = kScreenHeight / 6.4;
    CGFloat carouselX = (kScreenWidth - carouselWidth) / 2;
    CGFloat carouselY = kScreenHeight - carouselHeight - (kScreenHeight / 36);

    self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(carouselX, carouselY, carouselWidth, carouselHeight)];
    self.carousel.type = iCarouselTypeRotary;
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.alpha = 0.0;
    self.carousel.scrollSpeed = 0.15;
    self.carousel.clipsToBounds = NO;

    [self.view addSubview:_carousel];
    [self.view bringSubviewToFront:_carousel];

    carouselIsAnimating = NO;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:7.5];
    [self.carousel setAlpha:0.8];
    [UIView commitAnimations];
}

- (NSInteger) numberOfItemsInCarousel:(iCarousel *)carousel {
    return [ABScript totalStanzasCount];
}

- (UIView *) carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = nil;

    if (view == nil) {
        // create new view if no view is available for recycling
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 20.48, kScreenHeight / 7.68)];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.tag = 1;
        [view addSubview:label];
    } else {
        // get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    // remember to always set any properties of your carousel item views outside of the `if (view == nil) {...}`
    // check or you'll get weird issues with item content appearing in the wrong place
    label.backgroundColor = [UIColor clearColor];
    int intindex = (int)index;
    label.textColor = [ABUI progressHueColorForStanza:intindex];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:ABRA_FLOWERS_FONT size:(kScreenWidth / 34.13)];
    label.text = @"Q";
    
    return view;
}

- (CATransform3D) carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat) carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap: { return YES; }
        case iCarouselOptionShowBackfaces: { return NO; }
        case iCarouselOptionSpacing: { return value * 1.21f; }
        case iCarouselOptionFadeMin: { return -0.1f; }
        case iCarouselOptionFadeMax: { return 0.35f; }
        case iCarouselOptionFadeRange: { return 1.01f; }
        case iCarouselOptionFadeMinAlpha: { return 0.26f; }
        default: { return value; }
    }
}

- (void) carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    [ABState manuallyTransitionStanzaToNumber:(int)carousel.currentItemIndex];
    [self performSelector:@selector(carouselDoneAnimating) withObject:self afterDelay:0.2];
}

- (void) carouselDoneAnimating {
    carouselIsAnimating = NO;
}

- (void) carouselWillBeginScrollingAnimation:(iCarousel *)carousel {
    carouselIsAnimating = YES;
}

- (void) carouselWillBeginDragging:(iCarousel *)carousel {
    carouselIsAnimating = YES;
    [ABClock updateLastInteractionTime];
}

- (void) carouselFlash {
    [UIView animateWithDuration:0.4 animations:^() {
        _carousel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.64 animations:^() {
            _carousel.alpha = 0.75;
        } completion:^(BOOL finished) {}];
    }];
}









- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


