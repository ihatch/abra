//
//  NSString+ABExtras.m
//  Abra
//
//  Created by Ian Hatcher on 7/7/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "NSString+ABExtras.h"

@implementation NSString (ConvertToArray)

- (NSArray *) convertToArray {
    NSMutableArray *arr = [NSMutableArray array];
    NSUInteger i = 0;
    while (i < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *chStr = [self substringWithRange:range];
        [arr addObject:chStr];
        i += range.length;
    }
    return arr;
}

- (NSMutableArray *) convertToMutableArray {
    NSMutableArray *arr = [NSMutableArray array];
    NSUInteger i = 0;
    while (i < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *chStr = [self substringWithRange:range];
        [arr addObject:chStr];
        i += range.length;
    }
    return arr;
}

@end



@implementation NSMutableArray (Shuffling)

- (void) shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end

