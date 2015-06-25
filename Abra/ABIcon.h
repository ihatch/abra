//
//  ABIcon.h
//  Abra
//
//  Created by Ian Hatcher on 6/8/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, iconType) {
    MUTATE_ICON,
    GRAFT_ICON,
    PRUNE_ICON,
    ERASE_ICON,
    CADABRA_ICON,
    SHARE_ICON,
    SETTINGS_ICON,
    INFO_ICON,
    FLOWER_ICON
};


@interface ABIcon : UIView

@property (nonatomic) iconType iconType;

@property (nonatomic) NSString *labelText;
@property (nonatomic) NSString *symbolText;

@property (nonatomic) UILabel *iconLabel;
@property (nonatomic) UILabel *iconLabelHighlighted;
@property (nonatomic) UILabel *iconSymbol;

@property (nonatomic) CGFloat iconWidth;
@property (nonatomic) CGFloat iconHeight;

@property (nonatomic) CGFloat labelFontSize;
@property (nonatomic) CGFloat symbolFontSize;
@property (nonatomic) CGFloat labelTopOffset;

@property (nonatomic) BOOL isModeControl;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isAnimating;


- (id) initWithFrame:(CGRect)frame text:(NSString *)text symbol:(NSString *)symbol iconType:(iconType)type;

- (void) select;
- (void) highlight;
- (void) lowlight;

- (void) show;
- (void) hide;
- (void) hideInstantly;
- (void) flash;

@end
