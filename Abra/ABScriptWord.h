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
@property (nonatomic) int sourceStanza;
@property (nonatomic) BOOL marginLeft;
@property (nonatomic) BOOL marginRight;
@property (nonatomic) NSMutableArray *leftSisters;
@property (nonatomic) NSMutableArray *rightSisters;
@property (nonatomic) BOOL isGrafted;
@property (nonatomic) int morphCount;

- (id) initWithText:(NSString *)wordText sourceStanza:(int)stanza;

- (void) addRightSister:(NSString *)wordText;
- (void) addLeftSister:(NSString *)wordText;

+ (ABScriptWord *) copyScriptWord:(ABScriptWord *)word;

@end
