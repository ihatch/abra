//
//  ABCharSets.m
//  Abra
//
//  Created by Ian Hatcher on 7/3/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//


#import "ABCharSets.h"
#import "ABEmoji.h"
#import "emojis.h"
#import "ABConstants.h"
#import "ABScriptWord.h"
#import "ABData.h"


@implementation ABCharSets : NSObject

// NSArray *


- (void) initCharSets {
    DDLogInfo(@"$$$$ init charsets $$$$");
    
    
    DDLogInfo(@"$$$$ done init charsets $$$$");
}


- (NSArray *) getAllSymbolsInCharset {
    
    NSCharacterSet *charset = [NSCharacterSet uppercaseLetterCharacterSet];
    NSMutableArray *array = [NSMutableArray array];
    for (int plane = 0; plane <= 16; plane++) {
        if ([charset hasMemberInPlane:plane]) {
            UTF32Char c;
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([charset longCharacterIsMember:c]) {
                    UTF32Char c1 = OSSwapHostToLittleInt32(c); // To make it byte-order safe
                    NSString *s = [[NSString alloc] initWithBytes:&c1 length:4 encoding:NSUTF32LittleEndianStringEncoding];
                    [array addObject:s];
                }
            }
        }
    }
    return [NSArray arrayWithArray:array];
}


    
@end
