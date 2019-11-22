#!/usr/bin/perl

use strict;           # Don't forget !
use Net::FTP;
use POSIX qw(strftime);
use File::Copy;
use Cwd qw(getcwd);

# misc variables
my $interval = 60;
my $continuous = 1;
my $debug = 1;
my $date = strftime "%Y-%m-%d", localtime;
my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;
my $yesterday = strftime "%Y-%m-%d", localtime(time - 23*3600);
my $webhome = '/var/www/html';
my $archive = "$webhome/webcamarchive";
my $timelapse = "$webhome/timelapse";
my $timelapsesource = "$archive/$yesterday";
my $timelapselist = "$timelapsesource/stills.txt";
my $timelapsecmd = "ffmpeg -f concat -safe 0 -i '$timelapselist' -vcodec libx264 $timelapse/$yesterday-lapse.mp4";
my @files;
my $files;



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
    if ($debug == 1) {print "\n Start loop. \n =================\n $capture \n\n"};
    system("$capture");

    #sleep(5);

    # set date/time stamp variables for file and directory names
    my $date = strftime "%Y-%m-%d", localtime;
    my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;
    my $yesterday = strftime "%Y-%m-%d", localtime(time - 23*3600);
    chdir ($archive);

    if ($debug) {print "My date is$date\n"};
    if ($debug) {print "My datetime is $datetime\n\n"};
    if ($debug) {print "Yesterday is $yesterday\n\n"};
    
    my $current = getcwd;
    if ($debug) {print "My cwd is $current\n\n"};
    
    #process this first run of each day
    unless (-d $date) {
        if ($debug) {print "Entering new day\n"};
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
        my @files = grep (/\.jpg$/,readdir(DIR));
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
        
        #change $Yesterday to today's date and create today's directory
        chdir ($archive/$date);
        mkdir ($date) or die "can't create directory";
        if ($debug) {print "My dir is: $date\n"};  
    }
    
    # archive latest image
    copy("$image","$archive/$date/$datetime-image.jpg");
    if ($debug) {print "copying $image to $archive/$date/$datetime-image.jpg\n"};

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
