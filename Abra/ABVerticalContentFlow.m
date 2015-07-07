//
//  ABVerticalContentFlow.m
//  Abra
//
//  Created by Ian Hatcher on 6/27/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABVerticalContentFlow.h"
#import "ABConstants.h"
#import "ABUI.h"
#import <QuartzCore/QuartzCore.h>


@implementation ABVerticalContentFlow

UIFont *contentFont, *headingFont, *italicFont, *linkFont, *flowersFont, *versionFont;


- (id) initWithFrame:(CGRect)frame {

    contentFont = [UIFont fontWithName:ABRA_FONT size:[ABUI scaleYWithIphone:11.0f ipad:16.0f]];
    headingFont = [UIFont fontWithName:ABRA_SYSTEM_FONT size:[ABUI scaleYWithIphone:9.5f ipad:15.0f]];
    flowersFont = [UIFont fontWithName:ABRA_FLOWERS_FONT size:[ABUI scaleYWithIphone:9.5f ipad:15.0f]];
    italicFont = [UIFont fontWithName:ABRA_ITALIC_FONT size:[ABUI scaleYWithIphone:11.0f ipad:16.0f]];
    linkFont = [UIFont fontWithName:ABRA_FONT size:[ABUI scaleYWithIphone:11.0f ipad:16.0f]];
    versionFont = [UIFont fontWithName:ABRA_SYSTEM_FONT size:[ABUI scaleYWithIphone:6.5f ipad:11.0f]];
    
    self = [super initWithFrame:frame];
    if (self) {
        self.appendYPosition = [ABUI scaleYWithIphone:5.0f ipad:20.0f];
        self.headingMarginBottom = [ABUI scaleYWithIphone:7.0f ipad:10.0f];
        self.paragraphMarginBottom = [ABUI scaleYWithIphone:7.0f ipad:10.0f];
        self.sectionMarginBottom = [ABUI scaleYWithIphone:20.0f ipad:35.0f];
        self.imageMargin = [ABUI scaleYWithIphone:10.0f ipad:15.0f];
        self.lineHeight = [ABUI scaleYWithIphone:20.0f ipad:30.0f];
    }
    return self;
}


- (void) refreshFrame {
    CGRect newFrame = self.frame;
    newFrame.size.height = self.appendYPosition;
    self.frame = newFrame;
}


- (CGFloat) flowHeight {
    return self.appendYPosition;
}


- (CGFloat) heightForLabel:(UILabel *)label {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = self.lineHeight;
    style.maximumLineHeight = self.lineHeight;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : style, NSFontAttributeName:label.font};
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attrs];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return ceil(rect.size.height);
}


- (UILabel *) addLabelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color shadow:(BOOL)shadow italic:(BOOL)italic url:(NSString *)url {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1000)];

    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.preferredMaxLayoutWidth = self.frame.size.width;
    label.numberOfLines = 0;
    
    if(font == headingFont) {
        text = [NSString stringWithFormat:@"%@ %@ %@", @"K", text, @"J"];
    }

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = self.lineHeight;
    style.maximumLineHeight = self.lineHeight;
    if(self.isSelfCentered) style.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : style};
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
    [label setTextColor:color];

    if(font == headingFont) {
        [attrString addAttribute:NSFontAttributeName value:flowersFont range:NSMakeRange(0, 1)];
        [attrString addAttribute:NSForegroundColorAttributeName value:[ABUI darkGoldColor2] range:NSMakeRange(0,1)];
        [attrString addAttribute:NSFontAttributeName value:flowersFont range:NSMakeRange([text length] - 1, 1)];
        [attrString addAttribute:NSForegroundColorAttributeName value:[ABUI darkGoldColor2] range:NSMakeRange([text length] - 1, 1)];
        [attrString addAttribute:NSKernAttributeName value:@(1.5f) range:NSMakeRange(0, [text length])];
    } else if(italic) {
        [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, [text length])];
    } else {
        [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(0, [text length])];
    }
    
    label.attributedText = attrString;
    
    
    CGFloat labelHeight = [self heightForLabel:label];
    label.frame = CGRectMake(0, self.appendYPosition, self.frame.size.width, labelHeight);
    
    if(shadow) {
        label.layer.shadowColor = [label.textColor CGColor];
        label.layer.shadowOffset = CGSizeMake(0, 0);
        label.layer.shadowRadius = [ABUI scaleYWithIphone:2.0f ipad:3.0f];
        label.layer.shadowOpacity = 0.65;
        label.layer.masksToBounds = NO;
    }
    
    [self addSubview:label];
    self.appendYPosition += labelHeight;
    
    return label;
}



- (void) addHeading:(NSString *)text {
    [self addLabelWithText:text font:headingFont color:[ABUI goldColor] shadow:YES italic:NO url:nil];
    self.appendYPosition += self.headingMarginBottom;
}

- (void) addItalicParagraph:(NSString *)text {
    [self addLabelWithText:text font:contentFont color:[ABUI whiteTextColor] shadow:NO italic:YES url:nil];
    self.appendYPosition += self.paragraphMarginBottom;
}

- (void) addParagraph:(NSString *)text {
    [self addLabelWithText:text font:contentFont color:[ABUI whiteTextColor] shadow:NO italic:NO url:nil];
    self.appendYPosition += self.paragraphMarginBottom;
}



- (void) addLink:(NSString *)text {
    UILabel *label = [self addLabelWithText:text font:contentFont color:[ABUI darkGoldColor] shadow:YES italic:NO url:text];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnLink:)];
    [label setUserInteractionEnabled:YES];
    [label addGestureRecognizer:gesture];
    
    self.appendYPosition += self.paragraphMarginBottom;
}


- (void) userTappedOnLink:(UIGestureRecognizer*)gestureRecognizer {
    UILabel *label = (UILabel *)gestureRecognizer.view;
    DDLogInfo(@"%@", label.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:label.text]];
}



- (void) addAuthors:(NSString *)text {
    [self addLabelWithText:text font:contentFont color:[ABUI whiteTextColor] shadow:NO italic:YES url:nil];
    self.appendYPosition += self.paragraphMarginBottom;
}


- (UIImage*) imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

    
- (void) addImage:(NSString *)imageName {

    self.appendYPosition += self.imageMargin;

    UIImage *image = [UIImage imageNamed:imageName];
    image = [self imageWithImage:image scaledToWidth:self.frame.size.width * 2];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, self.appendYPosition, image.size.width / 2, image.size.height / 2);

    [self addSubview:imageView];
    self.appendYPosition += (image.size.height / 2) + self.imageMargin;
}


// Only used for logos -- so tapping logo takes you to the CBPA site - or SHOULD... sigh
- (void) addImageToBottom:(NSString *)imageName {
    
    UIImage *image = [UIImage imageNamed:imageName];
    image = [self imageWithImage:image scaledToWidth:self.frame.size.width * 2];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    CGFloat y = self.frame.size.height - (image.size.height / 2) - [ABUI scaleYWithIphone:15.0f ipad:30.0f];
    imageView.frame = CGRectMake(0, y, image.size.width / 2, image.size.height / 2);
    
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnLogos:)];
    [imageView addGestureRecognizer:gesture];
    [self addSubview:imageView];
    
    // Version hack.
    [self addVersionToYPosition:y - [ABUI scaleYWithIphone:19.0f ipad:30.0f]];
    
}



- (void) addVersionToYPosition:(CGFloat)y {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1000)];
    label.text = ABRA_VERSION;
    label.font = versionFont;
    [label setTextColor:[UIColor colorWithRed:0.9 green:0.85 blue:0.78 alpha:0.4]];
    label.frame = CGRectMake(0, y, self.frame.size.width, 12.0f);
    
    [self addSubview:label];
}



- (void) userTappedOnLogos:(UIGestureRecognizer*)gestureRecognizer {
    DDLogInfo(@"userTappedOnLogos");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.colum.edu/academics/media-arts/initiatives/expanded-artists-books.html"]];
}


- (void) addSectionMargin {
    self.appendYPosition += self.sectionMarginBottom;
}


- (void) addSpecialItalicizedParagraph:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1000)];
    label.font = contentFont;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.preferredMaxLayoutWidth = self.frame.size.width;
    label.numberOfLines = 0;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = self.lineHeight;
    style.maximumLineHeight = self.lineHeight;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : style};
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
    
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(0,59)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,59)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(0,59)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(59,6)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(59,6)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(59,6)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(65,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(65,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(65,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(67,4)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(67,4)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(67,4)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(71,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(71,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(71,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(73,17)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(73,17)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(73,17)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(90,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(90,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(90,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(92,20)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(92,20)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(92,20)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(112,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(112,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(112,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(114,12)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(114,12)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(114,12)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(126,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(126,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(126,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(128,13)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(128,13)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(128,13)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(141,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(141,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(141,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(143,14)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(143,14)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(143,14)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(157,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(157,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(157,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(159,44)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(159,44)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(159,44)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(203,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(203,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(203,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(205,3)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(205,3)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(205,3)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(208,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(208,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(208,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(210,9)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(210,9)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(210,9)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(219,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(219,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(219,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(221,5)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(221,5)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(221,5)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(226,2)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(226,2)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(226,2)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(228,25)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(228,25)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(228,25)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(253,6)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(253,6)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(253,6)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(259,4)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(259,4)];
    [attrString addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(259,4)];
    [attrString addAttribute:NSLigatureAttributeName value:@(0) range:NSMakeRange(263,1)];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(263,1)];
    [attrString addAttribute:NSFontAttributeName value:contentFont range:NSMakeRange(263,1)];
    
    label.attributedText = [[NSAttributedString alloc] initWithAttributedString:attrString];
    
    [label setTextColor:[UIColor colorWithRed:0.95 green:0.9 blue:0.85 alpha:1]];
    CGFloat labelHeight = [self heightForLabel:label];
    label.frame = CGRectMake(0, self.appendYPosition, self.frame.size.width, labelHeight);
    [self addSubview:label];
    self.appendYPosition += labelHeight;
    self.appendYPosition += self.paragraphMarginBottom;
}




@end
