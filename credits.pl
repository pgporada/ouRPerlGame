#!/usr/bin/env perl
use strict;
use warnings;
use Term::Screen;
use Term::ANSIColor qw(:constants);

sub ENTER_PROMPT {
    print "\nPress [ENTER] to continue\n";
    my $input = <STDIN>;
    if ($input !~ /\012/) { ENTER_PROMPT(); }
}

my $scr = new Term::Screen;
unless ($scr) { die " Something's wrong \n"; }
$scr->new;
$scr->clrscr();

my @creditsArray;
while (<DATA>) {
    chomp;
    push @creditsArray, $_;
}

sleep 1;
my $var; my $index=0; my $step=0;
for(my $i = $#creditsArray*2; $i >= 0 ; $i--) {
    # This block allows the text to scroll upwards using Jamars idea
    for (my $j = 0; $j <= $index ; $j++) {
        # Makes the == Headings == BOLD plus concatenates the line to $var
        if ($creditsArray[$j] =~ /==/) { $var .= "\n\t".BOLD.$creditsArray[$j].RESET; }
        elsif ($creditsArray[$j] =~ /You /) { $var .= "\n\t".BOLD RED.$creditsArray[$j].RESET; }
        # Concatenates the lines into $var and allows the screen to clear off all of the words from $var
        elsif ( $#creditsArray+$scr->rows < $index ) { $var .= "\n"; }
        # Regular lines that aren't == Headings == will have a new line and a tab char to sort of center them
        else { $var .= "\n\t ".$creditsArray[$j]; }
    }
        
    $scr->clrscr();
    # Draws the giant box
    $scr->at($i,0)->puts($var);
    for (my $i = 60; $i < 75; $i++) {
        for (my $j = 6; $j < 15 ; $j++) {
            $scr->at($j,$i)->puts(ON_BRIGHT_YELLOW." ");
        }
    }    

    if ($step == 0) { 
        $scr->at(8,64)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(9,71)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(10,70)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(11,69)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(12,68)->puts(ON_BRIGHT_RED."\|".RESET);

        $scr->at(8,70)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(9,63)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(8,64)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(10,64)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(11,65)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(12,66)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(13,67)->puts(ON_BRIGHT_RED."\|".RESET); 

        $scr->at(8,66)->puts(ON_BRIGHT_RED."\|".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\|".RESET); 

        $step=1; 
    }
    elsif ($step == 1) { 
        $scr->at(8,64)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(9,71)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(10,70)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(11,69)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(12,68)->puts(ON_BRIGHT_RED."\\".RESET);
 
        $scr->at(8,70)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(9,63)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(10,64)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(11,65)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(12,66)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(13,67)->puts(ON_BRIGHT_RED."\/".RESET); 

        $scr->at(8,66)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\/".RESET); 

        $step=2; 
    }
    elsif ($step == 2) { 
        $scr->at(8,64)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(9,71)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(10,70)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(11,69)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(12,68)->puts(ON_BRIGHT_RED."\-".RESET); 

        $scr->at(8,70)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(9,63)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(8,64)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(10,64)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(11,65)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(12,66)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(13,67)->puts(ON_BRIGHT_RED."\-".RESET); 

        $scr->at(8,66)->puts(ON_BRIGHT_RED."\-".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\-".RESET); 

        $step=3; 
    }
    elsif ($step == 3) {
        $scr->at(8,64)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(9,71)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(10,70)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(11,69)->puts(ON_BRIGHT_RED."\/".RESET); 
        $scr->at(12,68)->puts(ON_BRIGHT_RED."\/".RESET); 
 
        $scr->at(8,70)->puts(ON_BRIGHT_RED."\\".RESET);
        $scr->at(9,63)->puts(ON_BRIGHT_RED."\\".RESET);
        $scr->at(10,64)->puts(ON_BRIGHT_RED."\\".RESET);
        $scr->at(11,65)->puts(ON_BRIGHT_RED."\\".RESET);
        $scr->at(12,66)->puts(ON_BRIGHT_RED."\\".RESET);
        $scr->at(13,67)->puts(ON_BRIGHT_RED."\\".RESET);

        $scr->at(8,66)->puts(ON_BRIGHT_RED."\\".RESET); 
        $scr->at(8,68)->puts(ON_BRIGHT_RED."\/".RESET); 

        $step=0; 
    }
        # Bottom/Top of the heart
        $scr->at(13,67)->puts(ON_BRIGHT_RED."V".RESET); 
        $scr->at(9,67)->puts(ON_BRIGHT_RED."V".RESET); 
        $scr->at(7,65)->puts(ON_BRIGHT_RED."\^".RESET); 
        $scr->at(7,69)->puts(ON_BRIGHT_RED."\^".RESET); 
        # Fills in the heart
        $scr->at(8,65)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(8,69)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(9,64)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(9,65)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(9,66)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(9,68)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(9,69)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(9,70)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(10,65)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(10,66)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(10,67)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(10,68)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(10,69)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(11,66)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(11,67)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(11,68)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        $scr->at(12,67)->puts(ON_BRIGHT_MAGENTA."@".RESET);
        
        # Homes the cursor to 0,0 per documentation
        $scr->new;
        

    $var = ''; # Resets var to be nothing so we can rebuild the concatenated text block in the inner for loop
    $index++;
    select(undef, undef, undef, 0.40);
}
$scr->clrscr();
print "\n\n\n\n";
print "The end!\n\n\n\n";
ENTER_PROMPT();

__DATA__
== Lead Designer ==
Phil Porada

== Music ==
Phil Porada

== Sound ==
Phil Porada

== Coding ==
Phil Porada

== Story ==
Dan Porter
Phil Porada

== Cats ==
Lilly
Noodle
Palmer
Spooky 
Bitty Kitty
Script Kitty
NetCat
Max
Clogay
Harley

== Lead Coffee Consumers ==
Jenny Ingles
Phil Porada

== Listener to of my bullshit ==
Jenny Ingles

== Special Thanks ==
The Specials
Myself
Evan Cosby
Eric Greene
Johnny Basile
Ricky Martin
Greg Kitson
UmbertoUnity82 aka Andrew
Avrey Polni
Chris Baker
Chris Dogbert
Ron Filloon
Carl Roudabayga
JSON McNew
Cathryn SDS
Steph
Johnny Basile
Kyle Blakely
Josh Boivin
John rAmbrow
Jamar Vales
Jenny Ingles
Kristie & Kelsey
Mom & Dad
Babcia & Dzadiu & Dzadiu Porada

== Love == 
You :3 <3!
