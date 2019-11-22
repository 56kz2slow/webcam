#!/usr/bin/perl

use strict;           # Don't forget !
use Net::FTP;
use POSIX qw(strftime);
use File::Copy;

# misc variables
my $interval = 60;
my $continuous = 1;
my $debug = 1;
my $date = strftime "%Y-%m-%d", localtime;
my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;
my $webhome = '/var/www/html';
my $archive = "$webhome/webcamarchive";
my $timelapse = "$webhome/timelaspse";
my $date = strftime "%Y-%m-%d", localtime;
my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;
my $dir = $date;

# FTP variables
my $ftp = 1;
my $host = "52.36.136.128";
my $pwfile = 'passw.txt';  #password file should have CamID on 1st line, key on 2nd line
my ($user, $pass) = @ARGV;


# fswebcam options
my $option = '-q --top-banner -r 640x480';
my $controls = '--set saturation=120 --set brightness=10 --set sharpness=10 ';
my $title = '--title "Millidgeville, NB"';
my $subtitle = '--subtitle "Weather Station ID: ISAINT148"';
my $info = '--info "Powered by Raspberry Pi"';
my $image = "$webhome/webcam/image.jpg";
my $capture = "fswebcam $option $controls $title $subtitle $info $image";

# the real work starts here.  Loop every minute to capture image
while ($continuous == 1) {

    # capture image using fswebcam
    if ($debug == 1) {print "\n Start loop. \n =================\n $capture \n"};
    system("$capture");

    sleep(5);

    # set date/time stamp variables for file and directory names
    my $date = strftime "%Y-%m-%d", localtime;
    my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;
    chdir ($archive);
    
    #process this first run of each day
    unless (-d $date) {
        #create time lapse in $dir
        chdir ($archive/$dir);
        my $timelapsecmd = "/home/pi/timelapse.bsh $timelapse/$dir-lapse.mp4";
        if ($debug) {print $timelapsecmd,"\n"};
        system($timelapsecmd);
        #change $dir to today's date and create today's directory
        my $dir = $date;
        mkdir ($dir) or die "can't create directory";
          
    }
    
    # archive latest image
    copy("$image","$archive/$dir/$datetime-image.jpg");
    if ($debug) {print "copying $image to $archive/$dir/$datetime-image.jpg\n"};

    # ftp my image to WU
    if ($ftp) {

        if ($debug) {
            print "Start FTP \n";
        }
        my $f = Net::FTP->new($host) or die "Can't open $host\n";
       
        if ($debug) {
            print $f,"Connect\n";
            print "$user.\n";
            print "$pass.\n";
        }

        $f->login($user, $pass) ;
        if ($debug) {print $f,"Login\n"};
        $f->binary();
        if ($debug) {print $f,"Binary\n"};
        $f->put($image); #or die "Cant put file\n";
        if ($debug) {print $f,"Put\n"};
    }

    # sleep until next capture
    if ($debug == 1) {print "Sleep for 60 seconds \n"};
    sleep($interval-5);

}
