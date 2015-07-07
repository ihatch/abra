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
@property (nonatomic) NSMutableArray *family;

@property (nonatomic) NSMutableArray *leftSisters;
@property (nonatomic) NSMutableArray *rightSisters;

@property (nonatomic) int sourceStanza;
@property (nonatomic) int morphCount;
@property (nonatomic) int emojiCount;
// @property (nonatomic) int nonAsciiCount;
@property (nonatomic) BOOL hasRunChecks;
// @property (nonatomic) BOOL isNumber;
@property (nonatomic) BOOL marginLeft;
@property (nonatomic) BOOL marginRight;
@property (nonatomic) BOOL isGrafted;
@property (nonatomic) BOOL hasFamily;
@property (nonatomic) NSString *cadabra;

@property (nonatomic, readonly) int charCount;
@property (nonatomic, readonly) NSArray *charArray;


- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza inFamily:(NSArray *)fam isGrafted:(BOOL)isGraft;

- (void) runChecks;

- (void) addFamily:(NSArray *)array;
- (void) addLeftSister:(NSString *)wordText;
- (void) addRightSister:(NSString *)wordText;

- (ABScriptWord *) copyOfThisWord;
+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word;


@end
