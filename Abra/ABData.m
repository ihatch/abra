//
//  ABData.m
//  Abra
//
//  Created by Ian Hatcher on 1/18/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABData.h"

@implementation ABData


+ (void) saveData:(NSDictionary *)dataDict forKey:(NSString *)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *fileName = [@"abraData-" stringByAppendingString:key];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:dataDict toFile:filePath];
}

+ (void) saveCoreMutationsIndex:(NSDictionary *)dataDict {
    [ABData saveData:dataDict forKey:@"coreMutationsTable"];
}

+ (void) saveModifiedMutationsIndex:(NSDictionary *)dataDict {
    [ABData saveData:dataDict forKey:@"modifiedMutationsTable"];
}

+ (NSMutableDictionary *) loadCoreMutationsIndex {
    return [ABData loadMutableDataForKey:@"coreMutationsTable"];
}

+ (NSMutableDictionary *) loadModifiedMutationsIndex {
    return [ABData loadMutableDataForKey:@"modifiedMutationsTable"];
}


+ (NSDictionary *) loadDataForKey:(NSString *)key {

    // look for saved data.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *fileName = [@"abraData-" stringByAppendingString:key];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return savedData;
    }
    return nil;
}


+ (NSMutableDictionary *) loadMutableDataForKey:(NSString *)key {
    NSDictionary *data = [ABData loadDataForKey:key];
    NSMutableDictionary *mut = CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(data), kCFPropertyListMutableContainersAndLeaves));
    return mut;
}



+ (NSArray *) loadRawStanzas {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [rawText componentsSeparatedByString:@"\n\n\n"];
}


+ (NSArray *) loadWordList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wordList" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [rawText componentsSeparatedByString:@"\n"];
}


+ (NSMutableDictionary *) loadDiceAdditionsAndAddToDictionary:(NSMutableDictionary *)diceDictionary {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"diceAdditions" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *entries = [rawText componentsSeparatedByString:@"\n"];

    for (int i = 0; i < [entries count]; i++) {
        NSArray *terms = [entries[i] componentsSeparatedByString:@" "];
        NSString *key = terms[0];
        NSMutableArray *others = [NSMutableArray array];
        for (int j = 1; j < [terms count]; j++) {
            [others addObject:terms[j]];
        }
        [diceDictionary setObject:[NSArray arrayWithArray:others] forKey:key];
    }

    return diceDictionary;
}





@end
