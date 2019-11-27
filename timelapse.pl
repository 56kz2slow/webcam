#!/usr/bin/perl

use strict;           # Don't forget !
#use Net::FTP;
use POSIX qw(strftime);
use File::Copy;
use Cwd qw(getcwd);

my $timelapse = "$webhome/timelapse";
my $timelapsesource = "$archive/$yesterday";
my $timelapselist = "$timelapsesource/stills.txt";
my $timelapsecmd = "ffmpeg -f concat -safe 0 -i '$timelapselist' -vcodec libx264 $timelapse/$yesterday-lapse.mp4";
my @files;
my $files;


# set date/time stamp variables for file and directory names
my $date = strftime "%Y-%m-%d", localtime;
my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;
my $yesterday = strftime "%Y-%m-%d", localtime(time - 23*3600);

        #create time lapse in $Yesterday
        my $timelapsesource = "$archive/$yesterday";
        my $timelapselist = "$timelapsesource/stills.txt";
        
        if ($debug) {print "\nMy timelapse source is: $timelapsesource\n"};
        if ($debug) {print "My file list is $timelapselist\n\n"};
       
       unless(open FILE, '>'.$timelapselist) {
            # Die with error message 
            # if we can't open it.
            die "\nUnable to create $timelapselist\n";
        }

        opendir (DIR, $timelapsesource) or die $!;
        my @listing = grep (/\.jpg$/,readdir(DIR));
        my @files = sort @listing;
        foreach $files (@files) {
        print FILE "file './$files'\n";
        }
        close FILE;

        if ($debug) {
            my $current = getcwd;
            print "Current directory is $current\n\n";
        }
        
        if ($debug) {print "=====================\n Timelapse command is:\n $timelapsecmd \n\n"};

        system($timelapsecmd);
