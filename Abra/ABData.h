//
//  ABData.h
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABData : NSObject <NSCoding> {
    NSDictionary *coreSimilarityIndex;
}

@property (nonatomic, copy) NSDictionary *coreSimilarityIndex;


@end
