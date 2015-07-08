//
//  NSString+ABExtras.h
//  Abra
//
//  Created by Ian Hatcher on 7/7/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ConvertToArray)

- (NSArray *) convertToArray;
- (NSMutableArray *) convertToMutableArray;

@end


@interface NSMutableArray (Shuffling)

- (void) shuffle;

@end
