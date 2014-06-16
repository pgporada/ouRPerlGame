#!/usr/bin/env  perl
use warnings;
use strict;
use feature qw(say);
use List::MoreUtils qw(uniq);
use Data::Dumper;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/ouRPerlGame';

use Inventory;
use Items;

my $bag = Inventory->new(color => 'brown');
say $bag->name." is ".$bag->color.".";
$bag->add_items(
    Sword01->new,
    Flail02->new,
    Sword02->new,
    Sword02->new,
    Sword02->new,
    Sword02->new,
    Flail02->new,
    Sword01->new,
    Sword01->new,
    Flail01->new,
);

my %seen;
my @unique;
say "It weighs ".$bag->weight."kg.";
say "Contents:";
foreach (sort $bag->contents) {
    if ( ! $seen{$_->name}++ ) {
        push @unique, $_->name;
        say "  ".$_->name;
        say "    weight: ".$_->weight."kg";
        say "    damage: ".$_->min_damage."-".$_->max_damage;
        say "    price: ".$_->price;
    }
        say "    stock: ".$seen{$_->name};

}



print "\n########\n";
print "Unique array\n";
print Dumper @unique;
print "Seen hash\n";
print Dumper %seen;
print "\n########\n";
#foreach (keys %counts) { print $counts{$_}."\n"; }
print "\n";

my $shop = Inventory->new;
say $shop->name." is ".$shop->color.".";
$shop->add_items(
    Flail02->new,
    Sword01->new,
    Sword02->new,
);
say "It weighs ".$shop->weight."kg.";
say "Contents:"; 

foreach ($shop->contents) {
    say "  ".$_->name;
    say "    weight: ".$_->weight."kg";
    say "    damage: ".$_->min_damage."-".$_->max_damage;
    say "    price: ".$_->price;
    say "    In stock: ";
}
