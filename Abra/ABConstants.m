//
//  ABConstants.m
//  Abra
//
//  Created by Ian Hatcher on 12/14/13.
//  Copyright (c) 2013 Ian Hatcher. All rights reserved.
//

#include <stdlib.h>
#import "ABConstants.h"


//////////////////
// GLOBAL UTILS //
//////////////////

CGFloat ABF(CGFloat multiplier) {
    return ((float)rand() / RAND_MAX) * multiplier;
}
int ABI(int max) {
    return (int) arc4random_uniform(max);
}




///////////////
// CONSTANTS //
///////////////

@implementation ABConstants


int const ABRA_START_LINE = 0;
int const ABRA_START_STANZA = 0;

CGFloat const ABRA_NORMAL_SPEED = 1.0;
CGFloat const ABRA_SLOWEST_SPEED = 1.5;
CGFloat const ABRA_FASTEST_SPEED = 0.2;
CGFloat const ABRA_SPEED_CHANGE_INTERVAL = 0.25;
CGFloat const ABRA_SPEED_GRAVITY_FAST = 0.01;
CGFloat const ABRA_SPEED_GRAVITY_SLOW = 0.03;

CGFloat const ABRA_BASE_STANZA_TIME = 9.0;
CGFloat const ABRA_WORD_ANIMATION_SPEED = 1100;
CGFloat const ABRA_WORD_FADE_OUT_DURATION = 400;
CGFloat const ABRA_WORD_FADE_IN_DURATION = 400;

CGFloat const ABRA_GESTURE_FEEDBACK_FADE_DURATION = 0.65;
CGFloat const ABRA_GESTURE_TIME_BUFFER = 0.75;
CGFloat const ABRA_TICKER_INTERVAL = 0.2;

NSString *const ABRA_FONT = @"IM FELL Great Primer PRO";
NSString *const ABRA_ITALIC_FONT = @"IM_FELL_Great_Primer_PRO_Italic";
NSString *const ABRA_FLOWERS_FONT = @"IM FELL FLOWERS 2";
NSString *const ABRA_SYSTEM_FONT = @"EuphemiaUCAS";


// --------------------------------------------------------------------

NSString *const SYMBOLS_CHESS = @"♜♞♝♛♚♝♞♜♟♟♟♟♟♟♟♟♙♙♙♙♙♙♙♙♖♘♗♕♔♗♘♖";
NSString *const SYMBOLS_DEATH = @"☠☣☢♱♱♱♱";

NSString *const BLOCK_BLACK_BOX = @"“Why am I always being asked to prove these systems aren't secure?\nThe burden of proof ought to be on the vendor.\nYou ask them about the hardware. “Secret.”\nThe software? “Secret.”\nWhat's the cryptography?\n“Can't tell you because that'll compromise the secrecy of the machines.\"\nFederal testing procedures? “Secret.”\nResults of the tests? “Secret.”\nBasically, we are required to have blind faith.”\n- Dr. David L. Dill\nProfessor, Computer Sciences, Stanford University";

NSString *const WORDS_DONE_HERE = @"done here mountaintop removal done here apocalypse done things are done have this purge for good for good a mountaintop gone a morgue for minerals we are all done enough done over overdone tree dome tree down first word past cut high cut dome a fragile film of flesh encasing a deadly dream machine intersection of nullification out of no where - no, where? nowhere nomenclature o yemen i am sorry memetopia arrange orange these distasteful deaths internal memetics arsenic do you know my referents sparrow web trapdoor spider springing spines radial interactive liquefying bubbling book lung there is no narrative in the moment of a strike there is only there and not there (and) variation how it plunges across bands and stations revolutions and decomposition bombs bursting in embolism redacting necklacing microwave goodbye bug squashing in a self-contained unit an ant swims for its dizzy life in a small cup succumbs to its surroundings immersion in sticky ichoric pests disassociated from empathy ok pets crop circles who do those appear to be tracking slaves in slums trading sales drone pilot wipes away sweat in a bathroom living breathing tile coated in the scum of the earth immolating itself as power grows along gridlines settling ceramic firing squadrons flying tripping on their heights splitting and bleeding out crushing cartiledge off the edge into flattened affect";

NSString *const WORDS_SPEAK = @"speak as clearly as you can say what as clearly as you can say what is as clearly as is can say what is clearly as is clearly say what what is clearly as you can speak in stability speak in recline speaker speak in clear cans wire singer speak as clearly as you can transmit over clear-eyed cable speak as clear as can you as clearly speak can you as clearly as speak can you speak as clearly as speak clearly as can you speak clearly you speak speak in a snowstorm speak in an ice castle speak in a dead computer speak in a diamond mine speak in a silver lining speak in an empty node speak in a speaker i can hear what you are saying i hear what you are communicating saying as clearly as you can i hear it as clearly as i can clearly i hear clearly you can speak as clearly as you can speak as clearly as you can it is the right you have left";

NSString *const WORDS_COLOR_BARS = @"in a church of color bars which have lost color which have become figure on ground stained glass opens a seascape a final dream a balcony trust forms which come in pairs key values radio storm flood of cats delineated and taxonomized box them up and seal them in chambers don't remember last forever don't remember last forever don't remember last forever don't remember last forever don't remember last forever don't remember last forever";

NSString *const WORDS_ATTENTION = @"in attention span problem things which interest us, not the other way around the attention space is an image, and that image is [muffled] we are our own attention to way the workers own the harvest mechanism attention, inattention [repeat] it is broken the program is jarring field of dots drone opening unending perception of a drone in time perception of perception of time defined by its very steady unyielding potential energy sublime force infinite pessimism pushing inward on itself visual field autonomous as an object rectangular viewport crushing inward on the eye distance is closed";

NSString *const WORDS_SYNC_RATES = @"insecting alignments insects phasing sync establishing sync rates phase lock loop secrecy contact the offal planets - i > drive > ii the becoming lesser > the lesser of the direction what is a narrative without a clenching schism a specter an implied harmonic center an EQ in which the rot fraying has been eliminated boss is proximity effect high pass low the sky and cut satellites from orbit the satellites see stitch data to data to discrete scenes alarm amalgamation of perception and record a grid as a lattice but carved out: what is absent compress but what is [] the selfless self antithesis of a frequency added to that frequency is no ping scythe wincing calm sky, calm place what could be more powerful than a perfect repeating calm a drone at the center of an atlas flat fleet closed layers fold and glibe into a flat sheath a sealed and locked comment a harbor of * in which each in which each maintains its present distances a bend of spectacle to a stillness perpetual clasp sexual exercise excision dust bomb";

NSString *const WORDS_NETWORK = @"in a network the nightmare of the undefined the fall of the crusher the inner contradiction of the hydraulic press the deliminting crusher yet speed drive of electrons the rush of blood skin them perpetuity is newer such as such but time is effort to maintain it enter drone bees at work defined their hive against the wasp by smothering rising temperatures maximum toleration of buzz of a fire starting bling flire licking flaming tongues clipped like wings by the edges of a video screen";

NSString *const WORDS_PYTHON = @"does a python of power have an ethical obligation to constrict itself? salmon rot on the banks of the river the hollow 2D plane of a crushed object viewport exiting speak from that voiceless place palace of time slapped running on the blood fuel of its slaves let's be real and call a slave a spade dig tunnels to ports of entry lawyer of gloves canvass verify meta lawyer a seperating drive or a substitute as a deficit under office enter port and clean it out empty into it port dump eat of that port pollen";

NSString *const WORDS_PERIMETER = @"systemic collection waves rippling to cancel screams out of phase with itself its own antithesis an ouroboros zero mouth speaking perimeter of a slick black hole looks to its edge a hunger of dying bugs impossible creeping along the rim of the mirror which only reflects itself to itself an infinite loop of recursive deferral irresponsibility void returning void this loop of perpetual motion feeding on that which it can only see (and does not touch)";

NSString *const WORDS_STING = @"in stinging a bee is ripped in half buzzing frantic bees form a coat to smother not to collectively sting orange";


NSString *const EMOJI_REGEX = @"[\U00002712\U00002714\U00002716\U0000271d\U00002721\U00002728\U00002733\U00002734\U00002744\U00002747\U0000274c\U0000274e\U00002753-\U00002755\U00002757\U00002763\U00002764\U00002795-\U00002797\U000027a1\U000027b0\U000027bf\U00002934\U00002935\U00002b05-\U00002b07\U00002b1b\U00002b1c\U00002b50\U00002b55\U00003030\U0000303d\U0001f004\U0001f0cf\U0001f170\U0001f171\U0001f17e\U0001f17f\U0001f18e\U0001f191-\U0001f19a\U0001f201\U0001f202\U0001f21a\U0001f22f\U0001f232-\U0001f23a\U0001f250\U0001f251\U0001f300-\U0001f321\U0001f324-\U0001f393\U0001f396\U0001f397\U0001f399-\U0001f39b\U0001f39e-\U0001f3f0\U0001f3f3-\U0001f3f5\U0001f3f7-\U0001f4fd\U0001f4ff-\U0001f53d\U0001f549-\U0001f54e\U0001f550-\U0001f567\U0001f56f\U0001f570\U0001f573-\U0001f579\U0001f587\U0001f58a-\U0001f58d\U0001f590\U0001f595\U0001f596\U0001f5a5\U0001f5a8\U0001f5b1\U0001f5b2\U0001f5bc\U0001f5c2-\U0001f5c4\U0001f5d1-\U0001f5d3\U0001f5dc-\U0001f5de\U0001f5e1\U0001f5e3\U0001f5ef\U0001f5f3\U0001f5fa-\U0001f64f\U0001f680-\U0001f6c5\U0001f6cb-\U0001f6d0\U0001f6e0-\U0001f6e5\U0001f6e9\U0001f6eb\U0001f6ec\U0001f6f0\U0001f6f3\U0001f910-\U0001f918\U0001f980-\U0001f984\U0001f9c0\U00003297\U00003299\U000000a9\U000000ae\U0000203c\U00002049\U00002122\U00002139\U00002194-\U00002199\U000021a9\U000021aa\U0000231a\U0000231b\U00002328\U00002388\U000023cf\U000023e9-\U000023f3\U000023f8-\U000023fa\U000024c2\U000025aa\U000025ab\U000025b6\U000025c0\U000025fb-\U000025fe\U00002600-\U00002604\U0000260e\U00002611\U00002614\U00002615\U00002618\U0000261d\U00002620\U00002622\U00002623\U00002626\U0000262a\U0000262e\U0000262f\U00002638-\U0000263a\U00002648-\U00002653\U00002660\U00002663\U00002665\U00002666\U00002668\U0000267b\U0000267f\U00002692-\U00002694\U00002696\U00002697\U00002699\U0000269b\U0000269c\U000026a0\U000026a1\U000026aa\U000026ab\U000026b0\U000026b1\U000026bd\U000026be\U000026c4\U000026c5\U000026c8\U000026ce\U000026cf\U000026d1\U000026d3\U000026d4\U000026e9\U000026ea\U000026f0-\U000026f5\U000026f7-\U000026fa\U000026fd\U00002702\U00002705\U00002708-\U0000270d\U0000270f]|[#]\U000020e3|[*]\U000020e3|[0]\U000020e3|[1]\U000020e3|[2]\U000020e3|[3]\U000020e3|[4]\U000020e3|[5]\U000020e3|[6]\U000020e3|[7]\U000020e3|[8]\U000020e3|[9]\U000020e3|\U0001f1e6[\U0001f1e8-\U0001f1ec\U0001f1ee\U0001f1f1\U0001f1f2\U0001f1f4\U0001f1f6-\U0001f1fa\U0001f1fc\U0001f1fd\U0001f1ff]|\U0001f1e7[\U0001f1e6\U0001f1e7\U0001f1e9-\U0001f1ef\U0001f1f1-\U0001f1f4\U0001f1f6-\U0001f1f9\U0001f1fb\U0001f1fc\U0001f1fe\U0001f1ff]|\U0001f1e8[\U0001f1e6\U0001f1e8\U0001f1e9\U0001f1eb-\U0001f1ee\U0001f1f0-\U0001f1f5\U0001f1f7\U0001f1fa-\U0001f1ff]|\U0001f1e9[\U0001f1ea\U0001f1ec\U0001f1ef\U0001f1f0\U0001f1f2\U0001f1f4\U0001f1ff]|\U0001f1ea[\U0001f1e6\U0001f1e8\U0001f1ea\U0001f1ec\U0001f1ed\U0001f1f7-\U0001f1fa]|\U0001f1eb[\U0001f1ee-\U0001f1f0\U0001f1f2\U0001f1f4\U0001f1f7]|\U0001f1ec[\U0001f1e6\U0001f1e7\U0001f1e9-\U0001f1ee\U0001f1f1-\U0001f1f3\U0001f1f5-\U0001f1fa\U0001f1fc\U0001f1fe]|\U0001f1ed[\U0001f1f0\U0001f1f2\U0001f1f3\U0001f1f7\U0001f1f9\U0001f1fa]|\U0001f1ee[\U0001f1e8-\U0001f1ea\U0001f1f1-\U0001f1f4\U0001f1f6-\U0001f1f9]|\U0001f1ef[\U0001f1ea\U0001f1f2\U0001f1f4\U0001f1f5]|\U0001f1f0[\U0001f1ea\U0001f1ec-\U0001f1ee\U0001f1f2\U0001f1f3\U0001f1f5\U0001f1f7\U0001f1fc\U0001f1fe\U0001f1ff]|\U0001f1f1[\U0001f1e6-\U0001f1e8\U0001f1ee\U0001f1f0\U0001f1f7-\U0001f1fb\U0001f1fe]|\U0001f1f2[\U0001f1e6\U0001f1e8-\U0001f1ed\U0001f1f0-\U0001f1ff]|\U0001f1f3[\U0001f1e6\U0001f1e8\U0001f1ea-\U0001f1ec\U0001f1ee\U0001f1f1\U0001f1f4\U0001f1f5\U0001f1f7\U0001f1fa\U0001f1ff]|\U0001f1f4\U0001f1f2|\U0001f1f5[\U0001f1e6\U0001f1ea-\U0001f1ed\U0001f1f0-\U0001f1f3\U0001f1f7-\U0001f1f9\U0001f1fc\U0001f1fe]|\U0001f1f6\U0001f1e6|\U0001f1f7[\U0001f1ea\U0001f1f4\U0001f1f8\U0001f1fa\U0001f1fc]|\U0001f1f8[\U0001f1e6-\U0001f1ea\U0001f1ec-\U0001f1f4\U0001f1f7-\U0001f1f9\U0001f1fb\U0001f1fd-\U0001f1ff]|\U0001f1f9[\U0001f1e6\U0001f1e8\U0001f1e9\U0001f1eb-\U0001f1ed\U0001f1ef-\U0001f1f4\U0001f1f7\U0001f1f9\U0001f1fb\U0001f1fc\U0001f1ff]|\U0001f1fa[\U0001f1e6\U0001f1ec\U0001f1f2\U0001f1f8\U0001f1fe\U0001f1ff]|\U0001f1fb[\U0001f1e6\U0001f1e8\U0001f1ea\U0001f1ec\U0001f1ee\U0001f1f3\U0001f1fa]|\U0001f1fc[\U0001f1eb\U0001f1f8]|\U0001f1fd\U0001f1f0|\U0001f1fe[\U0001f1ea\U0001f1f9]|\U0001f1ff[\U0001f1e6\U0001f1f2\U0001f1fc]";




@end
