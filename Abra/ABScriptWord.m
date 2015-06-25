//
//  ABScriptWord.m
//  Abra
//
//  Created by Ian Hatcher on 2/7/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "ABScriptWord.h"
#import "ABConstants.h"

// Method to split string that works with extended chars (emoji)
@interface NSString (ConvertToArray)
- (NSArray *)convertToArray;
@end
@implementation NSString (ConvertToArray)
- (NSArray *)convertToArray {
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


// Private
@interface ABScriptWord ()

@property (nonatomic) NSArray *myCharArray;

@end



@implementation ABScriptWord

@synthesize text, sourceStanza, marginLeft, marginRight, family, leftSisters, rightSisters, isGrafted, emojiCount, nonAsciiCount, isNumber;

- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza inFamily:(NSArray *)fam isGrafted:(BOOL)isGraft {
    if(self = [super init]) {

        self.text = wordText;
        self.sourceStanza = stanza;
        self.isGrafted = isGraft;
        self.marginLeft = YES;
        self.marginRight = YES;
        self.emojiCount = 0;
        self.nonAsciiCount = 0;
        self.isNumber = NO;
        self.hasRunChecks = NO;
        
        self.family = [NSMutableArray array];
        self.leftSisters = [NSMutableArray array];
        self.rightSisters = [NSMutableArray array];

        if(fam != nil) [self addFamily:fam];
        
        if(isGraft) [self runChecks];
        
    }
    return self;
}


- (void) addFamily:(NSArray *)array {
    for(NSString *s in array){
        self.family = [self addDistinct:s toArray:self.family];
    }
}
- (void) addLeftSister:(NSString *)string {
    self.leftSisters = [self addDistinct:string toArray:self.leftSisters];
}
- (void) addRightSister:(NSString *)string {
    self.rightSisters = [self addDistinct:string toArray:self.rightSisters];
}

- (NSMutableArray *) addDistinct:(NSString *)string toArray:(NSMutableArray *)array {
    if([string isEqualToString:self.text]) return array;
    if([array indexOfObject:string] != NSNotFound) return array;
    [array addObject:[string copy]];
    self.hasFamily = YES;
    return array;
}


- (void) runChecks {
    self.isNumber = [self numberCheck] != 0;
    self.nonAsciiCount = [self nonAsciiCheck];
    if(self.nonAsciiCount > 0) {
        self.emojiCount = [self emojiCheck];
    }
    self.hasRunChecks = YES;
}

- (int) emojiCheck {
    return [self checkWithRegex:EMOJI_REGEX];
}
- (int) nonAsciiCheck {
    return [self checkWithRegex:NON_ASCII_REGEX];
}

// TODO ?
- (int) numberCheck {
    return 0;
//    return [self checkWithRegex:NUMBERS_REGEX];
}

- (int) checkWithRegex:(NSString *)regexString {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
    return numberOfMatches;
}


- (NSArray *) charArray {
    if (_myCharArray == nil) {
        _myCharArray = [self.text convertToArray];
    }
    return _myCharArray;
}

- (int) charLength {
    return [[self charArray] count];
}



- (ABScriptWord *) copyOfThisWord {
    return [ABScriptWord copyScriptWord:self];
}

+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word {
    
    ABScriptWord *copy = [[ABScriptWord alloc] initWithText:word.text sourceStanza:word.sourceStanza inFamily:word.family isGrafted:word.isGrafted];

    copy.marginLeft = word.marginLeft;
    copy.marginRight = word.marginRight;

    copy.isNumber = word.isNumber;
    copy.emojiCount = word.emojiCount;
    copy.nonAsciiCount = word.nonAsciiCount;
    
    copy.leftSisters = [[NSMutableArray alloc] initWithArray:word.leftSisters copyItems:YES];
    copy.rightSisters = [[NSMutableArray alloc] initWithArray:word.rightSisters copyItems:YES];
    copy.hasFamily = word.hasFamily;

    return copy;
}




@end
