//
//  ABApprentice.h
//  Abra
//
//  Created by Ian Hatcher on 7/5/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ABScriptWord;

@interface ABApprentice : NSObject

- (NSString *) randomSpell;

- (NSString *) randomStringFrom:(NSString *)source;
- (ABScriptWord *) randomSWFrom:(NSString *)source;


@end
