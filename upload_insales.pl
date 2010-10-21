#!/usr/bin/perl

use strict;
use warnings;
use WWW::Mechanize;
use utf8;

{
    package CFG;
    my $rc = do("./upload_insales.conf");
}

print "Please select site to upload:\n\n";
for (my $i=1; $i<=@{$CFG::c}; $i++) {
    print " [$i] - " . $CFG::c->[$i-1]{url} . "\n";
}

print "\n> ";
my $input = <>;
chomp $input;

if ( ($input =~ /^\d+$/) and ($input > 0) and ($input <= @{$CFG::c}) ) {
    print "Uploading to '" . $CFG::c->[$input-1]{url} . "'\n";

    # Create zip

    `zip a assets/* config/* templates/*`;

    unless ($?) {
        print " * Zip created\n";
    }
    else {
        die " * Error: can't create zip\n";
    }

    # Login

    my $mech = WWW::Mechanize->new();

    $mech->get( $CFG::c->[$input-1]{url} . "admin/login");
    $mech->submit_form(
        form_number => 1,
        fields      => {
            email       => $CFG::c->[$input-1]{email},
            password    => $CFG::c->[$input-1]{password},
        }
    );
    if ($mech->content =~ /<title>Учебный центр/g) {
        print " * Logged in successfully\n";
    }
    else {
        die " * Error: can't login\n";
    }

    # Upload

    $mech->follow_link( url => "/admin/theme" );
    $mech->form_number(1);
    $mech->field('import[zip]' => "a.zip");
    $mech->submit();

    if ($mech->content =~ /Файл загружен/g) {
        print " * Uploaded successfully\n";
    }
    else {
        die " * Error: can't upload\n";
    }

}
else {
    print "Incorrect input. Nothing done.";
}

