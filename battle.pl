#!/usr/bin/env perl
use strict;
use warnings;
use Term::Readkey;
use Term::ANSIColor qw(:constants colored);
use Curses::UI;
use feature qw(say);

my %knight = (
    NAME => 'Goat37',
    CLASS => 'Knight',
    HP => '100',
    LVL => '10',
    DMG_MIN => '10',
    DMG_MAX => '20',
    CRIT_CHANCE => '15',
    TOTAL_XP => '1000',
    XP_TIL_NEXT_LVL => '100',
    HP_PER_LVL => '10',
    DMG_UP_PER_LVL => '1',
    SPELL_EQUIPPED => 'None'
    );

my %sorc = (
    NAME => 'Lion23',
    CLASS => 'Sorceress',
    HP => '50',
    LVL => '10',
    DMG_MIN => '5',
    DMG_MAX => '14',
    CRIT_CHANCE => '10',
    TOTAL_XP => '1000',
    XP_TIL_NEXT_LEVEL => '100',
    DMG_UP_PER_LVL => '.7',
    SPELL_EQUIPPED => 'Fireball'
    );

sub ENTER_PROMPT {
    print "\nPress [ENTER] to continue\n";
    my $input = <STDIN>;
    if ($input !~ /\012/) { ENTER_PROMPT(); }
}

#####################
# GAME START SCREEN #
#####################
system("clear");

print "\n\n\n";
printf ("%65s", "##############################################\n");
printf ("%70s",  colored("Quest Through The Deathly Dungeon of Doom!", "bold"));
print "\n";
printf ("%65s", "##############################################\n");
printf ("%58s", "Story and coding by: Phil Porada\n");
printf ("%58s", "Version: Getting there but still alpha\n");
ENTER_PROMPT();
system("clear");

print "Welcome!\n\n";
sleep 1;
print "You approach a small computer sitting on a table in front of you. You notice a chair off to the side, grab it, move it in front of the monitor, and sit down.\n\nYou notice a button on the computer.\n"; 
ENTER_PROMPT();

# My first curses prompt
# 1) http://search.cpan.org/~mdxi/Curses-UI-0.9609/lib/Curses/UI.pm 
# 2) http://www.dirvish.org/viewvc/dirvish_1_3_ds/contrib/dirvish-setup.pl?sortby=log&view=diff&r1=80&r2=80&diff_format=s
my $cui = new Curses::UI ( -clear_on_exit => 1 ); 
my $question01 = $cui->dialog(
    -message => 'Press the button?',
    -buttons => ['yes','no'],
    -values  => [1,0],
    -title   => 'Question',
    );
if ($question01) { $cui->leave_curses; }
else { $cui->leave_curses; print "Goodbye\n"; exit; }

print "You press the button and the computer whirs to life.\n\n";
sleep 1;
print ITALIC, "*Whhhhhiiiirrrrrrr*\n", RESET;
sleep 1;
print ITALIC, "*Vvvvvvvrrrrrrrrrrrrr*\n", RESET;
sleep 2;
print ITALIC, "*BzzzRRRRRrrzzttt*\n", RESET;
sleep 2;
print ITALIC, "*DING!*\n\n", RESET;
print "Suddenly, a message appears .....\n";
ENTER_PROMPT();

$cui->dialog("Insert coins. 1 play = 75 cents\n\n");
$cui->leave_curses;

print "You think to yourself, \"That's strange, and proceed to check your pockets for some spare change.\"\n";

my $coinCount = 1;
my $stopCount = 0;
while ($coinCount <= 3) {
    print "=> Insert coin into cd drive? [", BOLD, "Y", RESET, "/", BOLD, "N", RESET, "] ";
    $input = <STDIN>;
    if ($input =~ /Y/i) {  
        print "You've inserted ".$coinCount;
	if ($coinCount == 1) { print " coin!\n"; }
	else { print " coins!\n"; }
	$coinCount += 1;
    }
    else { 
        if ($stopCount < 2) { print "Cmon, you know you want to play. Gimme all yer money\n"; }
	$stopCount += 1;
    }
    if ($stopCount == 3) { print "Guess you want to quit, huh?\n"; exit; } 
}

sub CHECK_MAP {
    my $cur_pos_x = 2;
    my $cur_pos_y = 3;
    my $position = "X";
    my $empty_space = "o";
    for(my $i=0; $i <= 4; $i++) {
        for(my $j=0; $j <= 4; $j++) {
	    if ($cur_pos_x == $i && $cur_pos_y == $j) { print "[$position]"; }
	    else { print "[$empty_space]"; }
	    }
	print "\n";
    }
}
CHECK_MAP();


#################################
# Print all character information
#################################
#print "$_ : $knight{$_}\n" for (keys %knight);
#print "\n";
#print "$_ : $sorc{$_}\n" for (keys %sorc);
print $knight{NAME}." and ".$sorc{NAME}." find a monster!\n";


# End
sleep 3; #change to like 20
my $finalQuestion = $cui->dialog(
    -message => 'What\'ll it be?',
    -buttons => ['yes','no'],
    -values  => [1,0],
    -title   => 'Question',
    );
if ($finalQuestion) { 
    $cui->leave_curses; 
    system("clear"); 
    print "\n\n\n\nMission Accomplished\n"; 
}
else { 
    $cui->leave_curses; 
    system("clear"); 
    print "\n\n\n\nNo\n"; 
}

system("clear");
my $town01 = << "EOL";
            |   _   _
      . | . x .|.|-|.|
   |\ ./.\-/.\-|.|.|.|
~~~|.|_|.|_|.|.|.|_|.|~~~
EOL
print $town01;
print "\nOut in the distance you see a town. You begin walking towards it\n";

ENTER_PROMPT();
system("clear");
my $town02 = << "EOL";
                      .|
                      | |
                      |'|            ._____
              ___    |  |            |.   |' .---"|
      _    .-'   '-. |  |     .--'|  ||   | _|    |
   .-'|  _.|  |    ||   '-__  |   |  |    ||      |
   |' | |.    |    ||       | |   |  |    ||      |
___|  '-'     '    ""       '-'   '-.'    '`      |____
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EOL
print $town01;
print "\nAs you get closer you realize this town is a lot larger than you thought. It's a goddamn city.\n";
ENTER_PROMPT();
system("clear");

my $town03 = << "EOL";
                                    +              #####
                                   / \
 _____        _____     __________/ o \/\_________      _________
|o o o|_______|    |___|               | | # # #  |____|o o o o  | /\
|o o o|  * * *|: ::|. .|               |o| # # #  |. . |o o o o  |//\\
|o o o|* * *  |::  |. .| []  []  []  []|o| # # #  |. . |o o o o  |((|))
|o o o|**  ** |:  :|. .| []  []  []    |o| # # #  |. . |o o o o  |((|))
|_[]__|__[]___|_||_|__<|____________;;_|_|___/\___|_.|_|____[]___|  |
EOL
print $town03;
print "\nWords and stuff. You're almost there.\n";
ENTER_PROMPT();
system("clear");

my $town04 = << "EOL";
.             .        .     .     |--|--|--|--|--|--|  |===|==|   /    i
        .            ______________|__|__|__|__|__|_ |  |===|==|  *  . /=\
__ *            .   /______________________________|-|  |===|==|       |=|  .
__|  .      .   .  //______________________________| :----------------------.
__|   /|\      _|_|//       ooooooooooooooooooooo  |-|                      |
__|  |/|\|__   ||l|/,-------8                   8 -| |                      |
__|._|/|\|||.l |[=|/,-------8                   8 -|-|       Welcome        |
__|[+|-|-||||li|[=|---------8                   8 -| |         to           |
_-----.|/| //:\_[=|\`-------8                   8 -|-|      Nightvale       |
 /|  /||//8/ :  8_|\`------ 8ooooooooooooooooooo8 -| |                      |
/=| //||/ |  .  | |\\_____________  ____  _________|-|                      |
==|//||  /   .   \ \\_____________ |X|  | _________| `---==------------==---'
==| ||  /         \ \_____________ |X| \| _________|     ||            ||
==| |~ /     .     \
LS|/  /             \______________________________________________________
EOL
print $town04;
print "\nWelcome to Nightvale\n";
ENTER_PROMPT();

