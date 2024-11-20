//
//  ABEmoji.m
//  Abra
//
//  Created by Ian Hatcher on 6/22/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//
//  Special emoji handling.


#import "ABEmoji.h"
#import "emojis.h"
#import "ABConstants.h"
#import "ABScriptWord.h"
#import "ABData.h"
#import "NSString+ABExtras.h"

#import "EmojiHelper.h"
#import "MyEmojiCategory.h"


@implementation ABEmoji

NSMutableDictionary *emojiIndex;
NSMutableDictionary *emojiByColor;
NSMutableDictionary *emojiByConcept;
NSMutableDictionary *emojiToWords;
NSMutableDictionary *wordsToEmoji;

NSArray<MyEmojiCategory *> *emojiCategories;
NSMutableDictionary *emojis;
NSMutableDictionary *emojisFitzToGeneric;
NSMutableDictionary *emojisByCategory;
NSMutableArray *emojisByFitz;

NSArray *allEmoji;
NSDictionary *colorCycle;


+ (void) initEmoji {
    
    emojiIndex = [NSMutableDictionary dictionary];
    
    colorCycle = @{
        @(0): @"RED",
        @(1): @"PINK",
        @(2): @"ORANGE",
        @(3): @"ORANGE",
        @(4): @"YELLOW_FACES",
        @(5): @"YELLOW_BODY",
        @(6): @"YELLOW_ETC",
        @(7): @"TAN",
        @(8): @"LT_GREEN",
        @(9): @"LT_GREEN",
        @(10): @"LT_GREEN",
        @(11): @"GREEN",
        @(12): @"GREEN",
        @(13): @"GREEN",
        @(14): @"TEAL",
        @(15): @"TEAL",
        @(16): @"TEAL",
        @(17): @"TEAL",
        @(18): @"TEAL",
        @(19): @"BLUE",
        @(20): @"BLUE",
        @(21): @"BLUE",
        @(22): @"BLUE",
        @(23): @"PALE_BLUE",
        @(24): @"PALE_BLUE",
        @(25): @"DK_BLUE",
        @(26): @"DK_BLUE",
        @(27): @"BLACK",
        @(28): @"BLACK",
        @(29): @"PURPLE",
        @(30): @"PURPLE",
        @(31): @"PURPLE",
        @(32): @"PURPLE",
        @(33): @"PURPLE",
        @(34): @"PURPLE",
        @(35): @"PURPLE",
        @(36): @"PURPLE",
        @(37): @"PINK",
        @(38): @"PINK",
        @(39): @"PINK",
        @(40): @"PINK",
        @(41): @"PINK_GIRL",
        @(42): @"RED_WHITE"
    };

    
    NSDictionary *colors = @{
        @"RED": @"🍎🍅🍣🍓🍒🌹🌺🍄🍁👹👺💃🐙🐞🐾💋👄🌋🎈❤️💔☎☎🎒⏰👠📕📮🚗📌🚫♥️♦️⭕❌⁉️‼️❓❗💯💢♨️🔴🔺🔻🉐💮🎁👣♦❤❗♨☎️❗️⭕️",
        @"RED_WHITE": @"📛🚨🎯⛔㊙️🈲🈵🈴🅰🅱🆎🆑🅾🆘㊙️㊗️🎴🈹🔞📵🚯🚱🚳🚷📍⛽️🚩🎪✂💌🐔🍫🍉🔇⛽🀄㊙⛔️✂️",
        @"ORANGE": @"😡🍁🍂🐅🔥⚡️☀️🌅🌞🍅🍟🍊🏮💥🎃🎸🎻🏉🏀🚌⛵️⛵⛵🌆🌇🍹🍺🍻👘📙🉑🈶🈚️🈸🈺🈷✴️✴️📳📴🆚🚼🔸🔶⛺🔑🍑☀⚡🈚✴⛺️",
        @"YELLOW_FACES": @"😀😁😂😃😄😅😆😇😉😊☺️😋😌😍😎😏😐😑😒😓😔😕😖😗😙😘😚😛😜😞😝😟😠😢😣😤😥😦😧😨😩😪😫😬😭😮😯😲😳😴😵😶😷😸😺😼😻😾😿🙀👦👶👧👨👩👩‍👩‍👦👰👱🎅💆💏👩‍❤️‍💋‍👩👨‍❤️‍💋‍👨☺",
        @"YELLOW_BODY": @"👏🙌👂👃👋👍👎☝️👆👇👈👉👌✌👊✊✋💪👐🙏✌️",
        @"YELLOW_ETC": @"🌻🌼🐯🐱🐤🐥⚡️🔥🌙☀️🌟⭐️🌕🌔🌖🌝🌛🌜🍋🌽🍋🍌🍟🍯👑✨💫💛🏆🎺🎷🎫🚕🚖🚚🚜🚤📀💰💊✏️📒🔆🔅🔒🔓📣📢🚸⚠️〽️〽🔱🌾🐠🌓🌗📯🎁⚠⭐✏",
        @"TAN": @"🐆🐕🐨🐌🐫🐪🐴🐒🙊🙉🐈🙈🐵🐰🍪🍢🍞🏉🎨🚃🏤📻💳🚪👢👒👝📜📔",
        @"LT_BROWN": @"🍕🍔🍗🍖🍤🍘",
        @"BROWN": @"🐂🐻🐺🐌🐡🍂🐎🏇🏇🏈🚪📦👞👜💼🍩🐗🐃💩📺☕",
        @"LT_GREEN": @"🌲🌳🍏🐛🍐🎾🌍🌎🌏",
        @"GREEN": @"🌱🌴🌵🌷🌿🍀🌾🐉🐲🐊🐍🐢🐸🎄🎋🎍💚🚛🏡🔋👒👗📗🈯️💹❇️✳️❎✅♻️✳🈯❇♻",
        @"TEAL": @"🚿🎿🐬🐳🏊🚣Ⓜ️🌏🌎🌍🏧🎽📘🌠🎇🎆💦💧🐟🗾🗻⛲💎📪📫📬📭🎽🚘🚙🎐🗽🌈💠🐠Ⓜ✈",
        @"BLUE": @"📘🛂🛃🛄🛅🈂🅿️🚾🚹♿️🚰🚭➿🌀🔷🔹🔵💙🌃💤♿☔",
        @"PALE_BLUE": @"1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🚻🚮⬅↗▶⬆↪↘⬇⤴ℹ↔◀↩↖⤵",
        @"DK_BLUE": @"👖🌌🌐🌊💺⚓️👕👤👥👔❄️🐋⚓",
        @"PURPLE": @"😈👿👾☔️💜🌉👚🔮🈳🆔♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🎵♓♍♊♉♋♐♏♒♈♌♎♑☔",
        @"PINK": @"👅💅🌸🌺🌷🐷🐽🐙🍇🎀💕💞💓💗💖💘💝💟🌂👛👙🚺💄",
        @"PINK_GIRL": @"🙆💁🙅🙋🙎🙍💆💇",
        @"WHITE": @"👻💀👽👀🐁🐭🐓🐐🐇🐏🐼☁️⛅️❄️💨🍨🍚🍼🍙☕️🍴🎌🎂⚾️🎲🎹🏁⚽️🎱🚆✈️📡💿📠📹📷🔫📓🔩🔪🔧📄📃📑🔭🔬📈📉📊✒️📂📁📏📐📎🔗🔎🔍📇💬💭📨📩✉️👟📰📖❕❔▫️⬜️◻️◽️💨☕️⚪️⚪⬜✉◽☁☕⛪▫⚾",
        @"WHITE_CLOCKS": @"🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕛🕚🕜🕝🕞🕟🕠🕡🕢🕣🕥🕦🕧🕤⚪️⚪⚾",
        @"BLACK": @"💂🌑🌒🌘🌚🚊🚉⌚️🎥📞🔌➕➖〰➗✖️✔️🔃🎓🎩💱💲➰🔚🔙🔛🔝🔜♠️♣️⚫️▪️⬛️◼️◾️🔍🔎🔗🌓🌗🎼🎶🚲🎮👓🎤♣◾♠◼⚫▪⬛🐜",
        @"BLACK_WHITE": @"🏁🎹🔘🔲🔳☑️💣🍳🎱🎳🐼📼💻📟🚞🚓🔊🔉🔈🔇⚽☑⛄",
        @"MISC": @"😰😱👲👳👮👷👴👵👼👸😽😹🚶🏃👫👪👬👭💑👯🙇👡💍🐶🐹🐮🐑🐘🐧🐦🐣🐚🐠🐄🐀🐖🐩💐⛄️🌁🎎🎏🎑🎉🎊💽💾📱🔔🔕⏳⌛️🔏🔐💡🔦🛁🛀🚽🔨🚬💉💴💵💷💶💸📲📧📥📤📝📋📅📆📚🔖🎬🎧🃏🀄️⛳️🚵🚴🏂🏄🎣🍵🍶🍸🍷🍝🍛🍱🍥🍜🍲🍡🍮🍦🍧🍰🍬🍭🍈🍍🍠🍆🏠🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏯🏰🏭🗼🌄🎠🎡⛲️🎢🚢🚀🚁🚂🚄🚅🚈🚇🚝🚋🚎🚍🚔🚒🚑🚐🚡🚟🚠💈🚏🚦🚥🚧🔰🎰🗿✔➡◻❄⌚⛳🎭™✉®↕🅿⌛⛅✒‼㊗©☝♥✖↙⁉"
        };

    
    
    
    NSDictionary *concepts = @{
        @"FOREST": @"🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🎄🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌱🌱🌱🌱🌱🌱🌱🌱🌱🌿🌿🌿🌿🌿🌿🌿🌿🌿🌿🌿🌿🐛🐝🐜🐞🐌🍂🍂🌿🌾🍄🌵🌴🌰🌼🌸🌷🍀🌻🌺🍁🍃",
        @"CHRIS": @"🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🏊🏊🏊🏊🏊🏊🏊🏊🏊🚣💧💧💧💧💧💧💧💦💙☔🌀🐳🔷🔷🔷🔷🔹🔹🔹🔹🌴🌴🌴🌴🌴🐠🐠🐠🐠👙🚿🚰😘",
        @"ANIMALS": @"🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩",
        @"PHOTOS": @"🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢",
        @"FRUIT": @"🍹🍎🍏🍊🍋🍒🍒🍇🍉🍓🍑🍈🍌🍐🍍",
        @"SWEETS": @"🍥🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯",
        @"AMERICA": @"🍺🍕🍔🍟🍦🌽",
        @"RICH": @"💸🐩🎩👠",
        @"FOOD": @"☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍠🍆🍅🌽"
    };


    emojiByColor = [ABEmoji processEmojiDictionary:colors withType:@"color"];
    emojiByConcept = [ABEmoji processEmojiDictionary:concepts withType:@"concept"];
    
    emojiToWords = [NSMutableDictionary dictionary];
    wordsToEmoji = [NSMutableDictionary dictionary];
    
    for(NSString *key in EMOJI_HASH) {
        NSString *emoji = [EMOJI_HASH objectForKey:key];
        [emojiToWords setObject:[NSMutableArray array] forKey:emoji];
        NSArray *words = [key componentsSeparatedByString:@" "];
        for(NSString *word in words) {
            if([wordsToEmoji objectForKey:word] == nil) {
                [wordsToEmoji setObject:[NSMutableArray array] forKey:word];
            }
            [[wordsToEmoji objectForKey:word] addObject:emoji];
            [[emojiToWords objectForKey:emoji] addObject:word];
        }
    }
    
    // TODO
    emojiCategories = [NSArray array]; //[EmojiHelper getEmoji];
    emojis = [NSMutableDictionary dictionary];
    emojisFitzToGeneric = [NSMutableDictionary dictionary];
    emojisByCategory = [NSMutableDictionary dictionary];
    emojisByFitz = [NSMutableArray array];
    emojisByFitz[0] = @"nope";
    emojisByFitz[1] = [NSMutableArray array];
    emojisByFitz[2] = [NSMutableArray array];
    emojisByFitz[3] = [NSMutableArray array];
    emojisByFitz[4] = [NSMutableArray array];
    emojisByFitz[5] = [NSMutableArray array];
    
    NSMutableArray *all = [NSMutableArray array];
    
    for(MyEmojiCategory *cat in emojiCategories) {
        NSString *catName = cat.name;
        if(catName == nil) continue;
        NSMutableArray *catEmojis = [NSMutableArray array];
        for(MyEmoji *e in cat.emoji) {
            NSDictionary *eDict = [NSMutableDictionary dictionary];
            [eDict setValue:catName forKey:@"category"];
            [eDict setValue:e.variations forKey:@"variations"];
            [emojis setObject:eDict forKey:e.emojiString];
            [catEmojis addObject:e.emojiString];
            [all addObjectsFromArray:e.variations];
            if([e.variations count] > 1) {
                for(int i=1; i < [e.variations count]; i ++) {
                    NSString *fitz = [e.variations objectAtIndex:i];
                    [emojisByFitz[i] addObject:fitz];
                    [emojisFitzToGeneric setValue:@{ @"emojiString": e.emojiString, @"fitz": [NSNumber numberWithInteger:i] } forKey:fitz];
                }
            }
            
        }
        [emojisByCategory setObject:catEmojis forKey:catName];
    }
    allEmoji = [NSArray arrayWithArray:all];
    
    
}




+ (NSMutableDictionary *) processEmojiDictionary:(NSDictionary *)stringDict withType:(NSString *)type {
    NSMutableDictionary *splitDict = [NSMutableDictionary dictionary];
    for(NSString *key in [stringDict allKeys]) {
        NSArray *emojiArray = [[stringDict objectForKey:key] convertToArray];
        [splitDict setValue:emojiArray forKey:key];
        for(NSString *emoji in [splitDict objectForKey:key]) {
            
            if([emojiIndex objectForKey:emoji] == nil) {
                [emojiIndex setObject:[NSMutableDictionary dictionary] forKey:emoji];
            }
            if([[emojiIndex objectForKey:emoji] objectForKey:type] == nil) {
                [[emojiIndex objectForKey:emoji] setObject:[NSMutableArray array] forKey:type];
            }

            [[[emojiIndex objectForKey:emoji] objectForKey:type] addObject:key];
        }
    }
    return splitDict;
}


+ (ABScriptWord *) emojiScriptWord:(NSString *)string {
    return [ABData scriptWord:string stanza:-1 fam:@[] leftSis:nil rightSis:nil graft:NO check:YES];
}

+ (NSString *) getRandomEmojiForKey:(NSString *)key inDictionary:(NSMutableDictionary *)dict  {
    NSArray *emojis = [dict objectForKey:key];
    return [ABEmoji getRandomEmojiInArray:emojis];
}

+ (NSString *) getRandomEmojiInArray:(NSArray *)emojis  {
    NSString *result = nil;
    int i = 0;
    while(i < 50 && result == nil) {
        result = emojis[arc4random() % [emojis count]];
        i ++;
    }
    if(result == nil) {
        result = @"?";
    }
    
    return result;
}

+ (NSString *) getRandomEmojiStringWithColor:(NSString *)color {
    NSString *e = [ABEmoji getRandomEmojiForKey:color inDictionary:emojiByColor];
    return e;
}

+ (NSString *) getRandomEmojiStringWithConcept:(NSString *)concept {
    return [ABEmoji getRandomEmojiForKey:concept inDictionary:emojiByConcept];
}

+ (NSString *) getEmojiOfSameColorAsEmoji:(NSString *)emoji {
    NSMutableDictionary *eDict = [emojiIndex objectForKey:emoji];
    if(eDict != nil) {
        
        NSArray *colors = [eDict objectForKey:@"color"];
        if(colors == nil) {
            NSLog(@"No colors dict for: %@", emoji);
            return [ABEmoji getRandomEmojiForKey:@"MISC" inDictionary:emojiByColor];
        }
        
        NSString *color = colors[arc4random() % [colors count]];
        return [ABEmoji getRandomEmojiForKey:color inDictionary:emojiByColor];

    } else {
        NSDictionary *generic = [emojisFitzToGeneric objectForKey:emoji];
        if(generic != nil) {
            NSInteger index = [(NSNumber *)[generic objectForKey:@"fitz"] integerValue];
            NSString *fitz = [ABEmoji getRandomEmojiInArray:[emojisByFitz objectAtIndex:index]];
            return fitz;
        }
        
        eDict = [emojis objectForKey:emoji];
        if(eDict == nil) {
            NSLog(@"No emoji dict for: %@", emoji);
            return @"?";
        }
        NSString *cat = [eDict valueForKey:@"category"];
        NSString *ret = [ABEmoji getRandomEmojiForKey:cat inDictionary:emojisByCategory];
        return ret;
    }
}

+ (BOOL) isEmoji:(NSString *)charString {
    return [allEmoji containsObject:charString];
}


+ (NSString *) emojiWordTransform:(NSString *)string {
    NSArray *e2w = [emojiToWords objectForKey:string];
    if(e2w != nil) return e2w[arc4random() % [e2w count]];
    NSArray *w2e = [wordsToEmoji objectForKey:string];
    if(w2e != nil) return w2e[arc4random() % [w2e count]];
    return nil;
}



+ (NSString *) getEmojiForStanza:(int)stanza {
    NSString *key = colorCycle[@(stanza)];
    NSString *e = [ABEmoji getRandomEmojiStringWithColor:key];
    if(e == nil) {
        NSLog(@"FAIL");
    }
    return e;
}




+ (NSString *) getEmojiForCurrentMoonPhase {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    int d = (int)[components day];
    int m = (int)[components month];
    int y = (int)[components year];
    int c, e;
    double jd;
    int b;
    
    if (m < 3) {
        y--;
        m += 12;
    }
    ++ m;
    c = 365.25 * y;
    e = 30.6 * m;
    jd = c + e + d - 694039.09; // jd is total days elapsed
    jd /= 29.53;                // divide by the moon cycle (29.53 days)
    b = jd;                     // int(jd) -> b, take integer part of jd
    jd -= b;                    // subtract integer part to leave fractional part of original jd
    b = jd * 8 + 0.5;           // scale fraction from 0-8 and round by adding 0.5
    b = b & 7;                  // 0 and 8 are the same so turn 8 into 0
    
    NSArray *phases = [@"🌑🌒🌓🌔🌕🌖🌗🌘" convertToArray];
    return [phases objectAtIndex:b];
}



@end
