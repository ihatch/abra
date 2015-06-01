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
#import "ABGestureArrow.h"
#import "ABBlackCurtain.h"
#import "ABControlPanel.h"
#import "ABInfoView.h"
#import "iCarousel.h"
#import "PECropViewController.h"
#import "emojis.h"

@interface ABMainViewController () <iCarouselDataSource, iCarouselDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UINavigationItem *navItem;

@end



@implementation ABMainViewController

CGPoint touchStart;

NSMutableArray *ABLines;
ABGestureArrow *feedbackForward, *feedbackBackward, *feedbackReset;

ABBlackCurtain *graftCurtain, *infoCurtain, *loadingCurtain;

UIButton *controlPanelArrowButton;
ABControlPanel *controlPanel;
ABInfoView *infoView;
UITextField *graftTextField;

BOOL carouselIsAnimating;
ABMainViewController *mainViewControllerInstance;

+ (ABMainViewController *) instance {
    return mainViewControllerInstance;
}

+ (void) initialize {
    @synchronized(self) {
        if (mainViewControllerInstance == NULL) mainViewControllerInstance = [[ABMainViewController alloc] init];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor blackColor];
    self.view.userInteractionEnabled = YES;
    
    [ABData initAbraData];

    NSLog(@"%f screenWidth", kScreenWidth);
    NSLog(@"%f screenHeight", kScreenHeight);
    
    // init lines
    ABLines = [ABState initLines];
    for(int i=0; i < [ABLines count]; i ++) [self.view addSubview:ABLines[i]];

    [self initGestures];
    [self initInfoView];
    [self initGraftModal];
    [self initControlPanel];
    [self initCarousel];

    [self devStartupTests];
}



- (void) devStartupTests {
    
}










///////////////////////////
// NAVIGATION / GESTURES //
///////////////////////////

- (void) initGestures {

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
    CGPoint point = [gesture locationInView:self.view];
    ABLine *line = [self checkLinesForPoint:point];
    if(line == nil) return;
    [line touch:[self.view convertPoint:point toView:line]];
}

- (IBAction) tap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.view];
    ABLine *line = [self checkLinesForPoint:point];
    if(line == nil) return;
    [line tap:[self.view convertPoint:point toView:line]];
}

- (IBAction) doubleTap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.view];
    ABLine *line = [self checkLinesForPoint:point];
    if(line == nil) return;
    [line doubleTap:[self.view convertPoint:point toView:line]];
}


- (IBAction) rotate:(UIRotationGestureRecognizer *)gesture {
    [ABClock updateLastInteractionTime];
    
    if(gesture.state == UIGestureRecognizerStateEnded) {
        if(gesture.rotation > 0.3 || gesture.rotation < -0.3 ) {
            [feedbackReset flash];
            [ABState clearMutations];
        }
    }
}


- (IBAction) longPress:(UILongPressGestureRecognizer *)gesture {
    [ABClock updateLastInteractionTime];
    
    if([ABState isRunningInBookMode]) {
        if(gesture.state == UIGestureRecognizerStateBegan) {
            if([ABState attemptGesture] == NO) return;
            [ABState pause];
        } else if(gesture.state == UIGestureRecognizerStateEnded) {
            [ABState resume];
        }
        
    } else {
        if(gesture.state == UIGestureRecognizerStateBegan) {
            CGPoint point = [gesture locationInView:self.view];
            ABLine *line = [self checkLinesForPoint:point];
            if(line == nil) return;
            [line longPress:[self.view convertPoint:point toView:line]];
        }
    }
}


- (void) turnPage:(int)direction {
    if(carouselIsAnimating) return;
    [self.carousel scrollByNumberOfItems:direction duration:1.4f];
    [self carouselFlash];
    [feedbackBackward flash];
    [ABState turnPage:direction];
}

- (void) edgeSwipeCheckWithGesture:(UIScreenEdgePanGestureRecognizer *)gesture andDirection:(int)direction {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        touchStart = [gesture locationInView:self.view];
        
    } else if(gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint touchEnd = [gesture locationInView:self.view];
        CGFloat xDist = (touchEnd.x - touchStart.x);
        CGFloat yDist = (touchEnd.y - touchStart.y);
        
        // alter xDist comparator with direction
        if(yDist < 100 && ((xDist < -40 && direction == 1) || (xDist > 40 && direction == -1))) {
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






///////////////////
// CONTROL PANEL //
///////////////////

- (void) initControlPanel {
    controlPanel = [[ABControlPanel alloc] init];
    [self.view addSubview:controlPanel];
    controlPanelArrowButton = [controlPanel createArrowButton];
    [controlPanelArrowButton addTarget:self action:@selector(triggerControlPanel) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    [self.view addSubview:controlPanelArrowButton];
}

- (void) triggerControlPanel {
    [controlPanel openOrClose];
}







/////////////////
// GRAFT MODAL //
/////////////////

- (void) initGraftModal {
    UIView *modal = [ABUI createModalWithFrame:CGRectMake(362, 100, 300, 140)];
    graftTextField = [ABUI createTextFieldWithFrame:CGRectMake(20, 20, 260, 100)];
    graftTextField.delegate = self;
    [modal addSubview:graftTextField];
    graftCurtain = [[ABBlackCurtain alloc] init];
    graftCurtain.destroyOnFadeOut = NO;
    [self.view addSubview:graftCurtain];
    [graftCurtain addSubview:modal];
}

- (void) showGraftModal {
    [graftTextField becomeFirstResponder];
    [graftCurtain show];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [graftTextField resignFirstResponder];
    BOOL successfulGraft = [ABState graftText:textField.text];
    if(successfulGraft == NO) [controlPanel selectMutate];
    [graftCurtain hide];
    return YES;
}






///////////////
// INFO VIEW //
///////////////

- (void) initInfoView {
    infoCurtain = [[ABBlackCurtain alloc] init];
    infoCurtain.destroyOnFadeOut = NO;
    [self.view addSubview:infoCurtain];
    infoView = [[ABInfoView alloc] init];
    [infoCurtain addSubview:infoView];
}

- (void) showInfoView {
    [infoCurtain show];
}







//////////////////
// LOADING VIEW //
//////////////////

- (void) initLoading {
    loadingCurtain = [[ABBlackCurtain alloc] init];
    loadingCurtain.destroyOnFadeOut = NO;
    [self.view addSubview:loadingCurtain];
    
}

- (void) showLoading {
    
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
    self.carousel.scrollSpeed = 0.19;
    self.carousel.clipsToBounds = NO;
    
    [self.view addSubview:_carousel];
    [self.view bringSubviewToFront:_carousel];
    
    carouselIsAnimating = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:8.5];
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
    carouselIsAnimating = YES;
    [UIView animateWithDuration:0.4 animations:^() {
        _carousel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.64 animations:^() {
            _carousel.alpha = 0.75;
        } completion:^(BOOL finished) {
            carouselIsAnimating = NO;
        }];
    }];
}










- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


