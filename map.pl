#!/usr/bin/env perl
use warnings;
use strict;
use Term::ANSIColor qw(:constants);
use Term::ExtendedColor qw(:all);
use utf8;
use feature qw(say);

my $user_color_choice = "sandybrown";
my $cur_position = 'X';
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
my $autoLook = 0;
my $autoMap = 0;

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
    'doom1' => 'idclip',
    'hexen' => 'casper',
    'doom2' => 'idspispopd',
    'heretic' => 'kitty',
    'chexquest' => 'charlesjacobi',
    'halflife' => 'noclip',
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
    	        print "[$cur_position]";
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
    preLeaveRoomCheck();
    my $input = shift;

    if ( $input =~ m/^N{1}O*R*T*H*$/ && @{$MapAoA[$MapLoc[4]]}[4] == 1) { 
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
        if (rand(101) >= 80) { 
            say RED."=> ".RESET."You should really ".BOLD."LOOK".RESET." where you're going";
        } 
        elsif (rand(101) >= 60) {
            say RED."=> ".RESET."Traveling into the ".BOLD.$input.RESET." wall is ill advised.";
        }
        elsif (rand(101) >= 40) {
            say RED."=> ".RESET."You've ran into the ".BOLD.$input.RESET." wall. Good job.";
        }
        elsif (rand(101) >= 20) {
            my $val = [@_=%cheats]->[1|rand@_];
            say RED."=> ".RESET."Despite how hard you want to walk through walls, you cannot. Try $val instead.";
        } 
        elsif (rand(101) >= 10) {
            say "You knock your noggin off the wall and hurt yourself! You lose 5hp.";
        } else {
            say "Your body attempts to merge with the wall in front of you. You lose 5hp."
        }
        return;
    }
    say "\n\n#-----------------------------------------------------------------#\n\n";
    postEnterRoomCheck();
}

sub ENTER_PROMPT {
    say "\nPress ".BOLD.CYAN."[ENTER]".RESET." to continue";
    my $input = <STDIN>;
    if ($input !~ /\012/) { ENTER_PROMPT(); }
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
        $cur_position = $impasse;
        say "\n\n".BOLD."Congrats, you beat the shit out of the game!".RESET."\n";
        ENTER_PROMPT();
        # Tests for existance and if it's not an empty file 
        -e "credits.pl" && -r "credits.pl" ? system("perl credits.pl") : print "[".RED."-".RESET."] Could not open credits.pl\n";
        # FINALE
        #system("/usr/bin/afplay Sounds/END.mp3 &");
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

sub postEnterRoomCheck {
    if ($autoMap == 1) {
        WHAT_DO("MAP");
    }
    if ($autoLook == 1) {
        WHAT_DO("LOOK");
    }
	say YELLOW."=> ".RESET."You just entered room: ".$MapLoc[0].",".$MapLoc[1]." via ".$MapLoc[2].",".$MapLoc[3];
}

sub preLeaveRoomCheck {
	say YELLOW."=> ".RESET."You attempt to leave room: ".$MapLoc[2].",".$MapLoc[3];
}

sub WHAT_DO {
        my $input = shift;
        if (not defined $input) {
            print "\nWhat would you like to do?\n".MAGENTA."%> ".RESET;
            $input = uc(<STDIN>);
            chomp($input);
        }
        # Help
        if ($input =~ /^H{1}E*L*P*$/ || $input =~ /^\?$/) {
            say GREEN."#----# ".RESET.RED.BOLD.UNDERLINE."HELP".RESET;
            print GREEN."# ".RESET."You can ";
            print BOLD."LOOK".RESET;
            print ", ".BOLD."GET".RESET;
            if ($haveMap == 1) { 
                print ", ".BOLD."MAP".RESET; 
            }
            print ", ".BOLD."CHECK".RESET;
            print ", ".BOLD."CLEAR".RESET;
            print ", ".BOLD."INV".RESET."[".BOLD."ENTORY".RESET."] ";
            print "and ".BOLD."READ".RESET.".\n"; 
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
        elsif ($input =~ m/^[cC]+[hH]+[eE]+[cC]+[kK]+$/ || $input =~ /^[iI]+[nN]+[vV]+[eE]*[nN]*[tT]*[oO]*[rR]*[yY]*$/) { 
            say "Current unimplemented";
        }
        # Get item in room
        elsif ($input =~ m/^[gG]+[eE]*[tT]*/) {
            say "Current unimplemented";
        }
        # Read <object> in room
        elsif ($input =~ /^[rR]+[eE]*[aA]*[dD]*/) {
            say "Current unimplemented";
        }
        elsif ($input =~ /^[cC]+[lL]+[eE]*[aA]*[rR]*$/) {
            system("clear");
        } else {
            if(rand(101) > 50) { 
                say RED."=> ".RESET."You can't do that here. Maybe you should seek ".BOLD."HELP".RESET."?";
            } else {
                say RED."=> ".RESET."You don't have a ".BOLD.$input.RESET;
            }
        }
}

sub main {
    system("clear");
    while(1) {
        UPDATE_MAP_DATA();
        STATUS();
        DO_SOMETHING();
        WHAT_DO();
    }
}

main();
