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
    NSLog(@"Emoji check: %@ %i", self.text, numberOfMatches);
    return numberOfMatches;
}

- (int) nonAsciiCheck {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NON_ASCII_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
    NSLog(@"Non-ASCII check: %@ %i", self.text, numberOfMatches);
    return numberOfMatches;
}

- (int) numberCheck {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NUMBERS_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(regex, @"Unable to create regular expression");
    int numberOfMatches = (int)[regex numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
    NSLog(@"Number check: %@ %i", self.text, numberOfMatches);
    return numberOfMatches;
}


+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word {
    ABScriptWord *copy = [[ABScriptWord alloc] initWithText:word.text sourceStanza:word.sourceStanza];
    copy.sisters = word.sisters;
    copy.isGrafted = word.isGrafted;
    copy.marginLeft = word.marginLeft;
    copy.marginRight = word.marginRight;
    copy.emojiCount = word.emojiCount;
    copy.nonAsciiCount = word.nonAsciiCount;
    return copy;
}




//
//- (NSArray *)propertyKeys
//{
//    NSMutableArray *array = [NSMutableArray array];
//    Class class = [self class];
//    while (class != [NSObject class])
//    {
//        unsigned int propertyCount;
//        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
//        for (int i = 0; i < propertyCount; i++)
//        {
//            //get property
//            objc_property_t property = properties[i];
//            const char *propertyName = property_getName(property);
//            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
//            
//            //check if read-only
//            BOOL readonly = NO;
//            const char *attributes = property_getAttributes(property);
//            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
//            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
//            {
//                readonly = YES;
//                
//                //see if there is a backing ivar with a KVC-compliant name
//                NSRange iVarRange = [encoding rangeOfString:@",V"];
//                if (iVarRange.location != NSNotFound)
//                {
//                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
//                    if ([iVarName isEqualToString:key] ||
//                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
//                    {
//                        //setValue:forKey: will still work
//                        readonly = NO;
//                    }
//                }
//            }
//            
//            if (!readonly)
//            {
//                //exclude read-only properties
//                [array addObject:key];
//            }
//        }
//        free(properties);
//        class = [class superclass];
//    }
//    return array;
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    if ((self = [self init]))
//    {
//        for (NSString *key in [self propertyKeys])
//        {
//            id value = [aDecoder decodeObjectForKey:key];
//            [self setValue:value forKey:key];
//        }
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    for (NSString *key in [self propertyKeys])
//    {
//        id value = [self valueForKey:key];
//        [aCoder encodeObject:value forKey:key];
//    }
//}
//

@end
