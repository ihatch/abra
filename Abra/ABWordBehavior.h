//
//  ABWordBehavior.h
//  
//
//  Created by Ian Hatcher on 8/29/14.
//
//

#import <UIKit/UIKit.h>

@interface ABWordBehavior : UIDynamicBehavior

@property (nonatomic) CGPoint targetPoint;
@property (nonatomic) CGPoint velocity;

- (instancetype)initWithItem:(id <UIDynamicItem>)item;

@end
