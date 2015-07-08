//
//  ABFlow.m
//  Abra
//
//  Created by Ian Hatcher on 6/27/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABFlow : UIView

@property (nonatomic) CGFloat appendYPosition;
@property (nonatomic) CGFloat headingMarginBottom;
@property (nonatomic) CGFloat paragraphMarginBottom;
@property (nonatomic) CGFloat sectionMarginBottom;
@property (nonatomic) CGFloat imageMargin;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) BOOL isSelfCentered;

- (CGFloat) flowHeight;

- (void) addHeading:(NSString *)text;
- (void) addParagraph:(NSString *)text;
- (void) addItalicParagraph:(NSString *)text;
- (void) addImage:(NSString *)imageName;
- (void) addImageToBottom:(NSString *)imageName;
- (void) addAuthors;
- (void) addLink:(NSString *)url;

- (void) addSectionMargin;
- (void) addSpecialItalicizedParagraph:(NSString *)text;

- (void) refreshFrame;
- (void) bringLogosToFront;
- (void) adjustBottomMargin;

@end
