//
//  ABScriptWord.h
//  Abra
//
//  Created by Ian Hatcher on 2/7/14.
//  Copyright (c) 2014 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABScriptWord : NSObject <NSCopying>

@property (nonatomic) NSString *text;

@property (nonatomic) NSArray *family;
@property (nonatomic) NSArray *leftSisters;
@property (nonatomic) NSArray *rightSisters;
@property (nonatomic) NSArray *emojiProperties;

@property (nonatomic) int sourceStanza;
@property (nonatomic) int morphCount;
@property (nonatomic) int emojiCount;
@property (nonatomic) BOOL hasRunChecks;
@property (nonatomic) BOOL marginLeft;
@property (nonatomic) BOOL marginRight;
@property (nonatomic) BOOL isGrafted;
@property (nonatomic) BOOL hasFamily;

@property (nonatomic) NSString *cadabra;

@property (nonatomic, readonly) int charCount;
@property (nonatomic, readonly) NSArray *charArray;


- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza inFamily:(NSArray *)fam isGrafted:(BOOL)isGraft;

- (void) addFamily:(NSArray *)array;
- (void) addLeftSisters:(NSArray *)sisters;
- (void) addRightSisters:(NSArray *)sisters;

- (void) runChecks;

+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word;

- (id)copyWithZone:(NSZone *)zone;

@end
