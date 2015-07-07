//
//  ABHistory.h
//  Abra
//
//  Created by Ian Hatcher on 6/28/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABState.h"

@interface ABHistory : NSObject

+ (id) history;
- (void) record:(SpellMode)mode line:(int)line index:(int)index;

@end
