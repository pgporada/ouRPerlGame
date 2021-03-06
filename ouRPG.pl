#!/usr/bin/env perl -w
use strict;

# http://perldoc.perl.org/open.html
# http://stackoverflow.com/questions/627661/how-can-i-output-utf-8-from-perl/627975#627975
use open qw/:std :utf8/;
use utf8;
use feature qw(say);
use Switch;
use Cwd;
my $abs_path = Cwd::abs_path($0);

use locale;
use Term::ANSIColor qw(:constants colored);
use Term::ExtendedColor qw(:all);
use Term::ReadKey;

my $user_color_choice = "sandybrown";
my $undiscovered = ' ';
my $revealed = fg('blue7','-');
my $impasse = fg($user_color_choice,'#');
my $shop = fg('yellow9','$');
my $count_NS = 0;
my $count_EW = 0;
my $is_shop = 0;
my $has_bomb = 0;
my $impasse01_cleared = 0;
my $impasse11_cleared = 0;
my $main_boss_dead = 0;
my $initialHelpScreen = 1;
my $haveMap = 0;
my $autoLook = 1;
my $autoMap = 0;
my $chest = 0;
my @talkToPerson;

my $ascii_explosion = << "EOL";
                             \\         .  ./
                           \\      .:";'.:.."   /
                               (M^^.^~~:.'").
                         -   (/  .    . . \\ \\)  -
  O                         ((| :. ~ ^  :. .|))
 |\\\\                     -   (\\- |  \\ /  |  /)  -
 |  T                         -\\  \\     /  /-
/ \\[_]..........................\\  \\   /  /
EOL
my $irs_guy_pic = << "EOL";
                      ,,,
                        i i'
                        \\~;\\
                         \\; \\
                          \\ ;\\    ====
                           \\ ;\\  ==== \\
                      __,--';;;\\-' (  0
                __,--';;; ;;; ;;\\      >
         __,--'\\\\ ;;; ;;; ;;; ;;;\\--__<
  _ _,--' __,--'\\\\  ;;; __,~~' \\ ;\\
 (_)|_,--' __,--'\\\\;,~~'        \\ ;\\
 |(_)|_,--'       ~~             \\; \\
 || |                             \\ ;\\
  |_/                              !~!,
                               .---'''---.
                               |   WWE   |
                               |   IRS   |
                               |   GUY   |
                               `---------'
EOL
my $struttin_guy_pic = << "EOL";
                 /
                /               .'
               /              .'
              /   ______.   .'
             /   / __/_//  '
            /   / /  c c
           /    \\ G    >                    _.-'
          /      \\/.  -                 _.-'
         /     .---\\  / --.         _.-'
        /     /     \\(     \\    _.-'
       /     /  \\    \\  (.  )  '
      /     /   /\\       \\ /
     /      \\  |  \\       \\               __..--''
    /   .'   \\_\\   )     )\\\\      __..--''
   /  .'      ) \\  |    /   \\  -''
  / .'   _   '///` (   /\\    \\
 /.' _.-'  __     /    ) )    )
 '.-'..--''      /   ,' /    /
  .__---------- /__./  /    / --------------------
     ``--..  __//  /   )   /
            /    _J)   /)`-\\
            `-__/-'  ` \\\\  |(
                        `\\   \\  -..__
                          `--'       ``--..__
                                             ``--
EOL
my $grim_reaper_statue_pic = << "EOL";
  ____,
 /.---|
 `    |     ___
     (=\\.  /-. \\
      |\\/\\_|"|  |
      |_\\ |;-|  ;
      | / \\| |_/ \\
      | )/\\/      \\
      | ( '|  \\   |
      |    \\_ /   \\
      |    /  \\_.--\\
      \\    |    (|\\`
       |   |     \\
       |   |      '.
       |  /         \\
       \\  \\.__.__.-._)
EOL
my $dirty_french_guy_pic = << "EOL";
                     ____...
            .-"--"""".__    `.
           |            `    |
 (         `._....------.._.:
  )         .()''        ``().
 '          () .=='  `===  `-.
  . )       (   <o>  <o>    g)
   )         )     /        J
  (          |.   /      . (
  \$\$         (.  (_'.   , )|`
  ||         |\\`-....--'/  ' \\
 /||.         \\\\ | | | /  /   \\.
//||(\\         \`-===-'  '     \\o.
.//7' |)         `. --   / (     OObaaaad888b.
(<<. / |     .a888b`.__.'d\\     OO888888888888a.
\\  Y' |    .8888888aaaa88POOOOOO888888888888888.
 \\  \\ |   .888888888888888888888888888888888888b
  |   |  .d88888P88888888888888888888888b8888888.
  b.--d .d88888P8888888888888888a:f888888|888888b
  88888b 888888|8888888888888888888888888\\8888888
EOL
my $birds_shitting_on_a_car_pic = << "EOL";
   `-.                      .
     \\`.            .       ``.
      \\\\`.         .'`.      `.`-.    ///
     _.`.\\`._ _..-'.'.'       `.  `--'_'_.
     =_`   ` "--..'.'         .-'   ._.-'
        `--.___.:; ;        , ,  _.-'
                 `v'        v  -'
    ----------..
     .     .-'  `.
    ';` .-'       `.
-------.-'      `..   `._
     \\`-.     '`    / .''''''\
      \\  `.        @.'      .'|
       \\.  `._ _..-'      .'  /|
         `.             .'  /L/
           `-.______.--'  /O/
                       |/L/
            _.-._      |/
        ---/.-"-.\\----'
           \\`._.'/\\/
             """
EOL
my $crows_pic = << "EOL";
                     __,---,
       .---.        /__|o\\  )       .-"-.      .----.""".
      /   6_6        `-\\ / /       / 4 4 \\    /____/ (0 )\
      \\_  (__\\         ,) (,       \\_ v _/      `--\\_    /
      //   \\\\         //   \\\\      //   \\\\         //   \\\\
     ((     ))       {(     )}    ((     ))       {{     }}
=======""===""=========""===""======""===""=========""===""=======
        |||            |||||         |||             |||
         |              |||           |              '|'
EOL
my $roaming_bovine_pic = << "EOL";
    ___,,,___ _..............._
    '-/~'~\\-'` :::::'   .::    \
      |a a |   ':::'     `::   ||
      |   /::.  :::.  .:::.  ::||
      (oo/::'  .::::..::::::.  /|
       `` '._   /:::'''::::' <`\\/
             | /`--....-'`Y   \\))
             |||         //'. |((
             |||        //   ||
             //(        `    /(
             ```             ``
EOL
my $juggalette_pic = << "EOL";
           __.------._
          .' -|  -   . `.
         / '.' `-. `     \\
        /  /      `.  ` \\ \\
       |  /         `.  \\  |
       |  |           `.   |
       |  |.---.   .---.\\  |
       | ||><@> ) ( <@><|` |
       |  |     / \\     || |
       |  |    ((_))    |  |
       | `|`  /     \\  '|  |
       |  |   _.---._   |  |
       /  \\    `---'    /  |
      /    `.    "    .'   \\
     / / | | `-.___.-' ||   \\
    /     '|           |  \\  \\
   /'  /   |           |\\   ` \\
  /   .  /-'           `--.__ \\\\
 / .-'| ||               |   `-.\\
/.'  / / |               |      `.
EOL
my $corporate_satan_pic = << "EOL";
   |     /\\  /\\
(  |  ) ( (__) )
 \\_|_/   \\@..@/
   |    __\\\\//__
   |\\  /   \\/   \\
   |\\\\/ (   |  ) |
   | \\_/|   | | |
   |    |   | |o|
   |    |==-==| |
   |    (     )_|
   |    |  |  |()
   |    |  |  |
   |    |  |  |
   |   _|  |  |_
   |  (___/ \\___)
EOL
my $impatient_waiter_pic = << "EOL";
                   [_________]
              ,,,,,      _|//
             , , ;;      ( /
            <    D        =o
            |.   /       /\\|
        _____|><|_______/o /
       / '==| :: |=='  <  /
      /  \\  <    >  /____/
     /  _/\\ | :: | /
      \\  ||_|____|/
       |o| |  x  |
       ( \\ / _'_ \
       ////   |   \
         |    |    |
         |    |    |
         |    |    |
         \\ _  |  _ /
          \\   |   /
           \\  |  /
            |_|_|
           /o | o\
          /o _|_ o\
         (__/   \\__)
EOL
my $icp_clown_pic = << "EOL";
     ,            _..._            ,
    {'.         .'     '.         .'}
   { ~ '.      _|=    __|_      .'  ~}
  { ~  ~ '-._ (___________) _.-'~  ~  }
 {~  ~  ~   ~.'           '. ~    ~    }
{  ~   ~  ~ /   /\\     /\\   \\   ~    ~  }
{   ~   ~  /    __     __    \\ ~   ~    }
 {   ~  /\\/  -<( o)   ( o)>-  \\/\\ ~   ~}
  { ~   ;(      \\/ .-. \\/      );   ~ }
   { ~ ~\\_  ()  ^ (   ) ^  ()  _/ ~  }
    '-._~ \\   (`-._'-'_.-')   / ~_.-'
        '--\\   `'._'"'_.'`   /--'
            \\     \\`-'/     /
             `\\    '-'    /'
               `\\       /'
                 '-...-'
EOL
my $skeleton_pic = << "EOL";
     _.--"""""--._
   .'             '.
  /                 \
 ;                   ;
 |                   |
 |                   |
 ;                   ;
  \\ (`'--,    ,--'`) /
   \\ \\  _ )  ( _  / /
    ) )(')/  \\(')( (
   (_ `""` /\\ `""` _)
    \\`"-, /  \\ ,-"`/
     `\\ / `""` \\ /`
      |/\\/\\/\\/\\/\\|
      |\\        /|
      ; |/\\/\\/\\| ;
       \\`-`--`-`/
        \\      /
         ',__,'
          q__p
          q__p
          q__p
          q__p
EOL
my $jbizzle_pic = << "EOL";
                     .
           /^\\     .
      /\\   "V"
     /__\\   I      O  o
    //..\\\\  I     .
    \\].`[/  I
    /l\\/j\\  (]    .  O
   /. ~~ ,\\/I          .
   \\\\L__j^\\/I       o
    \\/--v}  I     o   .
    |    |  I   _________
    |    |  I c(`       ')o
    |    l  I   \\.     ,/
  _/j  L l\\_!  _//^---^\\\\_
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EOL
my $lead_skeleton_pic = << "EOL";
                                           .""--.._
                                           []      `'--.._
                                           ||__           `'-,
                                         `)||_ ```'--..       \
                     _                    /|//}        ``--._  |
                  .'` `'.                /////}              `\\/
                 /  .""".\\              //{///
                /  /_  _`\\\\            // `||
                | |(_)(_)||          _//   ||
                | |  /\\  )|        _///\\   ||
                | |L====J |       / |/ |   ||
               /  /'-..-' /    .'`  \\  |   ||
              /   |  :: | |_.-`      |  \\  ||
             /|   `\\-::.| |          \\   | ||
           /` `|   /    | |          |   / ||
         |`    \\   |    / /          \\  |  ||
        |       `\\_|    |/      ,.__. \\ |  ||
        /                     /`    `\\ ||  ||
       |           .         /        \\||  ||
       |                     |         |/  ||
       /         /           |         (   ||
      /          .           /          )  ||
     |            \\          |             ||
    /             |          /             ||
   |\\            /          |              ||
   \\ `-._       |           /              ||
    \\ ,//`\\    /`           |              ||
     ///\\  \\  |             \\              ||
    |||| ) |__/             |              ||
    |||| `.(                |              ||
    `\\\\` /`                 /              ||
       /`                   /              ||
      /                     |              ||
     |                      \\              ||
    /                        |             ||
  /`                          \\            ||
/`                            |            ||
`-.___,-.      .-.        ___,'            ||
         `---'`   `'----'`
EOL
my $boner_pic = << "EOL";
  _     .-.
 ( `. .'   )
  `. `   /'
    |   |
    |   |
   _|69 |
  (__,  |
    L_,)|
      | |
    ,_/ |
    |   |
    |   |
   /     '.
  (   ,    )
   '-' '--'
EOL
# A robot named Y2DT , Yum Yum Tasty Donuts, he provides you with baked goods

my %playerChar = (
    NAME => '"Guy Playington"',
    CLASS => '"Human"',
    PORTRAIT => 'o',
    CURRENT_HP => '130',
    MAX_HP => '130',
    LVL => '1',
    DMG_MIN => '10',
    DMG_MAX => '20',
    CRIT_CHANCE => '15',
    CURRENT_XP => '0',
    NEXT_LVL_XP => '100',
    DEFENSE => '0',
    TYPICAL => 'N',
    EQUIPPED_LEFT => '',
    EQUIPPED_RIGHT => '',
    EQUIPPED_HEAD => '',
    EQUIPPED_BODY => '',
    GOLD => '100',
    );

my %charClass = (
    Dwarf     => { PORTRAIT => 'ö', DESC => 'This tiny Joe can fit in small crevices. Their short stature makes them hard to budge.'},
    Human     => { PORTRAIT => '@', DESC => 'Your average Joe. They can do what most other races can and can\'t'},
    Elf       => { PORTRAIT => '§', DESC => 'Your skinny pointy eared Joe. They\'re typically faster than most'},
    Orc       => { PORTRAIT => '&', DESC => 'Your typical ugly looking Joe. Orcs are tough and strong.'},
    Giant     => { PORTRAIT => 'Ö', DESC => 'Giants can reach the top of the refridgerator that old adventurers can no longer get to.'},
    Underling => { PORTRAIT => '_', DESC => 'Underlings slink by in the shadows and like to stay out of site. They like to go under things.'},
    Overling  => { PORTRAIT => '^', DESC => 'Overlings like to stay in shadows, but prefer to go over things.'},
    Wizard    => { PORTRAIT => 'ᐂ', DESC => 'Mutha fuckin wizards never die.'}
    );

my @monsterName = ("Boner","Corporate Satan","Skeleton","Impatient Waiter","Crows","IRS Guy","ICP Clown","Juggalette","Roaming bovine","Struttin guy","Grim Reaper Statue","Dirty French Guy","Birds shitting on a car");

my %monsterChar = (
        NAME => '',
        MAX_HP => '',
        CURRENT_HP => '',
        DMG_MIN => '',
        DMG_MAX => '',
        DEATH_XP => '',
        DEATH_GOLD => '',
    );

# Autovivification
my %items = (
        SWORD01 => {
            NAME => 'Long Sword',
            DESC => 'Your typical metal sword.',
            PRICE => '300',
            DMG => '12',
            TYPE => 'WEAPON',
        },
        SWORD02 => {
            NAME => 'Short Sword',
            DESC => 'A short sword for the short adventurer.',
            PRICE => '150',
            DMG => '6',
            TYPE => 'WEAPON',
        },
        HELMET01 => {
            NAME => 'Wool Cap',
            DESC => 'This wool cap will protect you from the slightest scratches.',
            PRICE => "125",
            DEF => '6',
            TYPE => 'HELMET',
        },
        HELMET02 => {
            NAME => 'Steel Helmet',
            DESC => 'This helmet will help protect your head.',
            PRICE => '350',
            DEF => '12',
            TYPE => 'HELMET',
        },
        ARMOR01 => {
            NAME => 'Leather Armor Mk.1',
            DESC => 'Your basic all leather apparel. Finely crafted from tanned brahmin hide.',
            PRICE => '170',
            DEF => '8',
            TYPE => 'ARMOR',
        },
        ARMOR02 => {
            NAME => 'Leather Armor Mk.2',
            DESC => "An enhanced version of the basic leather armor with extra layers of\nprotection. Finely crafted from tanned brahmin hide.",
            PRICE => '375',
            DEF => '14',
            TYPE => 'ARMOR',
        },
        OCARINA => {
            NAME => "THE Ocarina",
            DESC => "You see a blue transverse ocarina.",
            PRICE => "666",
            TYPE => "MISC",
        },
        MAP => {
            NAME => "a map",
            DESC => "Allows you to orient yourself in the world.",
            PRICE => "200",
            TYPE => "MISC",
        }
    );

my %quests = (
   # ESCAPE => {
  #     NAME => "Escape from wherever the hell you got warped into.",
   #     STATE_A => '2',
   #     STATE_B => '2',
   #     LOG_ENTRY_A1 => "Some shit",
   #     LOG_ENTRY_B1 => "Some other shit",
   #     LOG_ENTRY_A2 => "More shit",
   #     LOG_ENTRY_B2 => "The most shit",
   #     },
    MOVELOGS => {
        NAME => "Find a way past the fallen trees.",
        STATE_A => '0',
        STATE_B => '0',
        LOG_ENTRY_A1 => "The shopkeeper mentioned to go back to the burly guys.",
        LOG_ENTRY_B1 => "Some burly guys say that the path is blocked. I have to find a way around it.",
        LOG_ENTRY_A2 => "I've gotten the burly guys to clear a path and I can now head North from here.",
        LOG_ENTRY_B2 => "",
        },
    );

my @fightIntro = ("HALT!","I EAT PIECES OF SHIT LIKE YOU FOR BREAKFAST!","GARBAGE DAY!","C'MERE YOU!","WHY I OUGHTTA","I'M GONNA PASTEURIZE YOU!","I'M GONNA MURDA YA!","I'MA WARIO I'MA GONNA WEEN","I'M GUNNA MOYDA YA!","I'M GONNA FOLD YOUR CLOTHES WITH YOU IN 'EM","YOU WANNA SEE TOUGH? I'LL SHOW YOU TOUGH","I NEVER LOSE!","LEMME AT 'EM","I'M GONNA PARK MY CAR ON TOP OF YOU!","GET READY!","YOU HAVE HUGE GUTS!","RIP AND TEAR!","I'LL TURN YOU INTO A MEAT POPSICLE!","FRESH MEAT!","TO KILL OR NOT TO KILL?","BRING THE NOISE!","BRING THE PAIN!","FOR ZUUL!","YOU'RE FUCKING DEAD!","YOU'RE FUCKING WORMFOOD!");
my @fightWords = ("POW!","ZAP!","BLAMMO!","THUD!!","CRACK!", "BIFF!", "WHOOP","OVER 9000!!!", "BOOP", "BOP", "BLAM SLAM", "TOASTIEEE", "SHAZZAM!", "BANG!", "SPLAT!", "SHWOMP!", "BOING!", "GLAVEN!", "JINKIES!", "YOWZA!", "UHH! I FEEL GOOD!","BONK!","CLONK!","HHHWHACK!","HHHWWAAMM!","THUNK!!","KRUNCH!","MEOW!","SPREZCEHN ZE POW!","HUUU!","KABLAM!","BONK!","KLUNK!","THWACK!","OOOOFF!","ZAM!","ZOWIE!","SWOOSH!","PAM!","CRRAAACK!");
my @fightEnd = ("BURY ME WITH MY...MONEY","X_X","X_x","I'M GONNA TELL MY MOM!","HEY","RUDE :P <3 :)","*trumpet* WAAA WAAA WAAAAAAA","FUCK!", "SHITCOCKS!","DO IT!","SOMETIMES I JUST KILL MYSELF!","I'M BATMAN!","HOW DID YOU DO SUCH AMAZING STUNTS WITH SUCH LITTLE FEET?","NICE SHOT!","GOODBYE MR. $playerChar{NAME}!","HAPPY LANDINGS ASSHOLE!","THAT'LL DO IT!","ENOUGHH! ENOUGHHHH!","FOR ENGLAND?","I AM INVINCIBLE!","I SHOULD HAVE HAD BETTER LAST WORDS!","I REGRET NOTHING!");

push@{$playerChar{INVENTORY}},'Ocarina';



sub ENTER_PROMPT {
    say "\nPress ".BOLD.CYAN."[ENTER]".RESET." to continue";
    my $input = <STDIN>;
    if ($input !~ /\012/) { ENTER_PROMPT(); }
}

sub GAME_INTRO {
    system("clear");
    print "\n\n\n";
    printf ("%65s", "##############################################\n");
    printf ("%70s",  colored("Quest Through The Deathly Dungeon of Doom!", "bold"));
    print "\n";
    printf ("%65s", "##############################################\n");
    printf ("%65s", " Version: Best damn beta anyone's ever played\n");
    ENTER_PROMPT();
    system("clear");
    say "Welcome!\n";
    sleep 1;

    my $intro = "You're in a small room with one window. You notice a computer chair sitting in\nthe corner of the room. There is a table with a computer on it in the\nmiddle of the room. Behind you is a door.";
    say $intro;
    my $chairMoved = 0;
    my $tempVar = 0;
    my $tempName;
    my $input;
    while(1) {
        print "\nWhat would you like to do?\n".MAGENTA."%> ".RESET;
        $input = uc(<STDIN>);
        chomp($input);
        if ($chairMoved == 0 && ($input =~ m/^GET CHAIR$/ || $input =~ m/^MOVE CHAIR$/ || $input =~ m/^PUSH CHAIR/)) {
            say "You move the chair over to the table and sit down. You notice ";
            say "a big red button on the computer. There is a note on the table ";
            say "that reads in big letters, \"".BOLD."DO NOT TOUCH".RESET."\"";
            $chairMoved = 1;
            next;
        }
        elsif ($input =~ m/^LOOK$/) { say YELLOW."=> ".RESET."Seek and ye shall find. Where may not always be clear."; }
        elsif ($input =~ m/^LOOK WINDOW$/ || $input =~ m/^CHECK WINDOW$/) { say "You look out the window. You realize that you're several floors up in\na skyscraper. Their is a storm raging outside but you can make out the\ndim lights of cars and other businesses below. Squinting you can see\nthe corner of Base and 64th."}
        elsif ($input =~ m/^USE DOOR$/ || $input =~ m/^CHECK DOOR$/) {
            say "You jiggle the knob but the door is firmly shut. There is no lock on the inside.";
            if ($tempVar == 0) {
                say "There is a sliding viewport abd you knock on door. You see a pair of eyes stare back\nat you as the viewport opens up. A gruff voice asks for your name.";
                print ITALIC."\n\"What is your name?\"\n".RESET.MAGENTA."%> ".RESET;
                $tempName = uc(<STDIN>);
                chomp($tempName);
                say "\"Oh yeah, nice to meet you $tempName, it seems the door is stuck.\" You think about\nforcing it open.";
                $tempVar = 1;
            }
        }
        elsif ($input =~ m/^REPEAT$/) {
            say $intro;
        }
        elsif ($input =~ m/^FORCE THE DOOR/ || $input =~ m/^FORCE DOOR/) {
            if ($tempName !~ m/^RON/) {
                say "You get a running start and kick the door with everything you've got.\nThe door does not budge and your knee shatters completely. As you lay on the\nground screaming, the door falls and crushes you.\n\nYour days trapped in this room are over, but so is your life.";
            } else {
                say "You absolutely blow the door in half. The force of your kick blasts a shockwave through\nthe person that was on the other side and turns them into a fine mist of red against the\nback wall. You see an elevator and ride it down to freedom town.\n".BOLD."Congratulations!".RESET;
            }
            sleep 10;
            system("clear");
            exit;
        }
        elsif ($input =~ m/^WHERE$/) { say "TW92ZSB0aGUgY2hhaXIsIHByZXNzIHRoZSBidXR0b24sIGFuZCBjb25ncmF0cyBmb3IgZGVjb2RpbmcgdGhpcw=="; }
        elsif ($input =~ m/^SEEK$/) { say YELLOW."=> ".RESET."You didn't actually believe me did you?"; }
        elsif ($chairMoved == 1 && ($input =~ m/^USE COMPUTER$/ || $input =~ m/^PRESS BUTTON$/ || $input =~ m/^PUSH BUTTON$/ || $input =~ m/^TOUCH BUTTON$/)) {
            # Match the word before the first occurrence of white space. The \s* makes sure there's no white space at the beginning of the line JUSTIN CASE.
            $input =~ m/^\s*(\w+)/;
            say "You ".BOLD.$1.RESET" the button on the computer and it whirs to life.";
            last;
        } else {
            say YELLOW."=> ".RESET."I don't understand what you mean by ".BOLD.$input.RESET;
        }
    }

    #e it in front of the monitor, and sit down.\n\nYou notice a button on the computer.";
    ENTER_PROMPT();
    sleep 1;
    say ITALIC, "*Whhhhhiiiirrrrrrr*", RESET;
    sleep 1;
    say ITALIC, "*Vvvvvvvrrrrrrrrrrrrr*", RESET;
    sleep 2;
    say ITALIC, "*BzzzRRRRRrrzzttt*", RESET;
    sleep 3;
    say ITALIC, "*DING!*\n", RESET;
    say "Suddenly, a wild popup appears! ";
    say ITALIC."\"If only you had some computer repair flyers...\"".RESET." you think to yourself.";
    ENTER_PROMPT();

    say GREEN."=> ".RESET."Insert Coins because this computer takes coins. 1 play = ".YELLOW."3".RESET."gp\n";
    say "You think to yourself, \"That's strange, and proceed to check your pockets for some spare change.\"";
    say "In your pockets you find ".YELLOW.$playerChar{GOLD}.RESET."gp. How convienient!";

    my $coinCount = 1;
    my $stopCount = 0;
    while ($coinCount <= 3) {
        print GREEN." \$ ".RESET."Insert coin into cd drive? [", BOLD, "Y", RESET, "/", BOLD, "N", RESET, "] ";
        $input = uc(<STDIN>);
        chomp($input);
        if ($input =~ m/Y{1}E*S*/) {
            say GREEN." \$ ".RESET."You've inserted ".YELLOW.$coinCount.RESET."gp!";
            $coinCount += 1;
            $playerChar{GOLD} -= 1;
        }
        else {
            $stopCount += 1;
            if ($stopCount < 3) { say GREEN." \$ ".RESET."You know you want to play. I can hear ".YELLOW.$playerChar{GOLD}.RESET."gp in there."; }
            if ($stopCount == 2) { say GREEN." \$ ".RESET."Guess you want to quit, huh?"; }
            if ($stopCount == 3) { say GREEN." \$ ".RESET."Well rats\' off to ya then!"; }
        }
    }

    say "\n\n#-----------------------------------------------------------------#\n\n";
    say "\nThe computer displays a character creation screen.\nYou lean in close to take a look.\n\n";
    say "If you choose to take the default values, just press ".CYAN."[ENTER]".RESET;
    print GREEN." \$ ".RESET."What do they call you? ".YELLOW."=> ".RESET;
    $input = <STDIN>;
    chomp($input);
    if ($input) {
        $playerChar{NAME} = $input;
    }
    system("/usr/bin/afplay Sounds/EricGreene_charCreationScreen.wav &");
    say GREEN." \$ ".RESET."Welcome to the fray, ".BOLD.$playerChar{NAME}.RESET.".\n";
    say GREEN." \$ ".RESET."Choose your race. Currently the race is cosmetic but race traits and flaws will be added later.";
    say GREEN." \$ ".RESET."#---------------------------------------------------------- ------------------------------------------#";
    foreach (keys %charClass) {
        print GREEN." \$ ".RESET.BOLD;
        printf ("%-13s %-1s %-70s", $_.RESET, ":", $charClass{$_}{DESC});
        print "\n";
    }
    say GREEN." \$ ".RESET."#----------------------------------------------------------------------------------------------------#\n";
    print GREEN." \$ ".RESET."Enter ".BOLD."class name".RESET." to select a character ".YELLOW."=> ".RESET;
    $input = uc(<STDIN>);
    chomp($input);
    if ($input) {
        foreach my $var (keys %charClass) {
            if ($input =~ /^$var$/i) {
                $playerChar{CLASS} = $var;
                $playerChar{PORTRAIT} = $charClass{$var}{PORTRAIT};
                if (($playerChar{NAME} =~ m/JENNY/i || $playerChar{NAME} =~ m/BREAKDANCINGCAT/i || $playerChar{NAME} =~ m/JINGLES/i) && $playerChar{CLASS} =~ m/DWARF/i) {
                    say GREEN." \$ ".RESET."Typical. :P ".RED."<3".RESET;
                    $playerChar{TYPICAL} = "Y";
                }
                elsif ($playerChar{NAME} =~ m/^JENNY$/i && $playerChar{CLASS} =~ m/^GIANT$/i) {
                    say GREEN." \$ ".RESET."Maybe in your dreams :P ".RED."<3".RESET;
                }
                elsif ($playerChar{NAME} =~ m/PHILI*P*/i && $playerChar{CLASS} =~ m/GIANT/i) {
                    say GREEN." \$ ".RESET."Typical. :P ".RED."<3".RESET;
                    $playerChar{TYPICAL} = "Y";
                }
                last;
            }
        }
    }

    ENTER_PROMPT();
    say "As soon as you press the enter key, you get sucked in through the computer monitor.";
    say "Your heart is ".BLINK."pounding".RESET." so hard and you have trouble breathing.";
    say "You collapse onto the floor in a panic. As you bring your hands to your face you";
    say "notice something strange. You no longer have your normal hands. You're in control";
    say "of another body.".ITALIC."\"Did I get sucked into the game!?!?\"".RESET." your mind races.";
    say "The only way out of this mess is to see what the path ahead of you has in store\n";
    say "\n".ITALIC."\"If there's one thing for sure, it's that I, $playerChar{NAME} the $playerChar{CLASS} will find a way out of this mess.\"".RESET;
    ENTER_PROMPT();
}

sub FINALE {
    sleep 10;
    print "Will you marry me? ";
    my $input = <STDIN>;
    chomp ($input);
    if ($input =~ m/Y/i || $input =~ m/YES/i) {
        system("clear");
        say "\n\n\n\nMission Accomplished";
        system("open \"END.png\"");
        exit;
    } else {
        system("clear");
        print "\n\n\n\nReally?\n";
        exit;
    }
}

#Location on the grid = current X[0], current Y[1], previous X[2], previous Y[3], AoAIndexCount[4]
my @MapLoc = (0,0,0,0,0);
# data structure: X[0], Y[1], state[2], boss[3], exit N[4], exit S[5], exit E[6], exit W[7], enemy[8], tile[9]
# state[2] will be 0=undiscovered,1=discovered,2=impasse,3=shop
# enemy[8] will be 0=no enemy,1=enemy
# tile[9] will be 0=ascii_Up_Down, 1=ascii_Left_Right, 2=ascii_Top_Left_Corner, 3=ascii_Bottom_left_Corner, 4=ascii_Top_Right_Corner , 5=ascii_Bottom_Right_Corner, 6=ascii_3Way
# For the tiles, when you enter the room and it determines what your exits are, it will print the correct tile. [NOT DONE]
# Not every room will have an enemy. There will be a post-enter and pre-leave check done for each room. There will be a percentage chance of not encountering a monster in the room if there is an enemy. This percentage can be based off of a character stat or something later down the line. If there is an enemy in the room but you successfully escape the post check, you'll still need to encounter the pre-leave check. If you pass both, then consider yourself lucky ;) and may you live to fight another day. [NOT DONE]
my @MapAoA = ( [0,0,1,0,0,1,0,0,0,0], #[0] array.
	           [1,0,2,0,0,1,1,0,1,0], #[1] array..
	           [2,0,0,0,0,1,1,0,1,0], #[2] array...
	       	   [3,0,0,0,0,0,1,1,1,0], #[3] etc
	           [4,0,0,0,0,1,0,1,1,0], #[4] etc.
	           [0,1,0,0,1,1,0,0,1,0], #[5] etc..
  		       [1,1,2,0,1,0,0,0,1,0], #[6] etc...
  		       [2,1,0,0,1,0,1,0,1,0], #[7]
  		       [3,1,0,0,0,1,0,1,1,0], #[8]
  		       [4,1,0,1,1,1,0,0,1,0], #[9]
  		       [0,2,0,0,1,1,0,0,1,0], #[10]
  		       [1,2,0,0,0,1,1,0,1,0], #[11]
  		       [2,2,0,0,0,0,1,1,1,0], #[12]
  		       [3,2,0,0,0,1,0,1,0,0], #[13]
  		       [4,2,0,0,0,1,0,0,0,0], #[14]
  		       [0,3,0,0,1,1,0,0,1,0], #[15]
  		       [1,3,0,0,1,1,0,0,1,0], #[16]
  		       [2,3,3,0,0,1,0,0,0,0], #[17]
  		       [3,3,0,0,1,1,0,0,1,0], #[18]
  		       [4,3,0,0,0,1,0,0,0,0], #[19]
  		       [0,4,0,0,1,0,1,0,1,0], #[20]
  		       [1,4,0,0,1,0,0,1,1,0], #[21]
  		       [2,4,0,0,1,0,1,0,1,0], #[22]
  		       [3,4,0,0,1,0,0,1,1,0], #[23]
  		       [4,4,0,0,0,1,0,0,0,0]  #[24]
    );

my %cheats = (
    doom1 => 'idclip',
    doom2 => 'idspispopd',
    halflife => 'noclip',
    );

sub tileTypeChecker {
	my $ascii_Up_Down="\x{2502}";
	my $ascii_Left_Right="\x{2500}";
	my $ascii_Top_Left_Corner="\x{250C}";
	my $ascii_Bottom_Left_Corner="\x{2514}";
	my $ascii_Top_Right_Corner="\x{2510}";
	my $ascii_Bottom_Right_Corner="\x{2518}";
	my $ascii_3Way="\x{2524}";
}

sub UPDATE_MAP_DATA {
    # Inner/Outer exist so that I can get 0-24 for X,Y to access the correct array and check if the
    # current spot has been revealed. Without these, the entire row or column would be marked as revealed
    my $innerCount = 0;
    my $outerCount = 0;
    for(my $i=0; $i <= 4; $i++) {
        for(my $j=0; $j <= 4; $j++) {
	        # Prints your current position out from the @MapLoc array
            if ($MapLoc[0] == $j && $MapLoc[1] == $i) {
		        # Changes the current positions state to "1" to reveal it
	            # Upon traveling, the UPDATE_MAP_DATA function is called so this will update your map correctly
        		if (@{$MapAoA[$innerCount]}[2] == 0) { splice @{$MapAoA[$innerCount]},2,1,1; }
	            # If you destroy the walls then the map should be updated accordingly
	        	if ($impasse01_cleared == 1 && @{$MapAoA[1]}[2] != 1) { splice @{$MapAoA[1]},2,1,0; }
	        	if ($impasse11_cleared == 1 && @{$MapAoA[6]}[2] != 1) { splice @{$MapAoA[6]},2,1,0; }
                if (@{$MapAoA[$innerCount]}[2] == 3) { $is_shop = 1; }
	        }
	        $innerCount+=1;
        }
    	$outerCount+=1;
    }
}

sub PRINT_MAP {
   if ($haveMap == 0) {
        say "\n=> What are you talking about? You do not have a map.";
        return;
    }
    my $innerCount = 0;
    my $outerCount = 0;

    for(my $i=0; $i <= 4; $i++) {
        for(my $j=0; $j <= 4; $j++) {
	        # Prints your current position out from the @MapLoc array
            if ($MapLoc[0] == $j && $MapLoc[1] == $i) {
    	        print "[$playerChar{PORTRAIT}]";
	        }
	        elsif (@{$MapAoA[$innerCount]}[2] == 3 && $is_shop == 1) { print "[$shop]"; }
            elsif (@{$MapAoA[$innerCount]}[2] == 2) { print "[$impasse]"; }
            elsif (@{$MapAoA[$innerCount]}[2] == 1) { print "[$revealed]"; }
    	    else { print "[$undiscovered]"; }
	        $innerCount+=1;
        }
        print "\n";
    	$outerCount+=1;
    }
}

sub PRINT_DIRECTIONS {
    print "\nYou can travel in the following direction(s)\n[ ";
    if (@{$MapAoA[$MapLoc[4]]}[4] == 1) {
        print BOLD."N".RESET."orth ";
    }
    if (@{$MapAoA[$MapLoc[4]]}[5] == 1) {
        print BOLD "S".RESET."outh ";
    }
    if (@{$MapAoA[$MapLoc[4]]}[6] == 1) {
        print BOLD "E".RESET."ast ";
    }
    if (@{$MapAoA[$MapLoc[4]]}[7] == 1) {
        print BOLD "W".RESET."est ";
    }
    print "]\n";
}

sub TRAVEL_DIR {
    # Final check to make sure you can't leave the current room without possibly encountering something
    my $input = shift;

    if ( $input =~ m/^N{1}O*R*T*H*$/ && @{$MapAoA[$MapLoc[4]]}[4] == 1) {
        PRELEAVEROOMCHECK();
		$count_NS -= 1;
		# Sets a value so we can know what index we're in in the MapAoA structure
		splice @MapLoc,4,1,$MapLoc[4]-5;
		# Doesn't allow you to leave the map boundaries
		if ($MapLoc[1] <= 0 && @{$MapAoA[$MapLoc[4]]}[2] != 2) {
			$count_NS += 1;
			splice @MapLoc,1,1,0; #Resets you to the Y position of the top row
			splice @MapLoc,4,1,$MapLoc[4]+5; # Resets the MapAoA index
		}
		# Takes care of running into an "impasse" and resets your location to the previous location
		elsif ($MapLoc[1] >= 0 && @{$MapAoA[$MapLoc[4]]}[2] == 2) {
			splice @MapLoc,1,1,$MapLoc[3]; # Moves your position to the previous location
			splice @MapLoc,4,1,$MapLoc[4]+5; # Resets the MapAoA index
		}
		# Allows movement if within the map boundaries
		else {
			splice @MapLoc,1,1,$count_NS; # Current
			splice @MapLoc,3,1,$count_NS+1; # Previous
			splice @MapLoc,2,1,$count_EW; # Previous
		}
    }

    elsif ( $input =~ m/^S{1}O*U*T*H*$/ && @{$MapAoA[$MapLoc[4]]}[5] == 1) {
        PRELEAVEROOMCHECK();
		$count_NS += 1;
		# Sets a value so we can know what index we're in in the MapAoA structure
		splice @MapLoc,4,1,$MapLoc[4]+5;
		# Doesn't allow you to leave the map boundaries
		if ($MapLoc[1] >= 4 && @{$MapAoA[$MapLoc[4]]}[2] != 2) {
			$count_NS -= 1;
			splice @MapLoc,1,1,4; # Resets you to the Y position of the bottom row
			splice @MapLoc,4,1,$MapLoc[4]-5; # Resets the MapAoA index
		}
		# Takes care of running into an "impasse" and resets your location to the previous location
		elsif ($MapLoc[1] <= 4 && @{$MapAoA[$MapLoc[4]]}[2] == 2) {
			splice @MapLoc,1,1,$MapLoc[3]; # Moves your position to the previous location
			splice @MapLoc,4,1,$MapLoc[4]-5; # Resets the MapAoA index
		}
		# Allows movement if within the map boundaries
		else {
			splice @MapLoc,1,1,$count_NS; # Current
			splice @MapLoc,3,1,$count_NS-1; # Previous
			splice @MapLoc,2,1,$count_EW; # Previous
		}
    }

    elsif ( $input =~ m/^E{1}A*S*T*$/ && @{$MapAoA[$MapLoc[4]]}[6] == 1) {
        PRELEAVEROOMCHECK();
		$count_EW += 1;
		# Sets a value so we can know what index we're in in the MapAoA structure
		splice @MapLoc,4,1,$MapLoc[4]+1;
		# Doesn't allow you to leave the map boundaries
		if ($MapLoc[0] >= 4 && @{$MapAoA[$MapLoc[4]]}[2] != 2) {
			$count_EW -= 1;
			splice @MapLoc,0,1,4; # Rests you to the X position of the rightmost column
			splice @MapLoc,4,1,$MapLoc[4]-1; # Resets the MapAoA index
		}
		# Takes care of running into an "impasse" and resets your location to the previous location
		elsif ($MapLoc[0] <= 4 && @{$MapAoA[$MapLoc[4]]}[2] == 2) {
			splice @MapLoc,0,1,$MapLoc[2]; # Moves your position to the previous location
			splice @MapLoc,4,1,$MapLoc[4]-1; # Resets the MapAoA index
		}
		# Allows movement if within the map boundaries
		else {
			splice @MapLoc,0,1,$count_EW; # Current
			splice @MapLoc,2,1,$count_EW-1; # Previous
			splice @MapLoc,3,1,$count_NS; # Previous
		}
    }

    elsif ( $input =~ m/^W{1}E*S*T*$/ && @{$MapAoA[$MapLoc[4]]}[7] == 1) {
        PRELEAVEROOMCHECK();
		$count_EW -= 1;
		# Sets a value so we can know what index we're in in the MapAoA structure
		splice @MapLoc,4,1,$MapLoc[4]-1;
		# Doesn't allow you to leave the map boundaries
		if ($MapLoc[0] <= 0 && @{$MapAoA[$MapLoc[4]]}[2] != 2) {
			$count_EW += 1;
			splice @MapLoc,0,1,0; # Resets you to the X position of the leftmost column
			splice @MapLoc,4,1,$MapLoc[4]+1; # Resets the MapAoA index
		}
		# Takes care of running into an "impasse" and resets your location to the previous location
		elsif ( $MapLoc[0] >= 0 && @{$MapAoA[$MapLoc[4]]}[2] == 2) {
			splice @MapLoc,0,1,$MapLoc[2];
			splice @MapLoc,4,1,$MapLoc[4]+1; # Resets the MapAoA index
		}
		# Allows movement if within the map boundaries
		else {
			splice @MapLoc,0,1,$count_EW; # Current
			splice @MapLoc,2,1,$count_EW+1; # Previous
			splice @MapLoc,3,1,$count_NS; # Previous
		}
    } else {
        if (rand(121) >= 100) { say RED."=> ".RESET."You should really ".BOLD."LOOK".RESET." where you're going"; }
        elsif (rand(121) >= 80) { say RED."=> ".RESET."Traveling into the ".BOLD.$input.RESET." wall is ill advised."; }
        elsif (rand(121) >= 60) { say RED."=> ".RESET."You've ran into the ".BOLD.$input.RESET." wall. Good job."; }
        elsif (rand(121) >= 40) {
            my $val = [@_=%cheats]->[1|rand@_];
            say RED."=> ".RESET."Despite how hard you want to walk through walls, you cannot. Try $val instead.";
        }
        elsif (rand(121) >= 20) {
            say "You knock your noggin off the wall and hurt yourself! ".RED."You lose 10hp".RESET.".";
            $playerChar{CURRENT_HP} -= 10;
        } else {
            say "Your body attempts to merge with the wall in front of you.".RED."You lose 15hp".RESET.".";
            $playerChar{CURRENT_HP} -= 15;
        }
        return;
    }
    say "\n\n#-----------------------------------------------------------------#\n\n";
    POSTENTERROOMCHECK();
}


sub LOCATION_SETTINGS {
    # Unset the people you can talk to
    @talkToPerson = ();
    if ($MapLoc[0] == 0 && $MapLoc[1] == 0 && $initialHelpScreen == 1) {
        $initialHelpScreen = 0;
        ACTION("HELP");
    }

    if ($MapLoc[0] == 0 && $MapLoc[1] == 3 && $haveMap == 0) {
        say YELLOW."\n=> ".RESET.BOLD."You found a map!".RESET;
        say YELLOW."=> ".RESET."Take time to review the ".BOLD."HELP".RESET." options. During gameplay, acquiring items will alter the possible available actions of your character.\n";
        $haveMap = 1;
        ACTION("GET");
        ACTION("HELP");
    }

    # Once you get help from the shopkeeper, the pathing can change to allow access to the rest of the map at 3,2
    if ($MapLoc[0] == 3 && $MapLoc[1] == 2) {
        if ($quests{MOVELOGS}{STATE_A} == 0 || $quests{MOVELOGS}{STATE_B} == 1) {
            say YELLOW."=> ".RESET."You see some ".BOLD."burly guys".RESET." standing around.";
            push @talkToPerson,'BURLY GUYS';
            $playerChar{CURRENT_HP} = $playerChar{MAX_HP};
        }
    }

    if ($MapLoc[0] == 2 && $MapLoc[1] == 3) {
        say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." looks at you.";
        push @talkToPerson,'SHOPKEEPER';
    }

    # Script to destroy the impasse at 0,1
    if ($MapLoc[0] == 2 && $MapLoc[1] == 0 && $impasse01_cleared == 0) {
        print "\nYou see a crack in the wall. As you investigate you realize you have a bomb to deal with this certain thing!\n";
        print "Use bomb? [".BOLD."Y".RESET."es ".BOLD."N".RESET."o ]\n".YELLOW."=> ".RESET;
        my $input = uc(<STDIN>);
        chomp($input);
        if ($input =~ m/^Y+E*S*$/) {
            $impasse01_cleared = 1;
            print $ascii_explosion."\n";
            system("/usr/bin/afplay Sounds/LOZ_Secret.wav &");
            splice @{$MapAoA[$MapLoc[4]]},7,1,1;
            UPDATE_MAP_DATA();
            PRINT_MAP();
        }
    }

    # Script to destroy the impasse at 1,1 while standing in 0,1
    if ($MapLoc[0] == 1 && $MapLoc[1] == 0 && $impasse11_cleared == 0 && $impasse01_cleared == 1) {
        say "\nYou see a crack in the wall. As you investigate you realize you have a bomb to deal with this certain thing!";
        print "Use bomb? [".BOLD."Y".RESET."es ".BOLD."N".RESET."o ]\n".YELLOW."=> ".RESET;
        my $input = uc(<STDIN>);
        chomp($input);
        if ($input =~ m/^Y+E*S*/) {
            $impasse11_cleared = 1;
            print $ascii_explosion."\n";
            system("/usr/bin/afplay Sounds/LOZ_Secret.wav &");
            splice @{$MapAoA[$MapLoc[4]]},5,1,1;
            UPDATE_MAP_DATA();
            PRINT_MAP();
        }
    }

    if ($MapLoc[0] == 1 && $MapLoc[1] == 1) {
      say "You see a chest on the ground.\n";
      $chest = 1;
    }

    # If the main boss has died, the room will start collapsing. The falling rocks chase you the rest of the way out of the dungeon.
    if ($MapLoc[0] == 4 && $MapLoc[1] == 2 && $main_boss_dead == 0) {
      say YELLOW."=> ".RESET.BOLD."You enter the lair of the final boss. Prepare your buttholes for total annihilation.";
	    ENTER_PROMPT();
      COMBAT("BOSS");
    }
    if ($main_boss_dead == 1 && @{$MapAoA[$MapLoc[4]]}[2] == 1) {
        splice @{$MapAoA[$MapLoc[4]]},2,1,2;
    }
    if ($MapLoc[0] == 4 && $MapLoc[1] == 4) {
        say "\n\n".BOLD."Congrats, you beat the shit out of the game!".RESET."\n";
        ENTER_PROMPT();
        # Tests for existance and if it's not an empty file then rolls the credits
        -e "credits.pl" && -r "credits.pl" ? system("perl credits.pl") : print "[".RED."-".RESET."] Could not open credits.pl\n";
        # FINALE
        #system("/usr/bin/afplay Sounds/END.mp3 &");
        FINALE();
        exit;
	}
}

sub QUEST_SYSTEM {
    if ($MapLoc[0] == 3 && $MapLoc[1] == 2) {
        if ($quests{MOVELOGS}{STATE_B} == 0) {
            say YELLOW."=> ".RESET."The burly guy in front of you says, \"There's a bunch of giant logs";
            say "   blocking the path. You'll have to come back later\"";
            $quests{MOVELOGS}{STATE_A} = 1;
            say YELLOW."\n=> ".RESET."Your journal has been updated!";
        }
        elsif ($quests{MOVELOGS}{STATE_A} == 1) {
            say "Your help offers to help out. You think to yourself, \"That's redundant.\"";
            say "\"".FAINT."On your word we'll get these logs out of the way.".RESET."\"";
            ENTER_PROMPT();
            splice @{$MapAoA[$MapLoc[4]]},4,1,1;
            UPDATE_MAP_DATA();
            $quests{MOVELOGS}{STATE_A} = 2;
            $quests{MOVELOGS}{STATE_B} = 2;
            say YELLOW."\n=> ".RESET."Your ".BOLD."journal".RESET." has been updated!";

        }
    }
    if ($MapLoc[0] == 2 && $MapLoc[1] == 3) {
        if ($quests{MOVELOGS}{STATE_A} == 1 && $quests{MOVELOGS}{STATE_B} == 0) {
            say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." looks at you and says, \"I've heard that you need some";
            say "   help to clear out the path. For ".YELLOW."75".RESET."gp I can have my guys help";
            say "   you out.\"";
            print "\nWhat would you say? [", BOLD, "Y", RESET, "/", BOLD, "N", RESET, "]\n".MAGENTA."%> ".RESET;
            my $input = uc<STDIN>;
            chomp ($input);
            if ($input =~ m/Y{1}E*S*/) {
                if ($playerChar{GOLD} >= 75 ) {
                    $quests{MOVELOGS}{STATE_B} = 1;
                    say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." says \"Thanks, let me know if you need anything else.\"";
                    say YELLOW."\n=> ".RESET."Your ".BOLD."journal".RESET." has been updated!";
                    $playerChar{GOLD} -= 75;
                } else {
                    say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." says \"You don't have enough money for that right now. Come back later\"";
                }
            } else {
                say YELLOW."=> ".RESET."The shopkeeper says, \"Would you like to buy anything?\"";
                print "\nWhat would you say? [", BOLD, "Y", RESET, "/", BOLD, "N", RESET, "]\n".MAGENTA."%> ".RESET;
                $input = uc<STDIN>;
                chomp ($input);
                if ($input =~ m/Y{1}E*S*/) {
                    say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." shows you his stock";
                } else {
                    say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." says \"Thanks anyways. You know where to find me\"";
                }
            }
        } else {
            say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." says, \"Would you like to buy anything?\"";
            print "\nWhat would you say? [", BOLD, "Y", RESET, "/", BOLD, "N", RESET, "]\n".MAGENTA."%> ".RESET;
            my $input = uc<STDIN>;
            chomp ($input);
            if ($input =~ m/Y{1}E*S*/) {
                say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." shows you his stock";
            } else {
                say YELLOW."=> ".RESET."The ".BOLD."shopkeeper".RESET." says \"Thanks anyways. You know where to find me\"";
            }
        }
    }
}

sub COMBAT {
    my $final_boss = shift;
    if (not defined $final_boss) {
        $final_boss = 0;
        $monsterChar{NAME} = $monsterName[rand @monsterName];
        $monsterChar{MAX_HP} = int(rand(101) + 45) + int(10 + $playerChar{LVL} * 1.5);
        $monsterChar{CURRENT_HP} = $monsterChar{MAX_HP};
        $monsterChar{DMG_MIN} = int(rand(5)+1);
        $monsterChar{DMG_MAX} = int(rand(15) + 2) + int($playerChar{LVL} * 1.5);
        $monsterChar{DEATH_XP} = int(rand(66) + 25);
        $monsterChar{DEATH_GOLD} = int(rand(76) + 25);
    } else {
        $final_boss = 1;
        $monsterChar{NAME} = "Lead Skeleton";
        $monsterChar{MAX_HP} = int(rand(251) + 45) + int(10 + $playerChar{LVL} * 1.5);
        $monsterChar{CURRENT_HP} = $monsterChar{MAX_HP};
        $monsterChar{DMG_MIN} = int(rand(9)+1);
        $monsterChar{DMG_MAX} = int(rand(22) + 2) + int($playerChar{LVL} * 1.5);
        $monsterChar{DEATH_XP} = int(rand(400)+200);
        $monsterChar{DEATH_GOLD} = 666;
    }


    # Eventually turn this into how we assign a portrait to a monster permanently. This will be outside of combat and at game generation all initial monsters are created. Upon demand, monsters should also be able to be created. This would give us monster spawners. One day the monsters will be able to repopulate rooms after a set time period.
    switch ($monsterChar{NAME}) {
        case m/^Skeleton$/i { $monsterChar{PORTRAIT} = $skeleton_pic; }
        case m/^IRS Guy$/i { $monsterChar{PORTRAIT} = $irs_guy_pic; }
        case m/^Struttin Guy$/i { $monsterChar{PORTRAIT} = $struttin_guy_pic; }
        case m/^Birds shitting on a car$/i { $monsterChar{PORTRAIT} = $birds_shitting_on_a_car_pic; }
        case m/^Dirty French Guy$/i { $monsterChar{PORTRAIT} = $dirty_french_guy_pic; }
        case m/^Crows$/i { $monsterChar{PORTRAIT} = $crows_pic; }
        case m/^Roaming Bovine$/i { $monsterChar{PORTRAIT} = $roaming_bovine_pic; }
        case m/^Corporate Satan$/i { $monsterChar{PORTRAIT} = $corporate_satan_pic; }
        case m/^Impatient Waiter$/i { $monsterChar{PORTRAIT} = $impatient_waiter_pic; }
        case m/^ICP Clown$/i { $monsterChar{PORTRAIT} = $icp_clown_pic; }
        case m/^Grim Reaper Statue/i { $monsterChar{PORTRAIT} = $grim_reaper_statue_pic; }
        case m/^Juggalette$/i { $monsterChar{PORTRAIT} = $juggalette_pic; }
        case m/^Lead Skeleton$/i { $monsterChar{PORTRAIT} = $lead_skeleton_pic; }
        case m/^Boner$/i { $monsterChar{PORTRAIT} = $boner_pic; }
        else { $monsterChar{PORTRAIT} = BOLD.RED."=> ".RESET."Picture Unavailable."; }
    }

    say "\nUse ".BOLD RED."Attack".RESET.", ".BOLD BLUE."Block".RESET.", or ".BOLD GREEN."Magic".RESET." along with the arrow keys for\ndirectional damage in combat\n".RESET.RED."A".RESET." for attacking, ".BLUE."B".RESET." for blocking, ".GREEN."M".RESET." for magic spells.";

    say $monsterChar{PORTRAIT};
    say BRIGHT_RED."=> ".RESET."A $monsterChar{NAME} attacks you!";
    say BRIGHT_RED."=> ".RESET."The $monsterChar{NAME} yells ".ITALIC."\"".$fightIntro[rand @fightIntro]."\"".RESET;

    my $itsABonus = 0;

    while ($monsterChar{CURRENT_HP} > 0) {
        my $char = undef;
        my $rng = 0;
        my $dmg = 0;
        my $monster_dmg = 0;
        my $validKey = 0;
        my $block = 0;
        my $MONSTER_HP_STATUS = int(($monsterChar{CURRENT_HP} / $monsterChar{MAX_HP}) * 100);

        print BRIGHT_RED."=> ".RESET."The $monsterChar{NAME} has ";
        switch ($MONSTER_HP_STATUS) {
            case { $MONSTER_HP_STATUS >= 75} { say GREEN.$monsterChar{CURRENT_HP}.RESET."/".GREEN.$monsterChar{MAX_HP}.RESET."hp"; }
            case { $MONSTER_HP_STATUS >= 40} { say YELLOW.$monsterChar{CURRENT_HP}.RESET."/".GREEN.$monsterChar{MAX_HP}.RESET."hp"; }
            else { say RED.$monsterChar{CURRENT_HP}.RESET."/".GREEN.$monsterChar{MAX_HP}.RESET."hp"; }
        }

        print CYAN."\n=> ".RESET."Action: ";

        # Term::ReadKey doc http://search.cpan.org/dist/TermReadKey/ReadKey.pm
        ReadMode('cbreak');
        $char = ReadKey(0);

        # Try again if there is no character inputted
        if (not defined $char) {
            say RED."=> ".RESET."No character defined by that keypress";
        }

        #say ord($char);

        # A or a for basic attacking
        if (ord($char) == 97 || ord($char) == 65) {
            $rng = int(rand(6) + 1);
            print RED;
            switch ($rng) {
                case 1 { print "STAB"; }
                case 2 { print "SWING"; }
                case 3 { print "SLASH"; }
                case 4 { print "CUT"; }
                case 5 { print "BUTCHER"; }
                case 6 { print "SLICE"; }
                else { print "FILET"; }
            }
            print RESET;
            $validKey = 1;
            $dmg = int(rand($playerChar{DMG_MAX} - $playerChar{DMG_MIN})) + $playerChar{DMG_MIN};
            $monster_dmg = int(rand($monsterChar{DMG_MAX} - $monsterChar{DMG_MIN})) + $monsterChar{DMG_MIN};
        }
        # B or b for blocking
        elsif (ord($char) == 98 || ord($char) == 66) {
            $rng = int(rand(5)+1);
            print BLUE;
            switch ($rng) {
                case 1 { print "GUARD"; }
                case 2 { print "BLOCK"; }
                case 3 { print "DEFEND"; }
                case 4 { print "RESIST"; }
                case 5 { print "HARDEN"; }
                else { print "BIDE"; }
            }
            print RESET;
            $validKey = 1;
            $block = 1;
            $dmg = 0;
            $monster_dmg = int((rand($monsterChar{DMG_MAX} - $monsterChar{DMG_MIN}) + $monsterChar{DMG_MIN})/2);
        }
        # M or m for magic
        elsif (ord($char) == 109 || ord($char) == 77) {
            $rng = int(rand(4) + 1);
            print GREEN;
            switch ($rng) {
                case 1 { print "POOF"; }
                case 2 { print "POW"; }
                case 3 { print "SUPRISE"; }
                case 4 { print "ABRA KADABRA"; }
                else { print "SHAZZZAAM"; }
            }
            print RESET;
            $validKey = 1;
            $dmg = int(rand($playerChar{DMG_MAX} - $playerChar{DMG_MIN})) + $playerChar{DMG_MIN};
            $monster_dmg = int(rand($monsterChar{DMG_MAX} - $monsterChar{DMG_MIN})) + $monsterChar{DMG_MIN};
        } else {
          $validKey = 0;
          say BOLD RED."=> ".RESET.BOLD."You've pressed a key other than A, B, or M. You've missed your turn.".RESET;
          $dmg = 0;
        }

        # Get the arrow key directions
        if ($validKey == 1) {
          print CYAN." => ".RESET."Direction: ";
          $char = ReadKey(0);
          if (ord($char) == 27) {
              $char = ReadKey(0);
              if (ord($char) == 91) {
                  $char = ReadKey(0);
                  switch (ord($char)) {
                      case 65 { say "UP"; }
                      case 66 { say "DOWN"; }
                      case 67 { say "RIGHT"; }
                      case 68 { say "LEFT"; }
                      else { $dmg = 0; say "I have no clue what you pressed"; }
                  }
                  $monsterChar{CURRENT_HP} -= $dmg;
              }
          }
        }

        if ($block == 1) {
          $rng = int(rand(2));
          switch ($rng) {
            case 0 { say BLUE."=> ".RESET."You block, taking no damage, and the ".$monsterChar{NAME}." loses a turn."; $itsABonus = 1; $monster_dmg = BLUE."BLOCKED".RESET;
                     say BRIGHT_RED."=> ".RESET."Damage dealt to ".$playerChar{NAME}.": ".$monster_dmg;
            }
            else { say BLUE."=> ".RESET."You block and take half damage from ".$monsterChar{NAME};
                   say BRIGHT_RED."=> ".RESET."Damage dealt to ".$playerChar{NAME}.": ".$monster_dmg;
                   $playerChar{CURRENT_HP} -= $monster_dmg;
            }
          }
        }
        elsif ( $itsABonus == 1 ) {
          $itsABonus = 0;
          say "=> *".$fightWords[rand @fightWords]."*";
          say YELLOW."=> ".RESET."Damage dealt to ".$monsterChar{NAME}.": ".$dmg;
        }
        else {
          say "=> *".$fightWords[rand @fightWords]."*";
          say YELLOW."=> ".RESET."Damage dealt to ".$monsterChar{NAME}.": ".$dmg;
          $rng = int(rand(3)+1);
          switch ($rng) {
              case 1 { say BRIGHT_RED."=> ".RESET."The ".$monsterChar{NAME}." swings and misses."; $monster_dmg = 0; }
              else { say BRIGHT_RED."=> ".RESET."Damage dealt to ".$playerChar{NAME}.": ".$monster_dmg; }
          }
          $playerChar{CURRENT_HP} -= $monster_dmg;
        }

        print YELLOW."=> ".RESET."You have ";
        my $PLAYER_HP_STATUS = int(($playerChar{CURRENT_HP} / $playerChar{MAX_HP}) * 100);
        switch ($PLAYER_HP_STATUS) {
            case { $PLAYER_HP_STATUS >= 75} { say GREEN.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET."hp"; }
            case { $PLAYER_HP_STATUS >= 40} { say YELLOW.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET."hp"; }
            else { say RED.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET."hp"; }
        }

        ReadMode('normal');
        STATUS();
    }
    # If monster is dead, we let the STATUS function know so that we can collect loot and XP and stuff.
    if ($final_boss == 1) {
        splice @{$MapAoA[$MapLoc[4]]},3,1,0;
        $main_boss_dead = 1;
    }
    STATUS(1);
}


sub STATUS {
   # say @$_ foreach ( @MapAoA );
   # say "EW: ".$count_EW." NS: ".$count_NS;
   # say "X Y X Y ?";
   # say $_." " foreach ( @MapLoc );
   # print "\n";
   my $monster_activity = shift;
   if (not defined $monster_activity) {
        $monster_activity = 0;
   } else { $monster_activity = 1; }

    # Check if player is dead
    if ($playerChar{CURRENT_HP} <= 0) {
        my $rng = int(rand(12) + 1);
        print BRIGHT_RED."=> ".RESET."Unfortunately you have died. ";
        switch ($rng) {
            case 1 { say "Fortunately, you ".BOLD."HAVE".RESET." to play again. ;)"; sleep 5; system("clear"); exec("$abs_path") or say STDERR "Couldn't exec $abs_path: $!"; }
            case 2 { say "Your life is over and evil wins again."; }
            case 3 { say "Fortunately, no one will miss you"; }
            case 4 { say "Maybe if I implement saving you could reload. Too bad about that though."; }
            case 5 { say "Fortunately, Soylent Green is the next big thing!"; }
            case 6 { say "Good."; }
            case 7 { say "Your family now hates you."; }
            case 8 { say "Again."; }
            case 9 { say "And another one bites the dust."; }
            case 10 { say "May you have more luck in death than life."; }
            case 11 { say "Rest in pieces, $playerChar{NAME}."; }
            case 12 { say "Here's a picture of your corpse: ".RED."X".RESET.". Not pretty."; }
        }
        sleep 5;
        system("clear");
        exit;
    }

    if ($monster_activity == 1 && $monsterChar{CURRENT_HP} <= 0) {
        $monster_activity = 0;
        say BRIGHT_RED."=> ".RESET."The $monsterChar{NAME} utters a final remark, ".ITALIC."\"".$fightEnd[rand @fightEnd]."\"".RESET;
        print "\n";
        say YELLOW."=> ".RESET."You loot ".YELLOW.$monsterChar{DEATH_GOLD}.RESET."gp from the ".$monsterChar{NAME}."'s corpse.";
        $playerChar{GOLD} += $monsterChar{DEATH_GOLD};
        say YELLOW."=> ".RESET."You gain ".GREEN.$monsterChar{DEATH_XP}.RESET."xp.";
        $playerChar{CURRENT_XP} += $monsterChar{DEATH_XP};
        say "\n".YELLOW."=> ".RESET."You feel calm inside this room";
        splice @{$MapAoA[$MapLoc[4]]},8,1,0;
    }

    # Check if player can level up. If so, perform level up things and stuff.
    if ($playerChar{CURRENT_XP} >= $playerChar{NEXT_LVL_XP}) {
        $playerChar{CURRENT_XP} = $playerChar{CURRENT_XP} - $playerChar{NEXT_LVL_XP};
        $playerChar{LVL} += 1;
        my $dmg_min_increase = int(rand(6)+1);
        $playerChar{DMG_MIN} += $dmg_min_increase;
        my $dmg_max_increase = int(rand(10)+3);
        $playerChar{DMG_MAX} += $dmg_max_increase;
        $playerChar{NEXT_LVL_XP} += 100;
        my $hp_increase = int(rand(21)+5);
        $playerChar{MAX_HP} += $hp_increase;
        $playerChar{CURRENT_HP} = $playerChar{MAX_HP};
        say GREEN."=> ".RESET.BOLD."You've gained a level!".RESET;
        say GREEN."=> ".RESET."You've gained $hp_increase hp.";
        say GREEN."=> ".RESET."You now do $playerChar{DMG_MIN} \- $playerChar{DMG_MAX} damage total while unequiped.";
        ENTER_PROMPT();
    }
}

sub POSTENTERROOMCHECK {
    if ($autoMap == 1 && $haveMap == 1) {
        ACTION("MAP");
    }
    if ($autoLook == 1) {
        ACTION("LOOK");
    }
	say YELLOW."=> ".RESET."You just entered room: ".$MapLoc[0].",".$MapLoc[1]." via ".$MapLoc[2].",".$MapLoc[3];

    # Random monster check
    if (@{$MapAoA[$MapLoc[4]]}[8] == 1 && rand(101) > 50) {
        say YELLOW."=> ".RESET."A wild monster appears!";
        COMBAT();
    }
    elsif (@{$MapAoA[$MapLoc[4]]}[8] == 1) {
        my $rng = int(rand(7)+1);
        print YELLOW."=> ".RESET;
        switch ($rng) {
            case 1 { say "You feel as if you're being watched."; }
            case 2 { say "You feel unsettled."; }
            case 3 { say "You see a shadow dart across the distance."; }
            case 4 { say "You feel the weight of anothers eyes on you."; }
            case 5 { say "You feel paranoid."; }
            case 6 { say ITALIC."\"You feel like.. somebodies watchin' you!\"".RESET; }
            case 7 { say "The hair on the back of your neck stands up."; }
            else { say "You can't relax in here."; }
        }
    }
}

sub PRELEAVEROOMCHECK {
	say YELLOW."=> ".RESET."You attempt to leave room: ".$MapLoc[0].",".$MapLoc[1];

    # Random monster check
    if (@{$MapAoA[$MapLoc[4]]}[8] == 1 && rand(101) > 33) {
        say YELLOW."=> ".RESET."As you approach the exit, a monster appears out of nowhere and lunges at you!";
        ENTER_PROMPT();
        COMBAT();
    }
}

sub ACTION {
        my $input = shift;
        if (not defined $input) {
            print "\nWhat would you like to do?\n".MAGENTA."%> ".RESET;
            $input = uc(<STDIN>);
            chomp($input);
        }

        if ($input =~ m/^HELLO/) {
            if (rand(101) > 50) {
                say YELLOW."=> ".RESET."Goodbye.";
            } else {
                say YELLOW."=> ".RESET."Nice weather we're having today.";
            }
        }
        # Help
        elsif ($input =~ m/^HELP$/ || $input =~ m/^\?{1}$/) {
            say GREEN."#----# ".RESET.RED.BOLD.UNDERLINE."HELP".RESET.GREEN." #----------------------------------------------------------------------------------# ".RESET;
            print GREEN."# ".RESET."You can ";
            print BOLD."LOOK".RESET;
            print ", ".BOLD."GET".RESET;
            if ($haveMap == 1) {
                print ", ".BOLD."MAP".RESET;
            }
            print ", ".BOLD."CLEAR".RESET;
            print ", ".BOLD."TALK".RESET." [".BOLD."TO".RESET."] <PERSON>";
            print ", ".BOLD."INV".RESET."[".BOLD."ENTORY".RESET."] ";
            say "and ".BOLD."C".RESET."[".BOLD."HARACTER".RESET."] ".GREEN."#".RESET;
            say GREEN."#----# ".RESET.RED.BOLD.UNDERLINE."TIPS".RESET.GREEN." #----------------------------------------------------------------------------------# ".RESET;
            say GREEN."# ".RESET."If you ".BOLD."LOOK".RESET.", you can travel in one of the returned directions.                               ".GREEN."#".RESET;
            say GREEN."# ".RESET."Typing ".BOLD."AUTOLOOK".RESET." will enable/disable automatically checking directions when you enter a room. ".GREEN."#".RESET;
            if ($haveMap == 1) {
                say GREEN."# ".RESET."Typing ".BOLD."AUTOMAP".RESET." will enable/disable automatically viewing the map when you enter a room.      ".GREEN."#".RESET;
            }
            say GREEN."# ".RESET."Typing ".BOLD."HELP".RESET." or ".BOLD."?".RESET." will show this menu again.                                                  ".GREEN."#".RESET;
            say GREEN."#----------------------------------------------------------------------------------------------#".RESET;
        }
        elsif ($input =~ m/^AUTOLOOK$/) {
            if ($autoLook == 0) {
                $autoLook = 1;
                say "AUTOLOOK activated"
            } else {
                $autoLook = 0;
                say "AUTOLOOK disabled"
            }
        }
        elsif ($haveMap == 1 && $input =~ m/^AUTOMAP$/) {
            if ($autoMap == 0) {
                $autoMap = 1;
                say "AUTOMAP activated";
                ACTION("MAP");
            } else {
                $autoMap = 0;
                say "AUTOMAP disabled";
            }
        }
        # Take a look around
        elsif ($input =~ m/^L{1}O*O*K*$/) {
            PRINT_DIRECTIONS();
        }
        # Show the map
        elsif ($haveMap == 1 && $input =~ m/^M{1}A*P*/) {
            UPDATE_MAP_DATA();
            PRINT_MAP();
        }
        # Check directions
        elsif ($input =~ m/^S{1}O*U*T*H*$/ || $input =~ m/^N{1}O*R*T*H*$/ || $input =~ m/^E{1}A*S*T*$/ || $input =~ m/^W{1}E*S*T*$/) {
            TRAVEL_DIR($input);
        }
        # Check inventory
        elsif ($input =~ m/^I{1}N*V*E*N*T*O*R*Y*$/) {
            if (@{$playerChar{INVENTORY}}) {
                say "In your inventory you currently have";
                foreach (0..$#{$playerChar{INVENTORY}}) {
                  say "#".$_." ".$playerChar{INVENTORY}[$_];
                }
            } else {
                say RED."=> ".RESET."Your inventory is emtpy.";
            }
        }
        elsif ($input =~ m/^EQUIP$/) {
            if (@{$playerChar{INVENTORY}}) {
                ACTION("INVENTORY");
            } else {
                say RED."=> ".RESET."You have no items to equip.";
            }
        }
        # Get item in room
        elsif ($input =~ m/^GET/) {
            say "Currently expirimental";
            push@{$playerChar{INVENTORY}},'Map';
        }
        elsif ($input =~ m/^DROP/) {
            say "Currently expirimental";
            pop @{$playerChar{INVENTORY}};
        }
        # Read <object> in room
        elsif ($input =~ m/^R{1}E*A*D*/) {
            say "Current unimplemented";
        }
        elsif ($input =~ m/^C{1}H*A*R*A*C*T*E*R*$/) {
            printf("%-28s %3s %-35s", BOLD."Name".RESET, " : ", $playerChar{NAME}); print "\n";
            printf("%-28s %3s %-35s", BOLD."Class".RESET, " : ", $playerChar{CLASS}); print "\n";
            printf("%-28s %3s %-35s", BOLD."Level".RESET, " : ", $playerChar{LVL}); print "\n";
            my $PLAYER_HP_STATUS = int(($playerChar{CURRENT_HP} / $playerChar{MAX_HP}) * 100);
            if ($PLAYER_HP_STATUS >= 75) {
                printf("%-28s %3s %-35s", BOLD."HP".RESET, " : ", GREEN.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET); print "\n";
            }
            elsif ($PLAYER_HP_STATUS >= 40) {
                printf("%-28s %3s %-35s", BOLD."HP".RESET, " : ", YELLOW.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET); print "\n";
            } else {
                printf("%-28s %3s %-35s", BOLD."HP".RESET, " : ", RED.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET); print "\n";
            }
            printf("%-28s %3s %-35s", BOLD."DMG".RESET, " : ", $playerChar{DMG_MIN}."-".$playerChar{DMG_MAX}); print "\n";
            printf("%-28s %3s %-35s", BOLD."XP to next level".RESET, " : ", $playerChar{CURRENT_XP}."/".$playerChar{NEXT_LVL_XP}); print "\n";
            printf("%-28s %3s %-35s", BOLD."Gold".RESET, " : ", YELLOW.$playerChar{GOLD}.RESET."gp"); print "\n";
            printf("%-28s %3s %-35s", BOLD."Equipped helmet".RESET, " : ", $playerChar{EQUIPPED_HEAD}); print "\n";
            printf("%-28s %3s %-35s", BOLD."Equipped armor".RESET, " : ", $playerChar{EQUIPPED_BODY}); print "\n";
            # Orcs and Giants can have 2 weapons equipped
            if ($playerChar{CLASS} =~ m/^ORC/i || $playerChar{CLASS} =~ m/GIANT/i) {
                printf("%-28s %3s %-35s", BOLD."Equipped left hand".RESET, " : ", $playerChar{EQUIPPED_LEFT}); print "\n";
            }
            printf("%-28s %3s %-35s", BOLD."Equipped right hand".RESET, " : ", $playerChar{EQUIPPED_RIGHT}); print "\n";
        }
        #elsif ($input =~ m/^H{1}U*R*T*/) {
        #    $playerChar{CURRENT_HP} -= 20;
        #}
        elsif ($input =~ m/^PEE ON/ || $input =~ m/^PISS ON/) {
            say YELLOW."=> ".RESET."Drip drip yes it's true, I'm gonna pee on you";
        }
        elsif ($input =~ m/^DIE$/ || $input =~ m/^SUICIDE$/ || $input =~ m/^KILL YOURSELF/ || $input =~ m/^KILL MYSELF/) {
            $playerChar{CURRENT_HP} -= $playerChar{CURRENT_HP};
        }
        elsif ($input =~ m/^OPEN CHEST$/ && $chest == 1) {
            push@{$playerChar{INVENTORY}},'The Ring';
            system("/usr/bin/afplay Sounds/CHEST.mp3 &");
            $chest = 0;
        }
        elsif ($input =~ m/^J{1}O*U*R*N*A*L*$/) {
            say YELLOW."=> ".RESET."You check your journal";
            say "\n#------------------------#";
            foreach (keys %quests) {
                if ($quests{$_}{STATE_A} == 1) {
                    say "#".WHITE."=> ".RESET."Quest: ".$quests{$_}{NAME};
                    say "#".BRIGHT_BLUE."=> ".RESET.$quests{$_}{LOG_ENTRY_B1};
                }
                if ($quests{$_}{STATE_B} == 1) {
                    say "#".BRIGHT_BLUE."=> ".RESET.$quests{$_}{LOG_ENTRY_A1};
                }
                if ($quests{$_}{STATE_A} == 2 && $quests{$_}{STATE_B} == 2) {
                    say "#".WHITE."=> ".RESET."Quest: ".$quests{$_}{NAME};
                    if ($quests{$_}{LOG_ENTRY_A1} ne '') { say "#".BRIGHT_BLUE."=> ".RESET.$quests{$_}{LOG_ENTRY_A1}; }
                    if ($quests{$_}{LOG_ENTRY_B1} ne '') { say "#".BRIGHT_BLUE."=> ".RESET.$quests{$_}{LOG_ENTRY_B1}; }
                    if ($quests{$_}{LOG_ENTRY_A2} ne '') { say "#".BRIGHT_BLUE."=> ".RESET.$quests{$_}{LOG_ENTRY_A2}; }
                    if ($quests{$_}{LOG_ENTRY_B2} ne '') { say "#".BRIGHT_BLUE."=> ".RESET.$quests{$_}{LOG_ENTRY_B2}; }
                    say "#".WHITE."=> ".RESET."Quest: Completed";
                }
                print "\n";
            }
            say "#------------------------#";
        }
        elsif ($input =~ m/^CHECK TIME$/ || $input =~ m/^TIME$/ || $input =~ m/^CLOCK$/ || $input =~ m/^CHECK CLOCK$/ || $input =~ m/^CHECK THE TIME$/ || $input =~ m/^CHECK THE CLOCK/) {
            say YELLOW."=> ".RESET."You check your watch and it says ".localtime;
        }
        elsif ($input =~ m/^TALK$/ || $input =~ m/^TALK TO$/ || $input =~ m/^SPEAK$/ || $input =~ m/^SPEAK TO$/) {
            $input =~ m/^\s*(\w+)/;
            say RED."=> ".RESET.BOLD."$1".RESET." to who (or what)?";
        }

        # I could turn the talkToPerson array into a hash, that would be easier to handle.
        elsif ( @talkToPerson && ($input =~ m/^TALK $talkToPerson[0]$/ || $input =~ m/^TALK TO $talkToPerson[0]$/ || $input =~ m/^TALK TO THE $talkToPerson[0]$/)) {
            $input =~ m/^\s*(\w+)/;
            say YELLOW."=> ".RESET."You ".BOLD."$1".RESET." to $talkToPerson[0]";
            QUEST_SYSTEM();
        }
        elsif ($input =~ m/^QUIT$/ || $input =~ m/^EXIT$/) {
            print BOLD RED."=> YOU ARE ABOUT TO QUIT. PRESS Y TO CONFIRM: ".RESET;
            $input = uc(<STDIN>);
            chomp($input);
            if ($input =~ m/^Y$/) {
                say GREEN." \$ ".RESET."Thank you for taking the time to play my game. I appreciate it very much. I\nhope you had as much fun playing as I did creating this. Please contact me at\nhttps://github.com/pgporada/ouRPerlGame/issues if you'd like to talk about\nanything at all.";
                say "\n\n\n\n\n\n\n".BLUE."Well ".CYAN."then ".GREEN."and ".WHITE."rats\' ".YELLOW."off ".MAGENTA."to ".RED."you."."               \n\n       \n    \n         \n".BLACK."Nice job spotting this :), also, rats\' off to ya ;D!";
                exit;
            } else { say GREEN." \$ ".RESET."You return to the game world."; }
        }
        elsif ($input =~ m/^CLEAR$/) {
            system("clear");
        } else {
            my $rng = int(rand(4)+1);
            switch ($rng) {
                case 1 { say RED."=> ".RESET."Maybe you should seek ".BOLD."HELP".RESET."?"; }
                case 2 { say RED."=> ".RESET."You cannot perform ".BOLD.$input.RESET ." at this point in time"; }
                case 3 { say RED."=> ".RESET."You can't do that here."; }
                else { say RED."=> ".RESET."Not in town"; }
            }
        }
}

sub MAIN {
    GAME_INTRO();
    system("clear");
    while(1) {
        UPDATE_MAP_DATA();
        STATUS();
        LOCATION_SETTINGS();
        ACTION();
    }
}

MAIN();
