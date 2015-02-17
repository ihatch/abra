//
//  ABData.m
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABData.h"

@implementation ABData


@synthesize coreSimilarityIndex;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.coreSimilarityIndex = [decoder decodeObjectForKey:@"coreSimilarityIndex"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:coreSimilarityIndex forKey:@"coreSimilarityIndex"];
}

@end
