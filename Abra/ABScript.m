//
//  ABScripts.m
//  Abra
//
//  Created by Ian Hatcher on 12/5/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#import "ABScript.h"
#import "ABState.h"
#import "ABData.h"
#import "ABUI.h"
#import "ABConstants.h"
#import "ABScriptWord.h"


@implementation ABScript

NSArray *script;
int stanzaCount;
static ABScript *ABScriptInstance = NULL;

+ (void)initialize {
    @synchronized(self) {
        if (ABScriptInstance == NULL) ABScriptInstance = [[ABScript alloc] init];
        [ABScriptInstance parseScriptFile];
    }
}



// This class is initialized via ABData

+ (void) initScriptWithDataArray:(NSArray *)scriptDataArray {
    script = scriptDataArray;
    stanzaCount = (int)[script count];
}

+ (NSMutableDictionary *) initScriptAndParseScriptFile {
    return [ABScriptInstance parseScriptFile];
}





/////////////////////////////////////
// PARSE FILES + BUILD DATA ARRAYS //
/////////////////////////////////////


// Create nested structure of word objects
- (NSMutableDictionary *) parseScriptFile {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"txt"];
    NSString *rawText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *rawStanzas = [rawText componentsSeparatedByString:@"\n\n\n"];

    NSMutableDictionary *scriptWordsDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *stanzas = [NSMutableArray array];
    NSMutableArray *stanzaObjs = [NSMutableArray array];
    
    for (int i = 0; i < [rawStanzas count]; i++) {
        
        NSMutableArray *lines = [NSMutableArray arrayWithArray: [rawStanzas[i] componentsSeparatedByString:@"\n"]];
        NSMutableArray *linesObjs = [NSMutableArray array];
        
        // Make certain punctuations their own word objects
        for (int j = 0; j < [lines count]; j++) {
            lines[j] = [lines[j] stringByReplacingOccurrencesOfString:@"-" withString:@" - "];
            lines[j] = [lines[j] stringByReplacingOccurrencesOfString:@", " withString:@" , "];
            lines[j] = [lines[j] stringByReplacingOccurrencesOfString:@"’s " withString:@" ’s "];
        }
        
        // Remove any empty lines in each stanza
        [lines removeObject:@""];
        
        // Split into words
        for (int j = 0; j < [lines count]; j++) {
            
            [linesObjs addObject:[NSMutableArray array]];
            lines[j] = [lines[j] componentsSeparatedByString:@" "];

            int thisLineCount = (int)[lines[j] count];
            BOOL connectNextWord = NO;
            ABScriptWord *lastWordObj = nil;
            
            for (int z = 0; z < thisLineCount; z++) {
                
                BOOL connectLastAndCurrent = NO;

                NSString *text = lines[j][z];
                NSMutableArray *sibs = [NSMutableArray array];
                
                if(z > 0) [sibs addObject:lines[j][z - 1]];
                if(z + 1 != thisLineCount) [sibs addObject:lines[j][z + 1]];
                
                if([text isEqualToString:@""]) continue;
                
                if([text isEqualToString:@"estropheeeeeeeeeeeeeeeeeeeeeeeees"]) {
                    NSArray *parts = [self specialHandlingForCrazyEeeWordWithSourceStanza:i];
                    [linesObjs[j] addObjectsFromArray:parts];
                    for (ABScriptWord *sw in parts) {
                        [scriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];
                    }
                    continue;
                }
                
                ABScriptWord *sw = [ABData getScriptWord:text withSourceStanza:i];
                // Don't check extra properties because we know it's from the original script.
                // If sometime later I modify this to allow importing other texts, I need to checkProperties here.

                if(connectNextWord) {
                    connectLastAndCurrent = YES;
                    connectNextWord = NO;
                }

                if([text isEqualToString:@","] ||
                   [text isEqualToString:@"’s"] ||
                   [text isEqualToString:@"'s"] ) {
                    sw.marginLeft = NO;
                    connectLastAndCurrent = YES;
                }

                if([text isEqualToString:@"-"]) {
                    sw.marginLeft = NO;
                    sw.marginRight = NO;
                    connectLastAndCurrent = YES;
                    connectNextWord = YES;
                }
                
                if(connectLastAndCurrent && lastWordObj != nil) {
                    [sw addLeftSister:[lastWordObj text]];
                    [lastWordObj addRightSister:text];
                }
                
                lastWordObj = sw;
                [linesObjs[j] addObject:sw];
                
                [scriptWordsDictionary setObject:[ABScriptWord copyScriptWord:sw] forKey:text];
            }
        }
        
        // Add the cleaned and parsed array of word objects
        stanzaObjs[i] = [NSArray arrayWithArray:linesObjs];
        stanzas[i] = [NSArray arrayWithArray:lines];
    }
    
    script = [NSArray arrayWithArray:stanzaObjs];
    stanzaCount = (int)[stanzas count];

//    [ABData setABScriptWordsDictionary:scriptWordsDictionary];
    NSMutableDictionary *scriptData = [[NSMutableDictionary alloc] init];
    [scriptData setObject:script forKey:@"script"];
    [scriptData setObject:scriptWordsDictionary forKey:@"scriptWordsDictionary"];
    
    return scriptData;
    
}


- (NSArray *) specialHandlingForCrazyEeeWordWithSourceStanza:(int)stanza {
    
    ABScriptWord *sw1 = [ABData getScriptWord:@"estroph" withSourceStanza:stanza];
    ABScriptWord *sw2 = [ABData getScriptWord:@"eeeeeeeeeeeeeeeeeeeeeee" withSourceStanza:stanza];
    ABScriptWord *sw3 = [ABData getScriptWord:@"ees" withSourceStanza:stanza];
    
    sw1.marginRight = NO;
    sw2.marginLeft = NO; sw2.marginRight = NO;
    sw3.marginLeft = NO;
    
    [sw1 addRightSister:sw2.text];
    [sw2 addLeftSister:sw1.text];
    [sw2 addRightSister:sw3.text];
    [sw3 addLeftSister:sw2.text];
    
    return @[sw1, sw2, sw3];
}





/////////////
// GETTERS //
/////////////


+ (NSArray *) linesAtStanzaNumber:(int)stanza {
    if(stanza >= [script count]) return script[[script count] - 1];
    if(stanza < 0) return script[0];
    NSArray *scriptStanza = script[stanza];
    if([scriptStanza count] > [ABState numberOfLinesToDisplay]) {
        scriptStanza = [scriptStanza subarrayWithRange:NSMakeRange(0, [ABState numberOfLinesToDisplay])];
    }
    
    return script[stanza];
}

+ (NSArray *) wordsAtStanzaNumber:(int)stanza andLineNumber:(int)line {
    if(script[stanza][line]) {
        return script[stanza][line];
    } else {
        return [ABScript emptyLine];
    }
}

+ (NSArray *) emptyLine {
    return @[];
}

+ (int) lastStanzaIndex {
    return (int)[script count] - 1;
}

+ (int) firstStanzaIndex {
    return 0;
}

+ (int) scriptStanzasCount {
    return stanzaCount;
}

+ (int) totalStanzasCount {
    return stanzaCount + 1;
}


+ (NSArray *) allWordsInLines:(NSArray *)stanza {
    NSMutableArray *words = [NSMutableArray array];
    for(int l=0; l < [stanza count]; l ++) {
        NSArray *line = [stanza objectAtIndex:l];
        for(int w=0; w < [line count]; w ++) {
            [words addObject:[line objectAtIndex:w]];
        }
    }
    return [NSArray arrayWithArray:words];
}


+ (ABScriptWord *) randomScriptWordFromSet:(NSArray *)words {
    return [words objectAtIndex:ABI((int)[words count])];
}


+ (ABScriptWord *) trulyRandomWord {
    return [ABData getRandomScriptWord];
}








///////////////////////
// BASIC LINE MIXING //   (for loop-point stanza)
///////////////////////


+ (NSArray *) mixStanzaLines:(NSArray *)oldStanzaLines withStanzaAtIndex:(int)stanzaIndex {
    
    NSArray *lines1 = oldStanzaLines;
    NSArray *lines2 = script[stanzaIndex];
    
    NSMutableArray *remixStanza = [NSMutableArray array];
    
    for(int l=0; l<[lines1 count]; l++) {
        
        NSMutableArray *remixLine = [NSMutableArray array];
        
        NSArray *line1 = [lines1 objectAtIndex:l];
        NSArray *line2 = [lines2 objectAtIndex:l];
        
        int c1 = (int)[line1 count];
        int c2 = (int)[line2 count];
        
        int larger = (c1 > c2) ? c1 : c2;
        
        for(int i=0; i < larger; i++) {
            int r = ABI(2);
            
            if((r == 0 && i < c1)) {
                [remixLine addObject:[line1 objectAtIndex:i]];
            } else if((r == 1 && i < c2)) {
                [remixLine addObject:[line2 objectAtIndex:i]];
            }
        }
        
        [remixStanza addObject:remixLine];
    }
    
    return [NSArray arrayWithArray:remixStanza];
}









//////////////
// GRAFTING //
//////////////


+ (NSArray *) parseGraftArrayIntoScriptWords:(NSArray *)words {
    
    NSMutableArray *scriptWords = [NSMutableArray array];
    
    for(int i=0; i<[words count]; i++) {
        ABScriptWord *sw = [ABData scriptWord:words[i] stanza:-1 fam:words leftSis:nil rightSis:nil graft:YES check:YES];
        [scriptWords addObject:sw];
    }
    
    return [NSArray arrayWithArray:scriptWords];
}



+ (NSArray *) graftText:(NSArray *)scriptWords intoStanzaLines:(NSArray *)stanzaLines {

    int slc = (int)[stanzaLines count];
    int gtc = (int)[scriptWords count];
    
    NSMutableArray *mixedLines = [NSMutableArray array];
    for(int l=0; l<slc; l++) {
        NSMutableArray *line = [NSMutableArray array];
        BOOL spent = NO;
        for(int i=0; i < [stanzaLines[l] count]; i++) {
            if(spent == NO && ABI(11) == 0) {
                ABScriptWord *w = [ABScriptWord copyScriptWord:scriptWords[ABI(gtc)]];
                w.isGrafted = YES;
                [line addObject:w];
            }
            [line addObject:stanzaLines[l][i]];
        }
        [mixedLines addObject:line];
    }
    
    return [NSArray arrayWithArray:mixedLines];
}




@end


