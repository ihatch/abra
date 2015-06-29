//
//  ABHistory.h
//  Abra
//
//  Created by Ian Hatcher on 6/28/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABHistory : NSObject

@property (nonatomic) int mutateCount;
@property (nonatomic) int cadabraCount;
@property (nonatomic) int shareCount;
@property (nonatomic) int eraseCount;
@property (nonatomic) int pruneCount;
@property (nonatomic) int graftCount;
@property (nonatomic) int magicTapCount;

+ (id) history;



@end
