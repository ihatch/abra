//
//  ABLoading.m
//  Abra
//
//  Created by Ian Hatcher on 6/1/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABLoading.h"
#import "ABBlackCurtain.h"

@implementation ABLoading


ABBlackCurtain *blackCurtain;

static ABLoading *ABLoadingInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABLoadingInstance == NULL) ABLoadingInstance = [[ABLoading alloc] init];
    }
}


+ (void) setBlackCurtain:(ABBlackCurtain *)curtain {
    blackCurtain = curtain;
}

+ (void) showWithText:(NSString *)text {
    
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
