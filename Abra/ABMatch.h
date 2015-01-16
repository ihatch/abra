//
//  ABMatch.h
//  Abra
//
//  Created by Ian Hatcher on 12/12/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABMatch : NSObject

- (NSMutableArray *) matchWithPast: (NSArray *) pastArray andFuture:(NSArray *) futureArray;

@end
