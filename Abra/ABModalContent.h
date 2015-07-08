//
//  ABModalContent.h
//  Abra
//
//  Created by Ian Hatcher on 7/7/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABFlow;
@interface ABModalContent : NSObject

+ (ABFlow *) tipWelcome:(ABFlow *)flow;
+ (ABFlow *) tipGraft:(ABFlow *)flow;
+ (ABFlow *) tipSpellMode:(ABFlow *)flow;
+ (ABFlow *) tipCadabra:(ABFlow *)flow;

+ (ABFlow *) infoTitleLogos:(ABFlow *)flow;
+ (ABFlow *) infoContent:(ABFlow *)flow;

@end
