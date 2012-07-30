//
//  GlobalHeaders.h
//  Stixx
//
//  Created by Bobby Ren on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Stixx_GlobalHeaders_h
#define Stixx_GlobalHeaders_h

#define STATUS_BAR_SHIFT 0 // the distance from the y coordinate of the visible camera and the actual y coordinate in screen - bug/hack!
// status_bar_shift disappears if tabbarcontroller is manually sized
#define STATUS_BAR_SHIFT_OVERLAY 20 // for views that become camera's overlay, we need this 20 px shift: pixPreview, stixEditor, tabbarcontroller
#define USING_FLURRY 1

#define LAZY_LOAD_BOUNDARY 0
#define USE_PULL_TO_REFRESH 1

#define USE_HIGHRES_SHARE 0

#define PIX_WIDTH 314.0
#define PIX_HEIGHT 282.0

#define HAS_PROFILE_BUTTON 0

#define ADMIN_TESTING_MODE 1
#define VERBOSE 0
#define ADMIN_USER_SET [NSMutableSet setWithObjects:@"Bobby Ren", @"Will Ho", @"Original Stixster", @"Art Stixster", @"Cute Stixster", @"Mit Renegade", nil]
#define IS_ADMIN_USER(x) [ADMIN_USER_SET containsObject:x]
#define ADMIN_FBID @"701860"

#define LEFT_LABEL_TAG 1001000
#define RIGHT_LABEL_TAG 1002000
#define TIME_LABEL_TAG 1003000
#define PHOTO_TAG 1004000 // tag is going to be combined with comment index...hack: most comments possible: 999

// First Time User Experience - arrow and button clicking restrictions
#define SHOW_ARROW 0

// hack to make camera fill screen for a custom (shorter) tab bar
#define CAMERA_TRANSFORM_X 1.12412
#define CAMERA_TRANSFORM_Y 1.12412

#define FTUE_REDISPLAY_TIMER 10 // time before the message is redisplayed
#define NEWSCOUNT_DISPLAY_TIMER 5

enum {
    SUGGESTIONS_SECTION_FEATURED = 0,
    SUGGESTIONS_SECTION_FRIENDS = 1,
    SUGGESTIONS_SECTION_MAX
};

enum notification_bookmarks {
    NB_NEWSTIX = 0,
    NB_MESSAGE, 
    NB_NEWCOMMENT,
    NB_NEWGIFT,
    NB_PEELACTION,
    NB_UPDATECAROUSEL,
    NB_INCREMENTBUX,
    NB_NEWFOLLOWER,
    NB_ONLINE,
    NB_ONLINEREPLY,
    NB_NEWPIX
};

enum alertview_actions {
    ALERTVIEW_SIMPLE = 0,
    ALERTVIEW_UPGRADE,
    ALERTVIEW_NOTIFICATION,
    ALERTVIEW_PROMPT,
    ALERTVIEW_GOTOSTORE,
    ALERTVIEW_BUYBUX
};

enum actionsheet_tags {
    ACTIONSHEET_TAG_ADMIN = 1000,
    ACTIONSHEET_TAG_SHAREPIX,
    ACTIONSHEET_TAG_BUYBUX,
    ACTIONSHEET_TAG_MAX
};

// for remixing
enum {
    REMIX_MODE_NEWPIC, // adding stix to the original pix
    REMIX_MODE_USEORIGINAL, // adding stix using a blank slate - remixing from blank
    REMIX_MODE_ADDSTIX // adding stix on top of existing stix - the real remix
};

enum {
    SHELF_CATEGORY_FIRST = 0,
    SHELF_CATEGORY_FACEFUN=0,
    SHELF_CATEGORY_MEME,
    SHELF_CATEGORY_CUTE,
    SHELF_CATEGORY_ANIMALS,
    SHELF_CATEGORY_COMICS,
    SHELF_CATEGORY_VIDEOGAMES,
    SHELF_CATEGORY_HIPSTER,
    SHELF_CATEGORY_MAX
};

// profile users search
enum profile_search_mode {
    PROFILE_SEARCHMODE_FIND,
    PROFILE_SEARCHMODE_INVITE,
    PROFILE_SEARCHMODE_SEARCHBAR
};
enum profile_service {
    PROFILE_SERVICE_FACEBOOK,
    PROFILE_SERVICE_TWITTER,
    PROFILE_SERVICE_CONTACTS
};


#define STIX_ANIMALS @"babychick.png", @"baldeagle.png", @"bluecrab.png", @"brownbunny.png", @"butterfly2.png", @"butterfly3.png", @"capuchin.png", @"cat.png", @"cheladamonkeyface.png", @"chipmunk.png", @"dog_cleo.png", @"duck.png", @"fatlizard.png", @"fly.png", @"frog.png", @"frog2.png", @"giraffehead.png", @"goldfish.png", @"judgementalcat.png", @"kitten.png", @"kittenface.png", @"lazydog.png", @"lemurhead.png", @"lion.png", @"lioness.png", @"mallard.png", @"meerkat.png", @"monkeyface.png", @"monkeyface2.png", @"ostrichhead.png", @"owl.png", @"parrothead.png", @"peacock.png", @"penguin.png", @"redcardinal.png", @"rhino.png", @"shybear.png", @"sittingmonkey.png", @"snowowl.png", @"spider.png", @"spottedbunny.png", @"squirrel1.png", @"squirrel2.png", @"squirrel3.png", @"swan.png", @"zebra.png"
#define STIX_DESC_ANIMALS @"Baby Chick", @"Bald Eagle", @"Blue Crab", @"Brown Bunny", @"Butterfly", @"Butterfly", @"Capuchin", @"Cat", @"Chelada Monkeyface", @"Chipmunk", @"Golden Retriever", @"Duck", @"Fat Lizard", @"Fly", @"Frog", @"Frog", @"Giraffe Head", @"Gold Fish", @"Judgmental Cat", @"Kitten", @"Kitty Face", @"Lazy Dog", @"Lemur Head", @"Lion", @"Lioness", @"Mallard", @"Meerkat", @"Monkey Face", @"Monkey Face", @"Ostrich Head", @"Owl", @"Parrot Head", @"Peacock", @"Penguin", @"Red Cardinal", @"Rhino", @"Shy Bear", @"Sitting Monkey", @"Snow Owl", @"Spider", @"Spotted Bunny", @"Squirrel", @"Squirrel", @"Squirrel", @"Swan", @"Zebra"
#define STIX_COMICS @"ant.png", @"bomb.png", @"bone.png", @"bonk.png", @"brownanimeeyes.png", @"cartoonfly.png", @"chickenhero.png", @"chimpzilla.png", @"dynamite.png", @"evilrobot.png", @"exclamation.png", @"greenspaceman.png", @"hal.png", @"handgun.png", @"kaboom.png", @"kapow.png", @"lasergun.png", @"lightning.png", @"lightsword.png", @"longsword.png", @"milesanders_hook.png", @"milesanders_horns.png", @"milesanders_lobsterclaw.png", @"ninja2.png", @"ninjastar.png", @"pinkskull.png", @"plop.png", @"poof.png", @"pop.png", @"pow.png", @"question.png", @"rocket.png", @"shortsword.png", @"smack.png", @"speechbubble.png", @"stickfigure.png", @"thought_bubble.png", @"thud.png", @"thudd.png", @"zombiehead.png"
#define STIX_DESC_COMICS @"Ant", @"Bomb", @"Bone", @"Bonk", @"Brown Anime Eyes", @"Cartoon Fly", @"Chicken Hero", @"Chimpzilla", @"Dynamite", @"Evil Robot", @"Exclamation", @"Green Space Guy", @"Hal",  @"Handgun", @"Kaboom", @"Kapow", @"Laser Gun", @"Lightening", @"Light Sword", @"Long Sword", @"Pirate Hook", @"Devil Horns", @"Lobster Claw", @"Ninja", @"Ninja Star", @"Pink Skull", @"Plop", @"Poof", @"Pop", @"Pow", @"Question Mark", @"Rocket", @"Short Sword", @"Smack", @"Speech Bubble", @"Stick Figure", @"Thought Bubble", @"Thud", @"Thudd", @"Zombie Head"
#define STIX_CUTE @"abstractbubbles.png", @"abstractsun.png", @"babychick2.png", @"babypenguin.png", @"bemine.png", @"blue_splash.png", @"blueflower.png", @"bluepenguin.png", @"bunchofstars.png", @"cartoonpig.png", @"cheekymonkey.png", @"cherryblossomrabbits.png", @"flowerpower.png", @"giraffe.png", @"green_splash.png", @"happylemon.png", @"hearts1.png", @"heartsplenty.png", @"hippo.png", @"inksplash.png", @"ladybug.png", @"littlebear.png", @"milesanders_bird.png", @"milesanders_cat.png", @"milesanders_crab.png", @"milesanders_dog.png", @"milesanders_fish.png", @"milesanders_flower.png", @"milesanders_owl.png", @"milesanders_parrot.png", @"mole.png", @"musicnote.png", @"panda.png", @"panda2.png", @"panda3.png", @"pawprint.png", @"pink_splash.png", @"pinkballoon.png", @"pinkdolphin.png", @"pinkflower.png", @"pinkstar.png", @"purplebutterfly.png", @"rainbow.png", @"rainbow2.png", @"realteddybear.png", @"red_glowing_heart.png", @"redrose.png", @"smallwhale.png", @"snowflake.png", @"starexplode.png", @"swirlyribbons.png", @"teddy.png", @"teddyface.png", @"tulip.png", @"wackybear.png", @"yellowflowserborder.png"
#define STIX_DESC_CUTE @"Abstract Bubbles", @"Abstract Sun", @"Baby Chick", @"Baby Penguin", @"Be Mine", @"Blue Splash", @"Blue Flower", @"Blue Penguin", @"Bunch of Stars", @"Cartoon Pig", @"Cheeky Monkey", @"Cherry Blossom Rabbits", @"Flower Power", @"Giraffe", @"Green Splash", @"Happy Lemon", @"Hearts", @"Plenty of Hearts", @"Hippo", @"Ink Splash", @"Lady Bug", @"Little Bear", @"Green Bird", @"Purple Cat", @"Crab", @"Dog", @"Fish", @"Flower", @"Owl", @"Parrot", @"Mole", @"Music Note", @"Panda", @"Panda", @"Panda", @"Paw Prints", @"Pink Splash", @"Pink Balloon", @"Pink Dolphin", @"Pink Flower", @"Pink Star", @"Purple Butterfly", @"Rainbow", @"Rainbow",  @"Teddy Bear", @"Red Glowing Heart", @"Red Rose", @"Small Whale", @"Snow Flake", @"Star Explosion", @"Swirly Ribbons", @"Teddy", @"Teddy Face", @"Tulip", @"Wacky Bear", @"Yellow Flowers Border"
#define STIX_FACEFUN @"stache_fumanchu.png",@"stache_handlebar.png",@"stache_horseshoe.png",@"stache_oldman.png",@"stache_pencil.png",@"stache_walrus.png",@"stache_wedge.png",@"stache_western.png",@"stache_bushy.png", @"stache_rich.png", @"beard_scruffy.png", @"crown.png", @"drop.png", @"eye_scary.png",  @"eyes_bulging.png", @"eyes_creepycat.png", @"eyes_crossed.png", @"eyes_puppy.png", @"furryears.png", @"glasses_3d_glasses.png", @"glasses_aviatorglasses.png", @"glasses_catglasses.png", @"eyepatch.png", @"hair_afro.png", @"hair_blondshort.png", @"hair_blondwithbangs.png", @"hair_brownbangs.png", @"hair_brownlong.png", @"hair_celebrityboy.png", @"hair_curlylongblond.png", @"hair_dreadlocks.png", @"hair_eurostyle.png", @"hair_platinumblond.png", @"hair_redshorthair.png", @"hair_shortblondcosplayhair.png", @"hair_shortblondguy.png", @"hair_shortblue.png", @"hair_spikyblondcosplay.png", @"hat_browncap.png", @"hat_brownstripedcap.png", @"hat_fedora.png", @"hat_tophat.png", @"hockeymask.png", @"kiss.png", @"mouth_buckteeth.png", @"mouth_toothy.png", @"mouth_toothy2.png", @"mouth_uglyteeth.png", @"mouth_vampirefangs.png", @"nerdytie.png", @"openmouth.png", @"partyhat.png", @"polarbearhat.png", @"surprised_eyes.png", @"bandaid.png", @"blooddrip.png" 
#define STIX_DESC_FACEFUN @"Fumanchu Mustache",@"Handlebar Mustache",@"Horseshoe Mustache",@"Old Man Mustache",@"Pencil Mustache",@"Walrus Mustache",@"Wedge Mustache",@"Western Mustache",@"Bushy Mushtache", @"Rich Mustache", @"Scruffy Beard", @"Crown", @"Tear Drop", @"Scary Eye", @"Bulging Eyes", @"Creepy Cat Eyes", @"Crossed Eyes", @"Puppy Eyes", @"Furry Ears", @"3D Glasses", @"Aviator Glasses", @"Cat Glasses", @"Eye Patch", @"Afro", @"Short Blond Hair", @"Blond Hair with Bangs", @"Brown Hair with Bangs", @"Long Brown Hair", @"Celebrity Boy Hair", @"Curly Long Blond Hair", @"Dreadlocks", @"Euro Style Hair", @"Plantinum Blond Hair", @"Red Short Hair", @"Short Blond Cosplay Hair", @"Short Blond Guy's Hair", @"Short Blue Hair", @"Spikey Hair", @"Brown Cap", @"Brown Striped Hat", @"Fedora", @"Top Hat", @"Hockey Mask", @"Kiss", @"Buck Teeth", @"Toothy Mouth", @"Toothy Smile", @"Ugly Teeth", @"Vampire Fangs", @"Nerdy Tie", @"Open Mouth", @"Party Hat", @"Polar Bear Hat",  @"Surprised Eyes", @"Band Aid", @"Blood Drip"
#define STIX_MEMES @"areyoukiddingme.png", @"asianfather.png", @"badluckbrian.png", @"mybrainisfull.png", @"nyancat.png", @"photogenicguy.png", @"themostinterestingman.png", @"yodawg.png", @"areyouseriousface.png", @"chubbybaby.png", @"lol.png", @"derp.png", @"fail.png", @"ftw.png", @"guy_fawkes.png", @"happycutenessoverload.png", @"happysmileyface.png", @"foreveralone.png", @"lolface.png", @"megusta.png", @"noface.png", @"okayguy.png", @"omg.png", @"pleaseface.png", @"pokerface.png", @"skepticalbaby.png", @"sleepingbabyface.png", @"successkid.png", @"trollface.png", @"woodface.png", @"yolo.png", @"yunoguy.png",  @"censored.png", @"derpeyes.png", @"rawchicken.png"
#define STIX_DESC_MEMES @"Are You Kidding Me Face", @"High Expectations Asian Father", @"Bad Luck Brian", @"My Brain is Full", @"Nyan Cat", @"Ridiculously Photogenic Guy", @"The Most Interesting Man", @"Yo Dawg", @"Are You Serous", @"Chubby Baby", @"LOL", @"DERP", @"FAIL", @"FTW", @"Guy Fawkes Mask", @"Happy Cuteness Overload", @"Happy Smiley Face",  @"Forever Alone", @"LOL Face", @"Me Gusta", @"No Face", @"Okay Guy", @"OMG", @"Please", @"Poker Face", @"Skeptical Baby", @"Sleeping Baby Face", @"Success Kid", @"Troll Face", @"Wood Face", @"YOLO", @"Y U NO", @"Censored Bar", @"DERP eyes", @"Raw Chicken"
#define STIX_VIDEOGAMES @"cubeangry.png", @"cubecool.png", @"cubekiss.png", @"cubeshocked.png", @"cubesick.png", @"cubesilly.png", @"cubesmile.png", @"cubewink.png", @"game_coin.png", @"game_shroom.png", @"gamecontroller.png", @"gameinvader.png", @"gametower.png", @"handcursor.png", @"isobuilding.png", @"mariostar.png", @"minecraft.png", @"pacmangreen.png", @"pirates_chest.png", @"pressbutton.png", @"redfireball.png", @"robohead.png", @"tallisotower.png", @"tetris1.png", @"tetris2.png", @"tetris3.png", @"videogame_pipe.png"
#define STIX_DESC_VIDEOGAMES @"Angry Cube", @"Cool Cube", @"Kissy Cube", @"Shocked Cube", @"Sick Cube", @"Silly Cube", @"Smiley Cube", @"Wink Cube", @"Game Coin", @"Game Shroom", @"Game Controller", @"Game Invader", @"Game Tower", @"Hand Cursor", @"Isometric Building", @"Game Star", @"Mine Cube", @"Green Ghost", @"Pirates Chest", @"Press Button", @"Red Fireball", @"Robo Head", @"Tall Isometric Tower", @"Puzzle Game Piece", @"Puzzle Game Piece", @"Puzzle Game Piece", @"Game Pipe"

#endif
