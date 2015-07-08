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
#import "ABData.h"
#import "NSString+ABExtras.h"

@interface ABScriptWord ()
@property (nonatomic) NSArray *myCharArray;
@end


@implementation ABScriptWord

- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza inFamily:(NSArray *)fam isGrafted:(BOOL)isGraft {
    if(self = [super init]) {

        self.text = wordText;
        
        self.sourceStanza = stanza;
        self.isGrafted = isGraft;
        self.marginLeft = YES;
        self.marginRight = YES;
        
        self.hasRunChecks = NO;
        self.emojiCount = 0;

        self.cadabra = [ABData checkMagicWord:wordText];
        
        self.family = [NSMutableArray array];
        self.leftSisters = [NSMutableArray array];
        self.rightSisters = [NSMutableArray array];
        if(fam != nil) [self addFamily:fam];
        
        if(isGraft) [self runChecks];
        
    }
    return self;
}



// FAMILY

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



// PROPERTY CHECKS

- (void) runChecks {
    if(self.hasRunChecks) return;
    self.emojiCount = [self emojiCheck];
    self.hasRunChecks = YES;
}

- (int) emojiCheck {
    return [self checkWithRegex:EMOJI_REGEX];
}

- (int) checkWithRegex:(NSString *)regexString {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
    return numberOfMatches;
}



// CACHED FOR FASTER COMPARISONS

- (NSArray *) charArray {
    if (_myCharArray == nil) _myCharArray = [self.text convertToArray];
    return _myCharArray;
}

- (int) charLength {
    return (int)[[self charArray] count];
}




// COPIES

- (ABScriptWord *) copyOfThisWord {
    return [ABScriptWord copyScriptWord:self];
}

+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word {
    
    ABScriptWord *copy = [[ABScriptWord alloc] initWithText:word.text sourceStanza:word.sourceStanza inFamily:word.family isGrafted:word.isGrafted];

    copy.marginLeft = word.marginLeft;
    copy.marginRight = word.marginRight;
    copy.emojiCount = word.emojiCount;
    copy.leftSisters = [[NSMutableArray alloc] initWithArray:word.leftSisters copyItems:YES];
    copy.rightSisters = [[NSMutableArray alloc] initWithArray:word.rightSisters copyItems:YES];
    copy.hasFamily = word.hasFamily;
    copy.hasRunChecks = word.hasRunChecks;
    
    return copy;
}




@end
