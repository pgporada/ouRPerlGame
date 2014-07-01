#!/usr/bin/env perl -w
use strict;
use utf8;
use locale;
use Term::ANSIColor qw(:constants colored);
use Term::ExtendedColor qw(:all);
use Curses::UI;
use feature qw(say);

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
my $have_help = 0;
my $haveMap = 0;
my $autoLook = 1;
my $autoMap = 0;
my $cui = new Curses::UI ( -clear_on_exit => 1 ); 
$cui->leave_curses;

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

my %playerChar = (
    NAME => '"I\'m so bad at these names babe"',
    CLASS => '"Black, you said race"',
    PORTRAIT => 'o',
    CURRENT_HP => '100',
    MAX_HP => '100',
    LVL => '1',
    DMG_MIN => '10',
    DMG_MAX => '20',
    CRIT_CHANCE => '15',
    CURRENT_XP => '0',
    NEXT_LVL_XP => '100',
    TYPICAL => 'N'
    );

my %charClass = (
    Dwarf     => { PORTRAIT => 'o', DESC => 'This tiny Joe can fit in small crevices. Their short stature makes them hard to budge.'},
    Human     => { PORTRAIT => '@', DESC => 'Your average Joe. They can do what most other races can and can\'t'},
    Elf       => { PORTRAIT => '%', DESC => 'Your skinny pointy eared Joe. They\'re typically faster than most'},
    Orc       => { PORTRAIT => '&', DESC => 'Your typical ugly looking Joe. Orcs are tough and strong.'},
    Giant     => { PORTRAIT => 'O', DESC => 'Giants can reach the top of the refridgerator that old adventurers can no longer get to.'},
    Underling => { PORTRAIT => '_', DESC => 'Underlings slink by in the shadows and like to stay out of site. They like to go under things.'},
    Overling  => { PORTRAIT => '^', DESC => 'Overlings like to stay in shadows, but prefer to go over things.'},
    );

sub ENTER_PROMPT {
    say "\nPress ".BOLD.CYAN."[ENTER]".RESET." to continue";
    my $input = <STDIN>;
    if ($input !~ /\012/) { ENTER_PROMPT(); }
}

sub GAME_INTRO {
    #####################
    # GAME START SCREEN #
    #####################
    system("clear");

    print "\n\n\n";
    printf ("%65s", "##############################################\n");
    printf ("%70s",  colored("Quest Through The Deathly Dungeon of Doom!", "bold"));
    print "\n";
    printf ("%65s", "##############################################\n");
    printf ("%58s", "Version: Gettin out of alpha\n");
    ENTER_PROMPT();
    system("clear");
    say "Welcome!\n";
    sleep 1;
    say "You're in a small room with one window. You notice a chair sitting in";
    say "the corner of the room. There is a table with a computer on it in the";
    say "middle of the room";


    #e it in front of the monitor, and sit down.\n\nYou notice a button on the computer."; 
    ENTER_PROMPT();

    # 1) http://search.cpan.org/~mdxi/Curses-UI-0.9609/lib/Curses/UI.pm 
    # 2) http://www.dirvish.org/viewvc/dirvish_1_3_ds/contrib/dirvish-setup.pl?sortby=log&view=diff&r1=80&r2=80&diff_format=s
    my $question01 = $cui->dialog(
        -message => 'Press the button?',
        -buttons => ['yes','no'],
        -values  => [1,0],
        -title   => 'Question',
        );
    if ($question01) { $cui->leave_curses; }
    else { $cui->leave_curses; print "Goodbye\n"; exit; }

    say "You press the button and the computer whirs to life.\n";
    sleep 1;
    print ITALIC, "*Whhhhhiiiirrrrrrr*\n", RESET;
    sleep 1;
    print ITALIC, "*Vvvvvvvrrrrrrrrrrrrr*\n", RESET;
    sleep 2;
    print ITALIC, "*BzzzRRRRRrrzzttt*\n", RESET;
    sleep 2;
    print ITALIC, "*DING!*\n\n", RESET;
    say "Suddenly, a message appears .....";
    ENTER_PROMPT();

    $cui->dialog("Insert coins. 1 play = 75 cents\n\n");
    $cui->leave_curses;

    say "You think to yourself, \"That's strange, and proceed to check your pockets for some spare change.\"";

    my $coinCount = 1;
    my $stopCount = 0;
    while ($coinCount <= 3) {
        print "=> Insert coin into cd drive? [", BOLD, "Y", RESET, "/", BOLD, "N", RESET, "] ";
        my $input = uc(<STDIN>);
        if ($input =~ m/Y{1}E*S*/) { 
            print "You've inserted ".YELLOW.$coinCount.RESET; 
            if ($coinCount == 1) { 
                say " coin!"; 
            } else { 
                say " coins!"; 
            }
            $coinCount += 1;
        }
        else { 
            $stopCount += 1;
            if ($stopCount < 3) { say "Cmon, you know you want to play. Gimme all yer money"; }
            if ($stopCount == 3) { say "Guess you want to quit, huh?"; exit; } 
        }
    }

    say "\n\n#-----------------------------------------------------------------#\n\n";
    say "\nThe computer displays a character creation screen.\nYou lean in close to take a look.\n\n";
    say "If you choose to take the default values, just press ".CYAN."[ENTER]".RESET;
    print GREEN." \$ ".RESET."What do they call you? ".YELLOW."=> ".RESET;
    my $input = <STDIN>;
    chomp($input);
    if ($input) {
        $playerChar{NAME} = $input;      
    }
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
    sleep 15;
    my $finalQuestion = $cui->dialog(
        -message => 'What\'ll it be?',
        -buttons => ['yes','no'],
        -values  => [1,0],
        -title   => 'Question',
        );
    if ($finalQuestion) { 
        $cui->leave_curses; 
        system("clear"); 
        say "\n\n\n\nMission Accomplished";
        system("open \"END.png\"")
    }
    else { 
        $cui->leave_curses; 
        system("clear"); 
        print "\n\n\n\nNo\n"; 
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
		       [3,2,0,0,0,1,0,1,1,0], #[13]
		       [4,2,0,0,0,1,0,0,1,0], #[14]
		       [0,3,0,0,1,1,0,0,1,0], #[15]
		       [1,3,0,0,1,1,0,0,1,0], #[16]
		       [2,3,3,0,0,1,0,0,1,0], #[17]
		       [3,3,0,0,1,1,0,0,1,0], #[18]
		       [4,3,0,0,0,1,0,0,1,0], #[19]
		       [0,4,0,0,1,0,1,0,1,0], #[20]
		       [1,4,0,0,1,0,0,1,1,0], #[21]
		       [2,4,0,0,1,0,1,0,1,0], #[22]
		       [3,4,0,0,1,0,0,1,1,0], #[23]
		       [4,4,0,0,0,1,0,0,1,0]  #[24]
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
            say "You knock your noggin off the wall and hurt yourself! ".RED."You lose 5hp".RESET.".";
            $playerChar{CURRENT_HP} -= 5;
        } else {
            say "Your body attempts to merge with the wall in front of you.".RED."You lose 5hp".RESET.".";
            $playerChar{CURRENT_HP} -= 5; 
        }
        return;
    }
    say "\n\n#-----------------------------------------------------------------#\n\n";
    POSTENTERROOMCHECK();
}


sub DO_SOMETHING {
    if ($MapLoc[0] == 0 && $MapLoc[1] == 0 && $initialHelpScreen == 1) {
        $initialHelpScreen = 0;
        WHAT_DO("HELP");
    }       
    
    if ($MapLoc[0] == 0 && $MapLoc[1] == 3 && $haveMap == 0) {
        say YELLOW."\n=> ".RESET.BOLD."You found a map!".RESET;
        say YELLOW."=> ".RESET."Take time to review the ".BOLD."HELP".RESET." options. During gameplay, acquiring items will alter the possible available actions of your character.\n";
        $haveMap = 1;
        WHAT_DO("HELP");
    }

    # Once you get help from the shopkeeper, the pathing can change to allow access to the rest of the map at 3,2
    if ($have_help == 1 && $MapLoc[0] == 3 && $MapLoc[1] == 2) {
        say "Your help offers to help out. You think to yourself, \"That's redundant.\"";
        say "\"".FAINT."On your word we'll get these logs out of the way.".RESET."\"";
        ENTER_PROMPT();
        splice @{$MapAoA[$MapLoc[4]]},4,1,1;
        $have_help = 2;
    }
   
    if ($have_help == 0 && $MapLoc[0] == 2 && $MapLoc[1] == 3) {
       say YELLOW."=> ".RESET."The shopkeeper offers his minions help to clear the path";
       $have_help = 1;
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

    # If the main boss has died, the room will start collapsing. The falling rocks chase you the rest of the way out of the dungeon.
    if ($MapLoc[0] == 4 && $MapLoc[1] == 2 && $main_boss_dead == 0) {
        say YELLOW."\n=> ".RESET."You fight the ".RED.BOLD."Main Boss".RESET."!";
	    ENTER_PROMPT();
    	splice @{$MapAoA[$MapLoc[4]]},3,1,0;
    	$main_boss_dead = 1;
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

sub STATUS {
   # print @$_, "\n" foreach ( @MapAoA );
   # print "EW: ".$count_EW." NS: ".$count_NS."\n";
   # print "X Y X Y ?\n";
   # print $_." " foreach ( @MapLoc );
   # print "\n";
}

sub POSTENTERROOMCHECK {
    if ($autoMap == 1 && $haveMap == 1) {
        WHAT_DO("MAP");
    }
    if ($autoLook == 1) {
        WHAT_DO("LOOK");
    }
	say YELLOW."=> ".RESET."You just entered room: ".$MapLoc[0].",".$MapLoc[1]." via ".$MapLoc[2].",".$MapLoc[3];

    # Random monster check
    if (@{$MapAoA[$MapLoc[4]]}[8] == 1 && rand(101) > 50) {
        say "A wild monster appears!"
    } else {
        if (rand(101) > 75) { say YELLOW."=> ".RESET."You feel as if you're being watched."; }
        elsif (rand(101) > 75) { say YELLOW."=> ".RESET."You feel unsettled."; }
        elsif (rand(101) > 75) { say YELLOW."=> ".RESET."You see a shadow dart across the distance."; }
        else { say YELLOW."=> ".RESET."No matter how much you try to relax, the knot in your stomach persists."; }
    }
}

sub PRELEAVEROOMCHECK {
	say YELLOW."=> ".RESET."You attempt to leave room: ".$MapLoc[2].",".$MapLoc[3];

    # Random monster check
    if (@{$MapAoA[$MapLoc[4]]}[8] == 1 && rand(101) > 33) {
        say YELLOW."=> ".RESET."As you approach the exit, a monster appears out of nowhere and lunges at you!"
    }
}

sub WHAT_DO {
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
            say GREEN."#----# ".RESET.RED.BOLD.UNDERLINE."HELP".RESET;
            print GREEN."# ".RESET."You can ";
            print BOLD."LOOK".RESET;
            print ", ".BOLD."GET".RESET;
            if ($haveMap == 1) { 
                print ", ".BOLD."MAP".RESET; 
            }
            print ", ".BOLD."CLEAR".RESET;
            print ", ".BOLD."INV".RESET."[".BOLD."ENTORY".RESET."] ";
            say "and ".BOLD."READ".RESET; 
            say GREEN."#----# ".RESET.RED.BOLD.UNDERLINE."TIPS".RESET;
            say GREEN."# ".RESET."If you ".BOLD."LOOK".RESET.", you can travel in one of the returned directions.";
            say GREEN."# ".RESET."Typing ".BOLD."AUTOLOOK".RESET." will enable/disable automatically checking directions when you enter a room.";
            if ($haveMap == 1) {
                say GREEN."# ".RESET."Typing ".BOLD."AUTOMAP".RESET." will enable/disable automatically viewing the map when you enter a room.";
            }
            say GREEN."# ".RESET."Typing ".BOLD."HELP".RESET." or ".BOLD."?".RESET." will show this menu again.";
            say GREEN."#----#".RESET;
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
                WHAT_DO("MAP");
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
            say "Current unimplemented";
        }
        # Get item in room
        elsif ($input =~ m/^G{1}E*T*/) {
            say "Current unimplemented";
        }
        # Read <object> in room
        elsif ($input =~ m/^R{1}E*A*D*/) {
            say "Current unimplemented";
        }
        elsif ($input =~ m/^C{1}H*A*R*A*C*T*E*R*$/) {
            printf("%-24s %3s %-35s", BOLD."Name".RESET, " : ", $playerChar{NAME}); print "\n";
            printf("%-24s %3s %-35s", BOLD."Class".RESET, " : ", $playerChar{CLASS}); print "\n";
            printf("%-24s %3s %-35s", BOLD."Level".RESET, " : ", $playerChar{LVL}); print "\n";
            
            my $HP_STATUS = ($playerChar{CURRENT_HP} / $playerChar{MAX_HP}) * 100;
            if ($HP_STATUS >= 75) {
                use integer;
                printf("%-24s %3s %-35s", BOLD."HP".RESET, " : ", GREEN.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET); print "\n";
            }
            elsif ($HP_STATUS >= 40) {
                use integer;
                printf("%-24s %3s %-35s", BOLD."HP".RESET, " : ", YELLOW.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET); print "\n";
            } else {
                printf("%-24s %3s %-35s", BOLD."HP".RESET, " : ", RED.$playerChar{CURRENT_HP}.RESET."/".GREEN.$playerChar{MAX_HP}.RESET); print "\n";
            }
            
            printf("%-24s %3s %-35s", BOLD."DMG".RESET, " : ", $playerChar{DMG_MIN}."-".$playerChar{DMG_MAX}); print "\n";
            printf("%-24s %3s %-35s", BOLD."XP to next level".RESET, " : ", $playerChar{CURRENT_XP}."/".$playerChar{NEXT_LVL_XP}); print "\n";
        }
        elsif ($input =~ m/^CLEAR$/) {
            system("clear");
        } else {
            if(rand(101) > 50) { 
                say RED."=> ".RESET."You can't do that here. Maybe you should seek ".BOLD."HELP".RESET."?";
            } else {
                say RED."=> ".RESET."You don't have a ".BOLD.$input.RESET;
            }
        }
}

sub MAIN {
    GAME_INTRO();
    system("clear");
    while(1) {
        UPDATE_MAP_DATA();
        STATUS();
        DO_SOMETHING();
        WHAT_DO();
    }
}

MAIN();
