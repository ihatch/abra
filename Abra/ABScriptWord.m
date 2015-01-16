//
//  ABScriptWord.m
//  Abra
//
//  Created by Ian Hatcher on 2/7/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import "ABScriptWord.h"

@implementation ABScriptWord

@synthesize text, sourceStanza, marginLeft, marginRight, leftSisters, rightSisters, isGrafted;

- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza {
    if(self = [super init]) {

        self.text = wordText;
        self.sourceStanza = stanza;
        self.isGrafted = NO;

        // defaults
        self.marginLeft = YES;
        self.marginRight = YES;
    }
    
    return self;
}

- (void) addLeftSister:(NSString *)wordText {
    [self.leftSisters addObject:wordText];
}

- (void) addRightSister:(NSString *)wordText {
    [self.rightSisters addObject:wordText];
}

- (BOOL) checkLeft:(NSString *)word {
    return [self searchForSister:word inArray:self.leftSisters];
}

- (BOOL) checkRight:(NSString *)word {
    return [self searchForSister:word inArray:self.rightSisters];
}

- (BOOL) searchForSister:(NSString *)word inArray:(NSArray *)array {
    
    if([array count] == 0) return NO;
    
    for(int i=0; i<[array count]; i++){
        if([array[i] isEqualToString:word]) return YES;
    }
    return NO;
}

+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word {
    ABScriptWord *copy = [[ABScriptWord alloc] initWithText:word.text sourceStanza:word.sourceStanza];
    copy.leftSisters = word.leftSisters;
    copy.rightSisters = word.rightSisters;
    copy.isGrafted = word.isGrafted;
    copy.marginLeft = word.marginLeft;
    copy.marginRight = word.marginRight;
    return copy;
}


@end
