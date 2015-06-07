//
//  ABScriptWord.h
//  Abra
//
//  Created by Ian Hatcher on 2/7/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABScriptWord : NSObject

@property (nonatomic) NSString *text;
@property (nonatomic) NSMutableArray *sisters;
@property (nonatomic) int sourceStanza;
@property (nonatomic) int morphCount;
@property (nonatomic) int emojiCount;
@property (nonatomic) int nonAsciiCount;
@property (nonatomic) BOOL isNumber;
@property (nonatomic) BOOL marginLeft;
@property (nonatomic) BOOL marginRight;
@property (nonatomic) BOOL isGrafted;


- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza;
- (id) initGraftedWithText:(NSString *)wordText sourceStanza:(int)stanza;

- (void) checkProperties;
- (void) addSister:(NSString *)wordText;
- (BOOL) hasSister:(NSString *)string;

- (ABScriptWord *) copyOfThisWord;

+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word;


@end
