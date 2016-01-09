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
#import "ABEmoji.h"
#import "NSString+ABExtras.h"

@interface ABScriptWord ()
@property (nonatomic) NSArray *cachedCharArray;
@end


@implementation ABScriptWord

- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza inFamily:(NSArray *)fam isGrafted:(BOOL)isGraft {
    if(self = [super init]) {

        _text = wordText;
        _cachedCharArray = [wordText convertToArray];

        _sourceStanza = stanza;
        _isGrafted = isGraft;
        _marginLeft = YES;
        _marginRight = YES;

        _cadabra = [ABData checkMagicWord:wordText];

        _hasRunChecks = NO;
        _emojiCount = 0;
        
        _family = [NSArray array];
        _leftSisters = [NSArray array];
        _rightSisters = [NSArray array];
        
        if(fam != nil) [self addFamily:fam];
        if(isGraft) [self runChecks];
        
        
        /*
        NSRange stringRange = NSMakeRange(0, self.text.length);
        NSDictionary* languageMap = @{@"Latn" : @[@"en"]};
        [self.text enumerateLinguisticTagsInRange:stringRange
                                      scheme:NSLinguisticTagSchemeLexicalClass
                                     options:NSLinguisticTaggerOmitWhitespace
                                 orthography:[NSOrthography orthographyWithDominantScript:@"Latn" languageMap:languageMap]
                                  usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                                      // Log info to console for debugging purposes
                                      NSString *currentEntity = [self.text substringWithRange:tokenRange];
                                      NSLog(@"%@ is a %@, tokenRange (%d,%d)",currentEntity,tag,tokenRange.length,tokenRange.location);
                                  }];
         */
        
    }
    return self;
}



// FAMILY

- (void) addFamily:(NSArray *)array {

    if(array == nil) return;
    NSInteger count = [array count];
    if(count == 0 || count == 1) return;

    NSMutableArray *fam = [NSMutableArray arrayWithArray:array];
    for (NSInteger index = (count - 1); index >= 0; index--) {
        NSString *s = array[index];
        if ([s isEqualToString:_text]) {
            [fam removeObjectAtIndex:index];
        }
    }
    
    _family = [self addDistinct:[NSArray arrayWithArray:fam] toArray:_family];
}


- (void) addLeftSisters:(NSArray *)sisters {
    if(sisters == nil) return;
    if([sisters count] == 0) return;
    NSArray *result = [self addDistinct:sisters toArray:_leftSisters];
    _leftSisters = result;
}

- (void) addRightSisters:(NSArray *)sisters {
    if(sisters == nil) return;
    if([sisters count] == 0) return;
    NSArray *result = [self addDistinct:sisters toArray:_rightSisters];
    _rightSisters = result;
}

- (NSMutableArray *) addDistinct:(NSArray *)array1 toArray:(NSArray *)array2 {
    _hasFamily = YES;
    NSArray *array = [array1 arrayByAddingObjectsFromArray:array2];
    return [array valueForKeyPath:@"@distinctUnionOfObjects.self"];
}





// PROPERTY CHECKS

- (void) runChecks {
    if(_hasRunChecks) return;
    _emojiCount = [self emojiCheck];
//    if(_emojiCount > 1 /* || self.emojiCount != [_myCharArray count] */) {
//        [self checkEmojiProperties];
//    }
    _hasRunChecks = YES;
}

//- (void) checkEmojiProperties {
//    _emojiProperties = [ABEmoji getEmojiPropertiesForCharArray:_cachedCharArray ofString:_text];
//}

- (int) emojiCheck {
    return [self checkWithRegex:EMOJI_REGEX];
}


- (int) checkWithRegex:(NSString *)regexString {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:_text options:0 range:NSMakeRange(0, [_text length])];
    return numberOfMatches;
}



// CACHED FOR FASTER COMPARISONS

- (NSArray *) charArray {
    return _cachedCharArray;
}

- (int) charLength {
    return (int)[_cachedCharArray count];
}




// COPIES

- (id) copyWithZone:(NSZone *)zone {
    ABScriptWord *copy = [ABScriptWord allocWithZone:zone];
    copy->_text = [_text copyWithZone:zone];
    copy->_cachedCharArray = [_cachedCharArray copyWithZone:zone];
    copy->_sourceStanza = _sourceStanza;
    copy->_isGrafted = _isGrafted;
    copy->_marginLeft = _marginLeft;
    copy->_marginRight = _marginRight;
    copy->_hasRunChecks = _hasRunChecks;
    copy->_emojiCount = _emojiCount;
    copy->_cadabra = [_cadabra copyWithZone:zone];
    copy->_family = [_family copyWithZone:zone];
    copy->_leftSisters = [_leftSisters copyWithZone:zone];
    copy->_rightSisters = [_rightSisters copyWithZone:zone];
    copy->_family = [_family copyWithZone:zone];
    return copy;
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
