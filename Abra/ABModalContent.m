//
//  ABModalContent.m
//  Abra
//
//  Created by Ian Hatcher on 7/7/15.
//  Copyright (c) 2015 Ian Hatcher. All rights reserved.
//

#import "ABModalContent.h"
#import "ABFlow.h"
#import "ABUI.h"


@implementation ABModalContent


+ (ABFlow *) tipWelcome:(ABFlow *)flow {
    [flow addHeading:@"WELCOME TO ABRA!"];    
    [flow addParagraph:@"This app is a poetry instrument/spellbook that responds to touch."];
    [flow addParagraph:@"Caress the words and watch them shift under your fingers. Spin the rainbow dial to navigate. Touch the top of the screen for tools."];
    [flow addParagraph:@"There are many ways to interact with Abra. Read, write, and experiment to discover Abra's secrets and make her poems your own."];
    [flow addItalicParagraph:@"(Tap outside this box to close it.)"];
    [flow refreshFrame];
    return flow;
}

+ (ABFlow *) tipGraft:(ABFlow *)flow {
    [flow addHeading:@"GRAFTING"];
    [flow addParagraph:@"You are about to graft words for the first time."];
    [flow addParagraph:@"Type anything in the box that appears. You may enter multiple words if you wish; separate them by spaces. Once you've closed the box, draw with your finger to write onto the screen."];
    [flow addParagraph:@"Abra will learn and remember new words — of any alphabet."];
    [flow refreshFrame];
    return flow;
}

+ (ABFlow *) tipSpellMode:(ABFlow *)flow {
    [flow addHeading:@"SPELL MODES"];
    [flow addParagraph:@"The four icons on the left side of the toolbar are Spell Modes. Tap or drag your finger across the text to cast the spell you just selected."];
    [flow refreshFrame];
    return flow;
}

+ (ABFlow *) tipCadabra:(ABFlow *)flow {
    [flow addHeading:@"CADABRA"];
    [flow addParagraph:@"Pressing the Cadabra button, as you just did, casts an unpredictable spell."];
    [flow addParagraph:@"There are many possible Cadabra effects. Some Cadabras only occur under unusual conditions, or after you have done certain things."];
    [flow addParagraph:@"You can also cast Cadabras by pressing and holding your finger on magic words within the text."];
    [flow refreshFrame];
    return flow;
}






+ (ABFlow *) infoTitleLogos:(ABFlow *)flow {
    [flow addImage:@"abra_emboss_sub.png"];
    [flow addAuthors];
    [flow addSectionMargin];
    [flow addImageToBottom:@"abra_logos_12.png"];
    return flow;
}


+ (ABFlow *) infoContent:(ABFlow *)flow {

    [flow addHeading:@"INTRODUCTION"];
    [flow addParagraph:@"The Abra app is a poetry instrument/spellbook that responds to touch. Caress the words and watch them shift under your fingers."];
    [flow addParagraph:@"At the bottom of the screen is a rainbow dial, by which you can navigate to different poems in the Abra cycle. Touch the top of the screen to reveal a toolbar."];
    [flow addParagraph:@"There are many ways to interact with Abra. Read, write, and experiment to discover Abra's secrets and make her poems your own."];
    [flow addSectionMargin];
    
    [flow addHeading:@"OVERVIEW"];
    [flow addParagraph:@"Abra is a multifaceted project supported by an Expanded Artists’ Books grant from the Center for Book and Paper Arts, Columbia College Chicago. Its two main manifestations are this app, free for iPad and iPhone, and a limited-edition clothbound artists’ book. The two can be read separately or together, with an iPad inserted into a slot in the back of the book."];
    [flow addParagraph:@"Abra's main text was composed by Amaranth Borsuk and Kate Durbin. The app was designed and coded by Ian Hatcher. Art direction and decision-making for both artists’ book and app were undertaken in tandem as a trio."];
    [flow addParagraph:@"For more information on the conceptual framework of the project, and us, please see our site:"];
    [flow addLink:@"http://a-b-r-a.com"];
    [flow addSectionMargin];
    
    [flow addHeading:@"ABRA: THE APP"];
    [flow addParagraph:@"This app is designed to be at once a book, a toy, an instrument, and a tool for writing poetry. You can learn how it works by playing."];
    [flow addParagraph:@"A few things to try: press and hold your finger on one of the top bar icons, or on any word in the main text. Swipe from the left or right screen edges of the screen. Paste pages of pre-existing text into the graft box. Create poems of your own with Abra and tweet them to us @AbraApp. Follow us on Twitter to see others' creations retweeted:"];
    [flow addLink:@"http://twitter.com/AbraApp"];
    [flow addSectionMargin];

    [flow addHeading:@"ABRA: THE ARTISTS' BOOK"];
    [flow addParagraph:@"The Abra artists' book, published jointly alongside this app, features blind letterpress impressions, heat-sensitive disappearing ink, foil-stamping, and laser-cut openings. These last can serve as windows, revealing the screen of an embedded iPad running this app, conjoining the analog and digital into a single reading experience."];
    if([ABUI isIphone]) {
        [flow addImage:@"artists_book_iphone.png"];
    } else {
        [flow addImage:@"artists_book_ipad.png"];
    }
    [flow addImageMargin];
    [flow addParagraph:@"The artists' book was fabricated by Amy Rabas at the Center for Book and Paper Arts, with help from graduate students in Inter-Arts."];
    [flow addParagraph:@"To learn more about this edition or order a copy:"];
    [flow addLink:@"http://a-b-r-a.com/artists-book"];
    [flow addSectionMargin];
    
    [flow addHeading:@"ABRA: THE PAPERBACK"];
    [flow addParagraph:@"In addition to the app and the limited-edition artist’s book, Abra is available widely as a trade paperback from 1913 Press."];
    [flow addParagraph:@"In this edition, the poem’s stanzas meld one into the next, each recycling language from the preceding and animating as the reader turns the page. Illustrations by visual artist Zach Kleyn grow and mutate on facing pages, eventually reaching across the book’s gutter to meld with the text."];
    [flow addLink:@"http://www.journal1913.org/publications/abra/"];
    [flow addSectionMargin];
    
    [flow addHeading:@"ACKNOWLEDGEMENTS"];
    [flow addParagraph:@"We are grateful to the Center for Book and Paper Arts at Columbia College Chicago for their support of this work: Stephen Woodall, tireless mentor; Amy Rabas, visionary paper artist; and Clif Meador, Jessica Cochran, April Sheridan, Michelle Citron, and Paul Catanese, generous interlocutors."];
    [flow addParagraph:@"Additional gratitude to Abraham Avnisan, Steven Baughman, Danny Cannizaro, Samantha Gorman, Stephanie Strickland, Chris Wegman, and Paula Wegman for support and feedback on the app."];
    [flow addParagraph:@"We are also indebted to John Cayley, Brian Eno, and Peter Chilvers, whose ambient poetics informed our conception of this project from early stages."];
    [flow addSpecialItalicizedParagraph:@"Some of Abra's text appeared in slightly different form in Action, Yes!; The &Now Awards 3; Black Warrior Review; Bone Bouquet; The Collagist; Joyland Poetry; Lana Turner: A Journal of Poetry and Opinion; Lit; Peep/Show; SPECS; Spoon River Poetry Review; and VLAK."];
    [flow addSectionMargin];
    
    [flow addHeading:@"CONTACT"];
    [flow addParagraph:@"Comments, questions, bugs, spectacular screenshots? abraalivingtext@gmail.com"];
    [flow addSectionMargin];
    [flow adjustBottomMargin];
    
    [flow refreshFrame];
    return flow;
}



@end
