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

UIFont *contentFont, *headingFont, *italicFont;


- (id) initWithFrame:(CGRect)frame {

    contentFont = [UIFont fontWithName:ABRA_FONT size:17.0f];
    headingFont = [UIFont fontWithName:ABRA_SYSTEM_FONT size:15.0f];
    italicFont = [UIFont fontWithName:ABRA_ITALIC_FONT size:17.0f];
    
    self = [super initWithFrame:frame];
    if (self) {
        self.appendYPosition = 20.0f;
        self.headingMarginBottom = 10.0f;
        self.paragraphMarginBottom = 10.0f;
        self.sectionMarginBottom = 35.0f;
        self.imageMargin = 15.0f;
        self.lineHeight = 30.0f;
    }
    return self;
}


- (void) refreshFrame {
    CGRect newFrame = self.frame;
    newFrame.size.height = self.appendYPosition;
    self.frame = newFrame;
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



- (void) addLabelWithText:(NSString *)text Font:(UIFont *)font andColor:(UIColor *)color andShadow:(BOOL)shadow {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1000)];
    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.preferredMaxLayoutWidth = self.frame.size.width;
    label.numberOfLines = 0;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = self.lineHeight;
    style.maximumLineHeight = self.lineHeight;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName : style};
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attrs];
    
    [label setTextColor:color];
    CGFloat labelHeight = [self heightForLabel:label];
    label.frame = CGRectMake(0, self.appendYPosition, self.frame.size.width, labelHeight);
    
    if(shadow) {
        label.layer.shadowColor = [label.textColor CGColor];
        label.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        label.layer.shadowRadius = 3.0;
        label.layer.shadowOpacity = 0.2;
        label.layer.masksToBounds = NO;
    }
    
    
    [self addSubview:label];
    self.appendYPosition += labelHeight;
}


- (void) addHeading:(NSString *)text {
    [self addLabelWithText:text Font:headingFont andColor:[ABUI goldColor] andShadow:YES];
    self.appendYPosition += self.headingMarginBottom;
}


- (void) addParagraph:(NSString *)text {
    [self addLabelWithText:text Font:contentFont andColor:[UIColor colorWithRed:0.95 green:0.9 blue:0.85 alpha:1] andShadow:NO];
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


- (void) addImageToBottom:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    image = [self imageWithImage:image scaledToWidth:self.frame.size.width * 2];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, self.frame.size.height - (image.size.height / 2) - 30, image.size.width / 2, image.size.height / 2);
    
    [self addSubview:imageView];
//    self.appendYPosition += (image.size.height / 2) + self.imageMargin;
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
