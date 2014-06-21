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
my $revealed = fg('blue3','-');
my $impasse = fg($user_color_choice,'#');
my $shop = fg('yellow9','$');
my $count_NS = 0;
my $count_EW = 0;
my $is_shop = 0;
my $has_bomb = 0;
my $impasse01_cleared = 0;
my $impasse11_cleared = 0;
my $have_help = 0;
my $main_boss_dead = 0;

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

system("clear"); 

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

sub tileTypeChecker {
	my $ascii_Up_Down="\x{2502}";
	my $ascii_Left_Right="\x{2500}";
	my $ascii_Top_Left_Corner="\x{250C}";	
	my $ascii_Bottom_Left_Corner="\x{2514}";
	my $ascii_Top_Right_Corner="\x{2510}";
	my $ascii_Bottom_Right_Corner="\x{2518}";
	my $ascii_3Way="\x{2524}";
}

sub CHECK_MAP {
    # Inner/Outer exist so that I can get 0-24 for X,Y to access the correct array and check if the 
    # current spot has been revealed. Without these, the entire row or column would be marked as revealed
    my $innerCount = 0;
    my $outerCount = 0;
    for(my $i=0; $i <= 4; $i++) {
        for(my $j=0; $j <= 4; $j++) {
	    # Prints your current position out from the @MapLoc array
            if ($MapLoc[0] == $j && $MapLoc[1] == $i) { 
	        print "[$cur_position]";
		
		# Changes the current positions state to "1" to reveal it
		# Upon traveling, the CHECK_MAP function is called so this will update your map correctly
		if (@{$MapAoA[$innerCount]}[2] == 0) { splice @{$MapAoA[$innerCount]},2,1,1; }

		# If you destroy the walls then the map should be updated accordingly
		if ($impasse01_cleared == 1 && @{$MapAoA[1]}[2] != 1) { splice @{$MapAoA[1]},2,1,0; }
		if ($impasse11_cleared == 1 && @{$MapAoA[6]}[2] != 1) { splice @{$MapAoA[6]},2,1,0; }
		
		# This allows the shop to be revealed, by default it is hidden. Basically it checks 
		# if the state is set to 3 then updates the is_shop global var accordingly. 
		# Probably not the smartest way, but eh it works so hey!
		if (@{$MapAoA[$innerCount]}[2] == 3) { $is_shop = 1; }
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



# MapAoA - exit N[4], exit S[5], exit E[6], exit W[7]
sub TRAVEL_DIR {
    local $Term::ANSIColor;
    print "\nWhich direction do you choose to travel? -+[ ";
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
    print "]+-\n=> ";
    GO_TO_TRAVEL_DIR();
}


sub GO_TO_TRAVEL_DIR {

    my $input = uc(<STDIN>);
    chomp($input);
        CHECK_MAP();

    if ( ($input =~ /^N[oO]*[rR]*[tT]*[hH]*$/ || $input =~ /^\^$/) && @{$MapAoA[$MapLoc[4]]}[4] == 1) { 
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

    elsif ( ($input =~ /^S[oO]*[uU]*[tT]*[hH]*$/ || $input =~ /^[vV]$/) && @{$MapAoA[$MapLoc[4]]}[5] == 1) { 
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

    elsif ( ($input =~ /^E[aA]*[sS]*[tT]*$/ || $input =~ /^\>$/) && @{$MapAoA[$MapLoc[4]]}[6] == 1) {
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

    elsif ( ($input =~ /^W[eE]*[sS]*[tT]*$/ || $input =~ /^\<$/) && @{$MapAoA[$MapLoc[4]]}[7] == 1) {
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
    }
}

sub ENTER_PROMPT {
    say "\nPress [ENTER] to continue";
    my $input = <STDIN>;
    if ($input !~ /\012/) { ENTER_PROMPT(); }
}

sub DO_SOMETHING {
    # Once you get help from the shopkeeper, the pathing can change to allow access to the rest of the map at 3,2
    if ($have_help == 1 && $MapLoc[0] == 3 && $MapLoc[1] == 2) {
        print "\nYour help offers to help out. You think to yourself, \"That's redundant.\"\n";
        print "\"".FAINT."On your word we'll get these logs out of the way.".RESET."\"\n";
        ENTER_PROMPT();
        splice @{$MapAoA[$MapLoc[4]]},4,1,1;
        $have_help = 2;
    }
   
    if ($have_help == 0 && $MapLoc[0] == 2 && $MapLoc[1] == 3) {
       print "\nThe shopkeeper offers his minions help to clear the path\n";
       $have_help = 1;
       ENTER_PROMPT();
    }

    # Script to destroy the impasse at 0,1 
    if ($MapLoc[0] == 2 && $MapLoc[1] == 0 && $impasse01_cleared == 0) {
       print "\nYou see a crack in the wall. As you investigate you realize you have a bomb to deal with this certain thing!\n";
      
       print "Use bomb? [".BOLD."Y".RESET."es ".BOLD."N".RESET."o ]\n=>";
       my $input = uc(<STDIN>);
       chomp($input);
       $impasse01_cleared = 1;
       CHECK_MAP();
       print $ascii_explosion."\n";
       system("/usr/bin/afplay Sounds/LOZ_Secret.wav &");
       splice @{$MapAoA[$MapLoc[4]]},7,1,1;
       ENTER_PROMPT();
    }

    # Script to destroy the impasse at 1,1 while standing in 0,1
    if ($MapLoc[0] == 1 && $MapLoc[1] == 0 && $impasse11_cleared == 0 && $impasse01_cleared == 1) {
       print "\nYou see a crack in the wall. As you investigate you realize you have a bomb to deal with this certain thing!\n";
       print "Use bomb? [".BOLD."Y".RESET."es ".BOLD."N".RESET."o ]\n=>";
       my $input = uc(<STDIN>);
       chomp($input);
       $impasse11_cleared = 1;
       CHECK_MAP();
       print $ascii_explosion."\n";
       system("/usr/bin/afplay Sounds/LOZ_Secret.wav &");
       splice @{$MapAoA[$MapLoc[4]]},5,1,1;
       ENTER_PROMPT();
    }

    # If the main boss has died, the room will start collapsing. The falling rocks chase you the rest of the way out of the dungeon.
    if ($MapLoc[0] == 4 && $MapLoc[1] == 2 && $main_boss_dead == 0) {
        print "\nYou fight the main boss!\n";
	ENTER_PROMPT();
	splice @{$MapAoA[$MapLoc[4]]},3,1,0;
	$main_boss_dead = 1;
    }
    if ($main_boss_dead == 1 && @{$MapAoA[$MapLoc[4]]}[2] == 1) {
        splice @{$MapAoA[$MapLoc[4]]},2,1,2;
    }
    if ($MapLoc[0] == 4 && $MapLoc[1] == 4) {
        $cur_position = $impasse;
        print "\n\n".BOLD."Congrats, you beat the shit out of the game!".RESET."\n\n";
        ENTER_PROMPT(); 
        -e "credits.pl" && -r "credits.pl" ? system("perl credits.pl") : print "[".RED."-".RESET."] Could not open credits.pl\n";
        exit;
	}
}

sub STATUS {
	           # Debug data structure stuff
#       print @$_, "\n" foreach ( @MapAoA );
		print "EW: ".$count_EW." NS: ".$count_NS."\n";
        print "X Y X Y ?\n";
        print $_." " foreach ( @MapLoc );
        print "\n";
	postEnterRoomCheck();
    preLeaveRoomCheck();
}

sub postEnterRoomCheck {
	say "You just entered room: ".$MapLoc[0].",".$MapLoc[1]." via ".$MapLoc[2].",".$MapLoc[3];
}

sub preLeaveRoomCheck {
	say "You're going to be leaving room: ".$MapLoc[0].",".$MapLoc[1];
}


sub main {
    while(1) {
    	STATUS();
        CHECK_MAP();
        TRAVEL_DIR();
        STATUS();
        DO_SOMETHING();
        system("clear"); # Currently will clear the screen. I need to add some sort of loop incase the player decides to wait in the room and perform actions.
    }
}

main();
