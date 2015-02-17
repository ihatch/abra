//
//  ABDice.m
//  
//
//  Created by Ian Hatcher on 1/18/15.
//
//

#import "ABDice.h"
#import "ABData.h"

@implementation ABDice


NSDictionary *charArrayCache;


+ (CGFloat) diceCoefficientWithString:(NSString *)s andString:(NSString *)t {

    if ([s isEqualToString:t]) return 1;

    int n = (int)[s length];
    int m = (int)[t length];

    if (s == nil || t == nil) return 0;
    if (n < 1 || m < 1) return 0;
    
    NSArray *sChars = [charArrayCache objectForKey:s];
    NSArray *tChars = [charArrayCache objectForKey:t];

    int matches = 0, i = 0, j = 0;
    
    while (i < n && j < m) {
        NSComparisonResult result = [sChars[i] compare:tChars[j]];
        if (result == NSOrderedSame) {
            matches += 2;
            i++;
            j++;
        } else if (result == NSOrderedAscending) {
            i++;
        } else {
            j++;
        }
    }
    
    return (CGFloat) matches / (n + m);
}



+ (void) initCacheWithLexicon:(NSArray *)lexicon {
    
    NSMutableDictionary *arrays = [NSMutableDictionary dictionary];
    
    for(NSString * s in lexicon) {
        if([s length] < 1 || s == nil) continue;
        int n = (int)[s length] - 1;
        NSMutableArray *sChars = [[NSMutableArray alloc] initWithCapacity:n];
        for (int i = 0; i <= n; i ++) {
            [sChars addObject:[NSNumber numberWithChar:[s characterAtIndex:i]]];
        }
        if([sChars count] > 1) {
            [sChars sortUsingSelector:@selector(compare:)];
        }
        [arrays setObject:[NSArray arrayWithArray:sChars] forKey:s];
    }
    
    charArrayCache = [NSDictionary dictionaryWithDictionary:arrays];
}





+ (NSArray *) topMatchesForTerm:(NSString *)term inLexicon:(NSArray *)lexicon {
    
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
    for(NSString * term2 in lexicon) {
        
        if([term isEqualToString:term2]) continue;
        
        CGFloat c = [ABDice diceCoefficientWithString:term andString:term2];
        if(c < 0.3) continue;
        NSString *score = [NSString stringWithFormat:@"%f", c];
        
        if (![res objectForKey:score]) {
            [res setObject:[NSMutableArray array] forKey:score];
        }
        [[res objectForKey:score] addObject:term2];
    }
    
    NSArray *keys = [[res allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *topterms = [NSMutableArray array];
    
    for (NSString * key in [keys reverseObjectEnumerator]) {
        
        if([topterms count] > 30) break;
        
        NSArray *terms = [res objectForKey:key];
        if([terms count] == 0) continue;
        
        for(NSString * t in terms) {
            if([topterms count] > 40) break;
            [topterms addObject:t];
        }
    }

    return [NSArray arrayWithArray:topterms];
}




+ (NSDictionary *) topCoreMatchesForLexicon:(NSArray *)lexicon {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:@"coreLexiconSimilarityTable"];
    
    [prefs synchronize];
    
    if([prefs objectForKey:@"coreLexiconSimilarityTable"] && false) {
        NSLog(@"Core table found.");
        
//        return (__bridge NSDictionary *)(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
//                                                               (__bridge CFPropertyListRef)([prefs objectForKey:@"coreLexiconSimilarityTable"]),
//                                                               kCFPropertyListImmutable));

 //       return [NSDictionary dictionaryWithDictionary:[prefs objectForKey:@"coreLexiconSimilarityTable"]];
    }

    NSMutableDictionary *tops = [NSMutableDictionary dictionary];
    [ABDice initCacheWithLexicon:lexicon];
    
    for(NSString * term in lexicon) {
        if([term isEqualToString:@""]) continue;
        NSArray *topterms = [self topMatchesForTerm:term inLexicon:lexicon];
        [tops setObject:topterms forKey:term];
        NSLog(@"%@", term);
    }

    
    
    
    // NSDictionary *c = [NSDictionary dictionaryWithDictionary:tops];
    
//    NSDictionary *newDictionary =
//    (__bridge NSDictionary *)(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
//                                                           (__bridge CFPropertyListRef)(tops),
//                                                           kCFPropertyListImmutable));
    
    ABData *data = [[ABData alloc] initWithCoder:[[NSCoder alloc] init]];
    
    data.coreSimilarityIndex = tops;

    
    //@{@"coreSimilarityIndex": tops};
//
//    NSDictionary *bridgeDict =
//    (__bridge NSDictionary *)(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
//                                                           (__bridge CFPropertyListRef)(tops),
//                                                           kCFPropertyListImmutable));
//    
//    [prefs setObject:tops forKey:@"coreLexiconSimilarityTable"];
//
//    NSDictionary *prefDict = [prefs objectForKey:@"coreLexiconSimilarityTable"];
//    
    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:data];
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"abraData"];
    
    NSData *notesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"abraData"];
    NSArray *core = [NSKeyedUnarchiver unarchiveObjectWithData:notesData];
    
    NSLog(@"dfgdfg");
    NSLog(@"dfgdfg");
    
    
    return tops;
}


@end
