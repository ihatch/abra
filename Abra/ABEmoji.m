//
//  ABEmoji.m
//  Abra
//
//  Created by Ian Hatcher on 6/22/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABEmoji.h"
#import "emojis.h"
#import "ABConstants.h"
#import "ABScriptWord.h"
#import "ABData.h"


// Methods to split string that work with extended chars (emoji)
@interface NSString (ConvertToArray)
- (NSArray *)convertToArray;
- (NSMutableArray *) convertToMutableArray;
@end
@implementation NSString (ConvertToArray)
- (NSArray *)convertToArray {
    NSMutableArray *arr = [NSMutableArray array];
    NSUInteger i = 0;
    while (i < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *chStr = [self substringWithRange:range];
        [arr addObject:chStr];
        i += range.length;
    }
    return arr;
}
- (NSMutableArray *) convertToMutableArray {
    NSMutableArray *arr = [NSMutableArray array];
    NSUInteger i = 0;
    while (i < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *chStr = [self substringWithRange:range];
        [arr addObject:chStr];
        i += range.length;
    }
    return arr;
}
@end




@implementation ABEmoji

NSMutableDictionary *emojiIndex;
NSMutableDictionary *emojiByColor;
NSMutableDictionary *emojiByConcept;
NSMutableDictionary *emojiToWords;
NSMutableDictionary *wordsToEmoji;
NSArray *allEmoji;
NSDictionary *colorCycle;


+ (void) initEmoji {
    
    
    //    NSString *test = @"\U0001F34E";
    //    [test isEqualToString:@"🍎"];
    //    DDLogInfo(@"apple test: %i", [test isEqualToString:@"🍎"]);

    
    
    emojiIndex = [NSMutableDictionary dictionary];
    
    allEmoji = [@"😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤️💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐️☀️⛅️☁️⚡️☔️❄️⛄️🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎️📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛️⏰⌚️🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉️📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂️📌📎✒️✏️📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄️🎲🎯🏈🏀⚽️⚾️🎾🎱🏉🎳⛳️🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏤🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢⛵️🚤🚣⚓️🚀✈️💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠️🚧🔰⛽️🏮🎰♨️🗿🎪🎭📍🚩🇬🇧🇷🇺🇫🇷🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇺🇸🇺🇸1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯️🈳🈵🈴🈲🉐🈹🈺🈶🈚️🚻🚹🚺🚼🚾🚰🚮🅿️♿️🚭🈷🈸🈂Ⓜ️🛂🛄🛅🛃🉑㊙️㊗️🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔️✳️❇️❎✅✴️💟🆚📳📴🅰🅱🆎🅾💠➿♻️♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🏧💹💲💱©®™❌‼️⁉️❗️❓❕❔⭕️🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦✖️➕➖➗♠️♥️♣️♦️💮💯✔️☑️🔘🔗➰〰〽️🔱◼️◻️◾️◽️▪️▫️🔺🔲🔳⚫️⚪️🔴🔵🔻⬜️⬛️🔶🔷🔸🔹" convertToArray];
    
    /*
     🎭 🇬 🇺 🇫 🇯 🇵 🇺 © ® ™
     MISSING EMOJI COLOR: ✔➡◻❄⌚⚫▪⛳⬛🎭™✉®↕🅿⌛⛅✒‼㊗©☝♥✖↙⁉
     ⬅↗▶⬆↪↘⬇⤴ℹ↔◀↩↖⤵
     */
    
    
    colorCycle = @{
        @(0): @"pink",
        @(1): @"pink",
        @(2): @"orange",
        @(3): @"orange",
        @(4): @"yellowFaces",
        @(5): @"yellowBody",
        @(6): @"yellowEtc",
        @(7): @"green",
        @(8): @"green",
        @(9): @"green",
        @(10): @"green2",
        @(11): @"green2",
        @(12): @"green2",
        @(13): @"teal",
        @(14): @"teal",
        @(15): @"teal",
        @(16): @"teal",
        @(17): @"teal",
        @(18): @"teal",
        @(19): @"blue",
        @(20): @"blue",
        @(21): @"blue",
        @(22): @"darkBlue",
        @(23): @"darkBlue",
        @(24): @"grayBlue",
        @(25): @"blue",
        @(26): @"black",
        @(27): @"black",
        @(28): @"clocks",
        @(29): @"blackAndWhite",
        @(30): @"blackAndWhite",
        @(31): @"purple",
        @(32): @"purple",
        @(33): @"purple",
        @(34): @"purple",
        @(35): @"purple",
        @(36): @"purple",
        @(37): @"pink",
        @(38): @"pink",
        @(39): @"pink",
        @(40): @"pink",
        @(41): @"pinkGirl",
        @(42): @"redAndWhite"
    };

    
    NSDictionary *colors = @{
        @"red": @"🍎🍅🍣🍓🍒🌹🌺🍄🍁👹👺💃🐙🐞🐾💋👄🌋🎈❤️💔☎☎🎒⏰👠📕📮🚗📌🚫♥️♦️⭕❌⁉️‼️❓❗💯💢♨️🔴🔺🔻🉐💮🎁👣♦❤❗♨☎️❗️⭕️",
        @"redAndWhite": @"📛🚨🎯⛔㊙️🈲🈵🈴🅰🅱🆎🆑🅾🆘㊙️㊗️🎴🈹🔞📵🚯🚱🚳🚷📍⛽️🚩🎪✂💌🐔🍫🍉🔇⛽🀄㊙⛔️✂️",
        @"orange": @"😡🍁🍂🐅🔥⚡️☀️🌅🌞🍅🍟🍊🏮💥🎃🎸🎻🏉🏀🚌⛵️⛵⛵🌆🌇🍹🍺🍻👘📙🉑🈶🈚️🈸🈺🈷✴️✴️📳📴🆚🚼🔸🔶⛺🔑🍑☀⚡🈚✴⛺️",
        @"yellowFaces": @"😀😁😂😃😄😅😆😇😉😊☺️😋😌😍😎😏😐😑😒😓😔😕😖😗😙😘😚😛😜😞😝😟😠😢😣😤😥😦😧😨😩😪😫😬😭😮😯😲😳😴😵😶😷😸😺😼😻😾😿🙀👦👶👧👨👩👩‍👩‍👦👰👱🎅💆💏👩‍❤️‍💋‍👩👨‍❤️‍💋‍👨☺",
        @"yellowBody": @"👏🙌👂👃👋👍👎☝️👆👇👈👉👌✌👊✊✋💪👐🙏✌️",
        @"yellowEtc": @"🌻🌼🐯🐱🐤🐥⚡️🔥🌙☀️🌟⭐️🌕🌔🌖🌝🌛🌜🍋🌽🍋🍌🍟🍯👑✨💫💛🏆🎺🎷🎫🚕🚖🚚🚜🚤📀💰💊✏️📒🔆🔅🔒🔓📣📢🚸⚠️〽️〽🔱🌾🐠🌓🌗📯🎁⚠⭐✏",
        @"tan": @"🐆🐕🐨🐌🐫🐪🐴🐒🙊🙉🐈🙈🐵🐰🍪🍢🍞🏉🎨🚃🏤📻💳🚪👢👒👝📜📔",
        @"lightBrown": @"🍕🍔🍗🍖🍤🍘",
        @"brown": @"🐂🐻🐺🐌🐡🍂🐎🏇🏇🏈🚪📦👞👜💼🍩🐗🐃💩📺☕",
        @"green": @"🌲🌳🍏🐛🍐🎾🌍🌎🌏",
        @"green2": @"🌱🌴🌵🌷🌿🍀🌾🐉🐲🐊🐍🐢🐸🎄🎋🎍💚🚛🏡🔋👒👗📗🈯️💹❇️✳️❎✅♻️✳🈯❇♻",
        @"teal": @"🚿🎿🐬🐳🏊🚣Ⓜ️🌏🌎🌍🏧🎽📘🌠🎇🎆💦💧🐟🗾🗻⛲💎📪📫📬📭🎽🚘🚙🎐🗽🌈💠🐠Ⓜ✈",
        @"blue": @"📘🛂🛃🛄🛅🈂🅿️🚾🚹♿️🚰🚭➿🌀🔷🔹🔵💙🌃💤♿☔",
        @"grayBlue": @"1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🚻🚮⬅↗▶⬆↪↘⬇⤴ℹ↔◀↩↖⤵",
        @"darkBlue": @"👖🌌🌐🌊💺⚓️👕👤👥👔❄️🐋⚓",
        @"purple": @"😈👿👾☔️💜🌉👚🔮🈳🆔♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🎵♓♍♊♉♋♐♏♒♈♌♎♑☔",
        @"pink": @"👅💅🌸🌺🌷🐷🐽🐙🍇🎀💕💞💓💗💖💘💝💟🌂👛👙🚺💄",
        @"pinkGirl": @"🙆💁🙅🙋🙎🙍💆💇",
        @"white": @"👻💀👽👀🐁🐭🐓🐐🐇🐏🐼☁️⛅️❄️💨🍨🍚🍼🍙☕️🍴🎌🎂⚾️🎲🎹🏁⚽️🎱🚆✈️📡💿📠📹📷🔫📓🔩🔪🔧📄📃📑🔭🔬📈📉📊✒️📂📁📏📐📎🔗🔎🔍📇💬💭📨📩✉️👟📰📖❕❔▫️⬜️◻️◽️💨☕️⚪️⚪⬜✉◽☁☕⛪▫⚾",
        @"whiteClocks": @"🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕛🕚🕜🕝🕞🕟🕠🕡🕢🕣🕥🕦🕧🕤⚪️⚪⚾",
        @"black": @"💂🌑🌒🌘🌚🚊🚉⌚️🎥📞🔌➕➖〰➗✖️✔️🔃🎓🎩💱💲➰🔚🔙🔛🔝🔜♠️♣️⚫️▪️⬛️◼️◾️🔍🔎🔗🌓🌗🎼🎶🚲🎮👓🎤♣◾♠◼⚫▪⬛",
        @"blackAndWhite": @"🏁🎹🔘🔲🔳☑️💣🍳🎱🎳🐼📼💻📟🚞🚓🔊🔉🔈🔇⚽☑⛄",
        @"misc": @"😰😱👲👳👮👷👴👵👼👸😽😹🚶🏃👫👪👬👭💑👯🙇👡💍🐶🐹🐮🐑🐘🐧🐦🐣🐚🐠🐄🐀🐖🐩💐⛄️🌁🎎🎏🎑🎉🎊💽💾📱🔔🔕⏳⌛️🔏🔐💡🔦🛁🛀🚽🔨🚬💉💴💵💷💶💸📲📧📥📤📝📋📅📆📚🔖🎬🎧🃏🀄️⛳️🚵🚴🏂🏄🎣🍵🍶🍸🍷🍝🍛🍱🍥🍜🍲🍡🍮🍦🍧🍰🍬🍭🍈🍍🍠🍆🏠🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏯🏰🏭🗼🌄🎠🎡⛲️🎢🚢🚀🚁🚂🚄🚅🚈🚇🚝🚋🚎🚍🚔🚒🚑🚐🚡🚟🚠💈🚏🚦🚥🚧🔰🎰🗿✔➡◻❄⌚⛳🎭™✉®↕🅿⌛⛅✒‼㊗©☝♥✖↙⁉"
        };

    
    
        // fucked:  🇬🇧🇷🇺🇫🇷🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇧🇷🇲🇴🇨🇳🇩🇰🇨🇭🇹🇷🇭🇰🇻🇳🇨🇴🇪🇸🇸🇦
    
    NSDictionary *concepts = @{
        @"forest": @"🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🎄🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳🌱🌱🌱🌱🌱🌱🌱🌱🌱🌿🌿🌿🌿🌿🌿🌿🌿🌿🌿🌿🌿🐛🐝🐜🐞🐌🍂🍂🌿🌾🍄🌵🌴🌰🌼🌸🌷🍀🌻🌺🍁🍃",
        @"chris": @"🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🐬🏊🏊🏊🏊🏊🏊🏊🏊🏊🚣💧💧💧💧💧💧💧💦💙☔🌀🐳🔷🔷🔷🔷🔹🔹🔹🔹🌴🌴🌴🌴🌴🐠🐠🐠🐠👙🚿🚰😘"
        };


    emojiByColor = [ABEmoji processEmojiDictionary:colors withType:@"color"];
    emojiByConcept = [ABEmoji processEmojiDictionary:concepts withType:@"concept"];
    
//    for(NSString *e in allEmoji) {
//        if([emojiIndex objectForKey:e] == nil) {
//            DDLogInfo(@"MISSING EMOJI COLOR: %@", e);
//        }
//    }

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
     
//    DDLogInfo(@"test");
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
    return emojis[arc4random() % [emojis count]];
}

+ (NSString *) getRandomEmojiStringWithColor:(NSString *)color {
    return [ABEmoji getRandomEmojiForKey:color inDictionary:emojiByColor];
}

+ (NSString *) getRandomEmojiStringWithConcept:(NSString *)concept {
    return [ABEmoji getRandomEmojiForKey:concept inDictionary:emojiByConcept];
}

+ (NSString *) getEmojiOfSameColorAsEmoji:(NSString *)emoji {
    NSMutableDictionary *eDict = [emojiIndex objectForKey:emoji];
    if(eDict == nil) {
        DDLogError(@"No emoji dict for: %@", emoji);
        return @"?";
    }
    
    NSArray *colors = [eDict objectForKey:@"color"];
    if(colors == nil) {
        DDLogError(@"No colors dict for: %@", emoji);
        return [ABEmoji getRandomEmojiForKey:@"misc" inDictionary:emojiByColor];
    }

    NSString *color = colors[arc4random() % [colors count]];
    return [ABEmoji getRandomEmojiForKey:color inDictionary:emojiByColor];
}

+ (BOOL) isEmoji:(NSString *)charString {
    BOOL wtf = [allEmoji containsObject:charString];
    return wtf;
}


+ (NSString *) emojiWordTransform:(NSString *)string {
    
    NSArray *e2w = [emojiToWords objectForKey:string];

    if(e2w != nil) {
        return e2w[arc4random() % [e2w count]];
    }
    
    NSArray *w2e = [wordsToEmoji objectForKey:string];

    if(w2e != nil) {
        return w2e[arc4random() % [w2e count]];
    }
    
    return nil;
}



+ (NSString *) getEmojiForStanza:(int)stanza {
    NSString *key = colorCycle[@(stanza)];
    return [ABEmoji getRandomEmojiStringWithColor:key];
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