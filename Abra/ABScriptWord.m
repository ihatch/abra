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

@implementation ABScriptWord

@synthesize text, sourceStanza, marginLeft, marginRight, sisters, isGrafted, emojiCount, nonAsciiCount, isNumber;

- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza {
    if(self = [super init]) {

        self.text = wordText;
        self.sourceStanza = stanza;
        self.isGrafted = NO;
        self.emojiCount = 0;
        self.nonAsciiCount = 0;
        self.isNumber = NO;

        // defaults
        self.marginLeft = YES;
        self.marginRight = YES;
    }
    
    return self;
}


- (id) initGraftedWithText:(NSString *)wordText sourceStanza:(int)stanza {
    if(self = [super init]) {

        self.text = wordText;
        self.sourceStanza = stanza;
        self.isGrafted = YES;
        [self checkProperties];
        self.marginLeft = YES;
        self.marginRight = YES;
    }
    
    return self;
}


- (void) checkProperties {
    self.emojiCount = [self emojiCheck];
    self.nonAsciiCount = [self nonAsciiCheck];
    self.isNumber = [self numberCheck];
}



- (void) addSister:(NSString *)wordText {
    if([self.sisters indexOfObject:wordText]) return;
    [self.sisters addObject:wordText];
}

- (BOOL) hasSister:(NSString *)string {
    if([sisters count] == 0) return NO;
    for(int i=0; i<[sisters count]; i++){
        if([sisters[i] isEqualToString:string]) return YES;
    }
    return NO;
}



- (int) emojiCheck {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:EMOJI_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
//    NSLog(@"Emoji check: %@ %i", self.text, numberOfMatches);
    return numberOfMatches;
}

- (int) nonAsciiCheck {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NON_ASCII_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
//    NSLog(@"Non-ASCII check: %@ %i", self.text, numberOfMatches);
    return numberOfMatches;
}

- (int) numberCheck {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NUMBERS_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
//    NSLog(@"Number check: %@ %i", self.text, numberOfMatches);
    return numberOfMatches;
}


- (ABScriptWord *) copyOfThisWord {
    return [ABScriptWord copyScriptWord:self];
}


+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word {
    ABScriptWord *copy = [[ABScriptWord alloc] initWithText:word.text sourceStanza:word.sourceStanza];
    copy.marginLeft = word.marginLeft;
    copy.marginRight = word.marginRight;
    copy.isGrafted = word.isGrafted;
    copy.isNumber = word.isNumber;
    copy.emojiCount = word.emojiCount;
    copy.nonAsciiCount = word.nonAsciiCount;
    copy.sisters = word.sisters;
    return copy;
}




@end
