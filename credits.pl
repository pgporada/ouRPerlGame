#!/usr/bin/env perl
use strict;
use warnings;
use Term::Screen;
use Term::ANSIColor qw(:constants);

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
        # Concatenates the lines into $var and allows the screen to clear off all of the words from $var
        elsif ( $#creditsArray*2 < $index ) { $var .= "\n"; }
        # Regular lines that aren't == Headings == will have a new line and a tab char to sort of center them
        else { $var .= "\n\t ".$creditsArray[$j]; }
    }
        
    $scr->clrscr();
    $scr->at($i,0)->puts($var);
    
    if ($step == 0) { 
        $scr->at(8,64); 
        $scr->puts("\|"); 
        $scr->at(8,68); 
        $scr->puts("\|"); 
        $scr->at(9,71); 
        $scr->puts("\|"); 
        $scr->at(10,70); 
        $scr->puts("\|"); 
        $scr->at(11,69); 
        $scr->puts("\|"); 
        $scr->at(12,68); 
        $scr->puts("\|");

        $scr->at(8,70); 
        $scr->puts("\|"); 
        $scr->at(9,63); 
        $scr->puts("\|"); 
        $scr->at(8,64); 
        $scr->puts("\|"); 
        $scr->at(10,64); 
        $scr->puts("\|"); 
        $scr->at(11,65); 
        $scr->puts("\|"); 
        $scr->at(12,66); 
        $scr->puts("\|"); 
        $scr->at(13,67); 
        $scr->puts("\|"); 

        $scr->at(8,66); 
        $scr->puts("\|"); 
        $scr->at(8,68); 
        $scr->puts("\|"); 

        $step=1; 
    }
    elsif ($step == 1) { 
        $scr->at(8,64); 
        $scr->puts("\\"); 
        $scr->at(8,68); 
        $scr->puts("\\"); 
        $scr->at(9,71); 
        $scr->puts("\\"); 
        $scr->at(10,70); 
        $scr->puts("\\"); 
        $scr->at(11,69); 
        $scr->puts("\\"); 
        $scr->at(12,68); 
        $scr->puts("\\");
 
        $scr->at(8,70); 
        $scr->puts("\/"); 
        $scr->at(9,63); 
        $scr->puts("\/"); 
        $scr->at(10,64); 
        $scr->puts("\/"); 
        $scr->at(11,65); 
        $scr->puts("\/"); 
        $scr->at(12,66); 
        $scr->puts("\/"); 
        $scr->at(13,67); 
        $scr->puts("\/"); 

        $scr->at(8,66); 
        $scr->puts("\\"); 
        $scr->at(8,68); 
        $scr->puts("\/"); 

        $step=2; 
    }
    elsif ($step == 2) { 
        $scr->at(8,64); 
        $scr->puts("\-"); 
        $scr->at(8,68); 
        $scr->puts("\-"); 
        $scr->at(9,71); 
        $scr->puts("\-"); 
        $scr->at(10,70); 
        $scr->puts("\-"); 
        $scr->at(11,69); 
        $scr->puts("\-"); 
        $scr->at(12,68); 
        $scr->puts("\-"); 

        $scr->at(8,70); 
        $scr->puts("\-"); 
        $scr->at(9,63); 
        $scr->puts("\-"); 
        $scr->at(8,64); 
        $scr->puts("\-"); 
        $scr->at(10,64); 
        $scr->puts("\-"); 
        $scr->at(11,65); 
        $scr->puts("\-"); 
        $scr->at(12,66); 
        $scr->puts("\-"); 
        $scr->at(13,67); 
        $scr->puts("\-"); 

        $scr->at(8,66); 
        $scr->puts("\-"); 
        $scr->at(8,68); 
        $scr->puts("\-"); 

        $step=3; 
    }
    elsif ($step == 3) {
        $scr->at(8,64); 
        $scr->puts("\/"); 
        $scr->at(8,68); 
        $scr->puts("\/"); 
        $scr->at(9,71); 
        $scr->puts("\/"); 
        $scr->at(10,70); 
        $scr->puts("\/"); 
        $scr->at(11,69); 
        $scr->puts("\/"); 
        $scr->at(12,68); 
        $scr->puts("\/"); 
 
        $scr->at(8,70); 
        $scr->puts("\\"); 
        $scr->at(9,63); 
        $scr->puts("\\"); 
        $scr->at(10,64); 
        $scr->puts("\\"); 
        $scr->at(11,65); 
        $scr->puts("\\"); 
        $scr->at(12,66); 
        $scr->puts("\\"); 
        $scr->at(13,67); 
        $scr->puts("\\");

        $scr->at(8,66); 
        $scr->puts("\\"); 
        $scr->at(8,68); 
        $scr->puts("\/"); 

        $step=0; 
    }
        # Bottom/Top of the heart
        $scr->at(13,67);
        $scr->puts("V"); 
        $scr->at(9,67);
        $scr->puts("V"); 
        $scr->at(8,65);
        $scr->puts("\^"); 
        $scr->at(8,69);
        $scr->puts("\^"); 

    $var = ''; # Resets var to be nothing so we can rebuild the concatenated text block in the inner for loop
    $index++;
    sleep 1;
}

print "\n\n\n\n";
print "The end!\n\n\n\n";


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

== Lead Coffee Consumers ==
Jenny Ingles
Phil Porada

== Listener to of my bullshit ==
Jenny Ingles

== Cats ==
Lilly
Noodle
Palmer
Spooky 
Bitty Kitty
Script Kitty
NetCat

== Special Thanks ==
Myself
The Specials
Evan Cosby
Eric Greene
Johnny Basile
Ricky Martin
Greg Kitson
Chris Baker
Carl Roudabayga
JSON McNew
Kyle Blakely
Josh Boivin
Jamar Vales
Phil Porada
Jenny Ingles
Kristie & Kelsey
Mom & Dad
