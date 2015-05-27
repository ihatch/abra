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







- (NSArray *)propertyKeys
{
    NSMutableArray *array = [NSMutableArray array];
    Class class = [self class];
    while (class != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //check if read-only
            BOOL readonly = NO;
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
            {
                readonly = YES;
                
                //see if there is a backing ivar with a KVC-compliant name
                NSRange iVarRange = [encoding rangeOfString:@",V"];
                if (iVarRange.location != NSNotFound)
                {
                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
                    if ([iVarName isEqualToString:key] ||
                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //setValue:forKey: will still work
                        readonly = NO;
                    }
                }
            }
            
            if (!readonly)
            {
                //exclude read-only properties
                [array addObject:key];
            }
        }
        free(properties);
        class = [class superclass];
    }
    return array;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [self init]))
    {
        for (NSString *key in [self propertyKeys])
        {
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self propertyKeys])
    {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}


@end
