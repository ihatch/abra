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
#import "ABUI.h"
#import "ABGestureArrow.h"
#import "ABBlackCurtain.h"
#import "ABControlPanel.h"
#import "iCarousel.h"
#import "PECropViewController.h"
#import "emojis.h"

@interface ABMainViewController () <iCarouselDataSource, iCarouselDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UINavigationItem *navItem;

@end



@implementation ABMainViewController

ABGestureArrow *feedbackForward, *feedbackBackward, *feedbackReset;
UIView *infoView;
ABBlackCurtain *graftCurtain;
UIButton *controlPanelTriggerButton;
ABBlackCurtain *infoCurtain;
CGPoint touchStart;

UILabel *graftButton, *playButton, *shareButton;
NSArray *ABLines;

UITextField *graftTextField;

CGFloat screenHeight;
CGFloat screenWidth;
BOOL isIpad;
BOOL isIpadAir;


ABControlPanel *controlPanel;



BOOL carouselIsAnimating;

- (void) viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor blackColor];
    self.view.userInteractionEnabled = YES;
    
    [ABUI setMainViewReference:self.view];

    screenHeight = [ABUI screenHeight];
    screenWidth = [ABUI screenWidth];
    NSLog(@"%f screenWidth", screenWidth);
    NSLog(@"%f screenHeight", screenHeight);
    
    isIpad = [ABUI isIpad];
    isIpadAir = [ABUI isIpadAir];
    
    [self initLines];
    [self initGestures];
    [self initCarouselView];
//    [self initButtons];
    [self initInfoView];
    
    [self initTextFieldModal];
    
    // Top control panel
    controlPanel = [[ABControlPanel alloc] initWithMainView:self];
    [self.view addSubview:controlPanel];

    
    [self devStartupTests];
    
}


- (void) devStartupTests {
    
}




///////////
// LINES //
///////////

- (void) initLines {
    NSMutableArray *lines = [ABState initLines];
    for(int i=0; i < [lines count]; i ++) {
        [self.view addSubview:[lines objectAtIndex:i]];
    }
    ABLines = [NSArray arrayWithArray:lines];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void) initCarouselView {
    
    CGFloat carouselWidth = isIpad ? 624 : screenWidth / 1.5;
    CGFloat carouselHeight = isIpad ? 120 : 90;
    CGFloat carouselX = isIpad ? 200 : (screenWidth - carouselWidth) / 2;
    CGFloat carouselY = isIpad ? 612 : screenHeight - 90;
    
	self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(carouselX, carouselY, carouselWidth, carouselHeight)];
    self.carousel.type = iCarouselTypeRotary;
	self.carousel.delegate = self;
	self.carousel.dataSource = self;
    self.carousel.alpha = 0.0;
    self.carousel.scrollSpeed = 0.15;
    self.carousel.clipsToBounds = NO;
	
    //add carousel to view
	[self.view addSubview:_carousel];
    [self.view bringSubviewToFront:_carousel];
    
    carouselIsAnimating = NO;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:8.5];
    [self.carousel setAlpha:0.8];
    [UIView commitAnimations];
    
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [ABScript totalStanzasCount];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = nil;
    
    // create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 150.0f)];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.tag = 1;
        [view addSubview:label];
    } else {
        // get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    // remember to always set any properties of your carousel item views outside of the `if (view == nil) {...}` check or you'll get weird issues with item content appearing in the wrong place
    label.backgroundColor = [UIColor clearColor];
    int intindex = (int)index;
    label.textColor = [ABUI progressHueColorForStanza:intindex];

    label.textAlignment = NSTextAlignmentCenter;
    //label.font = [label.font fontWithSize:40];
    
    CGFloat fontSize = isIpad ? 30.0f : 20.0f;
    label.font = [UIFont fontWithName:ABRA_FLOWERS_FONT size:fontSize];
    label.text = @"Q";
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap: { return YES; }
        case iCarouselOptionShowBackfaces: { return NO; }
        case iCarouselOptionSpacing: { return value * 1.01f; }
        case iCarouselOptionFadeMin: { return -0.1f; }
        case iCarouselOptionFadeMax: { return 0.35f; }
        case iCarouselOptionFadeRange: { return 1.1f; }
        case iCarouselOptionFadeMinAlpha: { return 0.30f; }
        default: { return value; }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    [ABState manuallyTransitionStanzaToNumber:(int)carousel.currentItemIndex];
    carouselIsAnimating = NO;
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel {
    carouselIsAnimating = YES;
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    carouselIsAnimating = YES;
    [ABClock updateLastInteractionTime];
}

- (void)carouselFlash {
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









////////////////
// NAVIGATION //
////////////////

- (void) moveForward {
    if(carouselIsAnimating) return;
    [self.carousel scrollByNumberOfItems:1 duration:1.4f];
    [self carouselFlash];
    [feedbackForward flash];
    [ABState forward];
}

- (void) moveBackward {
    if(carouselIsAnimating) return;
    [self.carousel scrollByNumberOfItems:-1 duration:1.4f];
    [self carouselFlash];
    [feedbackBackward flash];
    [ABState backward];
}







//////////////
// GESTURES //
//////////////


- (void) initGestureFeedback {
    
    feedbackForward = [[ABGestureArrow alloc] initWithType:@"forward"];
    feedbackBackward = [[ABGestureArrow alloc] initWithType:@"backward"];
    feedbackReset = [[ABGestureArrow alloc] initWithType:@"reset"];
    
    [self.view addSubview:feedbackForward];
    [self.view addSubview:feedbackBackward];
    [self.view addSubview:feedbackReset];
}


- (void) initGestures {

    [self initGestureFeedback];

    // Tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];

    // Double tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    
    UIScreenEdgePanGestureRecognizer *leftEdge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdge:)];
    leftEdge.edges = UIRectEdgeLeft;
    leftEdge.delegate = self;
    [self.view addGestureRecognizer:leftEdge];

    
    UIScreenEdgePanGestureRecognizer *rightEdge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdge:)];
    rightEdge.edges = UIRectEdgeRight;
    rightEdge.delegate = self;
    [self.view addGestureRecognizer:rightEdge];

    // Long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];

    
    // Rotation
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
    [self carouselFlash];
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
        if(gesture.rotation > 0.3) {
            [self textFieldModal];

        } else if(gesture.rotation < -0.3 ) {
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


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (IBAction) leftEdge:(UIRotationGestureRecognizer *)gesture {
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        touchStart = [gesture locationInView:self.view];

    } else if(gesture.state == UIGestureRecognizerStateEnded) {

        CGPoint touchEnd = [gesture locationInView:self.view];
        CGFloat xDist = (touchEnd.x - touchStart.x);
        CGFloat yDist = (touchEnd.y - touchStart.y);
        
        if(yDist < 100 && xDist > 40) {
            [ABClock updateLastInteractionTime];
            [self moveBackward];
        }
    }
}



- (IBAction) rightEdge:(UIRotationGestureRecognizer *)gesture {
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        touchStart = [gesture locationInView:self.view];
        NSLog(@"%@", @"START");
    
    } else if(gesture.state == UIGestureRecognizerStateEnded) {

        CGPoint touchEnd = [gesture locationInView:self.view];
        CGFloat xDist = (touchEnd.x - touchStart.x);
        CGFloat yDist = (touchEnd.y - touchStart.y);

        NSLog(@"%@ %f %f", @"END", xDist, yDist);

        if(yDist < 100 && xDist < -40) {
            [ABClock updateLastInteractionTime];
            [self moveForward];
        }
    }
}






////////////////////////
// MODALS / INFO VIEW //
////////////////////////


- (void) initTextFieldModal {
    UIView *modal = [ABUI createModalWithFrame:CGRectMake(362, 100, 300, 140)];
    graftTextField = [ABUI createTextFieldWithFrame:CGRectMake(20, 20, 260, 100)];
    graftTextField.delegate = self;
    [modal addSubview:graftTextField];
    graftCurtain = [[ABBlackCurtain alloc] init];
    graftCurtain.destroyOnFadeOut = NO;
    [self.view addSubview:graftCurtain];
    [graftCurtain addSubview:modal];
}


- (void) textFieldModal {
    [graftTextField becomeFirstResponder];
    [graftCurtain show];

}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [graftTextField resignFirstResponder];
    
    BOOL successfulGraft = [ABState graftText:textField.text];
    if(successfulGraft == NO) [controlPanel setModeToMutate];
    [graftCurtain hide];
    return YES;
}


- (void) initInfoView {
    
    controlPanelTriggerButton = [ABUI createInfoButtonWithFrame:CGRectMake(960, 10, 53, 53)];
    
    [controlPanelTriggerButton addTarget:self action:@selector(triggerInfoViewButton) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    [self.view addSubview:controlPanelTriggerButton];
    
}


- (void) modeValueChanged:(UISegmentedControl *)segment {
    if(segment.selectedSegmentIndex == 0) {
        [ABState setModeToStandalone];
    } else if(segment.selectedSegmentIndex == 1){
        [ABState setModeToAutoplayMode];
    }
}


- (void) triggerInfoViewButton {
    [controlPanel triggerWithButton:controlPanelTriggerButton];
}










- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end






/*
 
 
 
 
 NSArray *keys = [EMOJI_HASH allKeys];
 NSString *emoji = @"";
 for (NSString *key in keys) {
 NSLog(@"%@", [EMOJI_HASH objectForKey:key]);
 emoji = [emoji stringByAppendingString:[EMOJI_HASH objectForKey:key]];
 }
 
 emoji = @"😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤️💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐️☀️⛅️☁️⚡️☔️❄️⛄️🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎️📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛️⏰⌚️🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉️📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂️📌📎✒️✏️📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄️🎲🎯🏈🏀⚽️⚾️🎾🎱🏉🎳⛳️🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏤🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢⛵️🚤🚣⚓️🚀✈️💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠️🚧🔰⛽️🏮🎰♨️🗿🎪🎭📍🚩🇬🇧🇷🇺🇫🇷🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯️🈳🈵🈴🈲🉐🈹🈺🈶🈚️🚻🚹🚺🚼🚾🚰🚮🅿️♿️🚭🈷🈸🈂Ⓜ️🛂🛄🛅🛃🉑㊙️㊗️🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔️✳️❇️❎✅✴️💟🆚📳📴🅰🅱🆎🅾💠➿♻️♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🏧💹💲💱©®™❌‼️⁉️❗️❓❕❔⭕️🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦✖️➕➖➗♠️♥️♣️♦️💮💯✔️☑️🔘🔗➰〰〽️🔱◼️◻️◾️◽️▪️▫️🔺🔲🔳⚫️⚪️🔴🔵🔻⬜️⬛️🔶🔷🔸🔹";
 
 
 
 
 
 
 NSLog(@"%@", emoji);
*/


/*
 😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤️💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭
 
 🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐️☀️⛅️☁️⚡️☔️❄️⛄️🌀🌁🌈🌊
 
 🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎️📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛️⏰⌚️🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲Z📧📥📤✉️📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂️📌📎✒️✏️📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄️🎲🎯🏈🏀⚽️⚾️🎾🎱🏉🎳⛳️🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽
 
 🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏤🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢⛵️🚤🚣⚓️🚀✈️💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠️🚧🔰⛽️🏮🎰♨️🗿🎪🎭📍🚩🇬🇧🇷🇺🇫🇷🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸
 
 1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯️🈳🈵🈴🈲🉐🈹🈺🈶🈚️🚻🚹🚺🚼🚾🚰🚮🅿️♿️🚭🈷🈸🈂Ⓜ️🛂🛄🛅🛃🉑㊙️㊗️🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔️✳️❇️❎✅✴️💟🆚📳📴🅰🅱🆎🅾💠➿♻️♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🏧💹💲💱©®™❌‼️⁉️❗️❓❕❔⭕️🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦✖️➕➖➗♠️♥️♣️♦️💮💯✔️☑️🔘🔗➰〰〽️🔱◼️◻️◾️◽️▪️▫️🔺🔲🔳⚫️⚪️🔴🔵🔻⬜️⬛️🔶🔷🔸🔹
 
 
 
 
 
 */

