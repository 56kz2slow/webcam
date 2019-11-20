#!/usr/bin/perl

use strict;           # Don't forget !
use Net::FTP;

use POSIX qw(strftime);
use File::Copy;

# FTP variables
my $host = "52.36.136.128";
my $user = "56kz2slowCAM3";
my $password = "9BWFywS2";

# fswebcam options
my $controls = '--set saturation=120 --set brightness=10 --set sharpness=10 ';
my $image = '/var/www/html/webcam/image.jpg';
my $title = '--title "Millidgeville, NB"';
my $subtitle = '--subtitle "Weather Station ID: ISAINT148"';
my $info = '--info "Powered by Raspberry Pi"';
my $resolution = '-r 640x480';
my $capture = "fswebcam -q --top-banner $controls $title $subtitle $info $resolution $image";

# other variables
my $interval = 60;
my $run = 1;
my $debug = 0;
my $archive = '/var/www/html/webcamarchive';


my $date = strftime "%Y-%m-%d", localtime;
my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;

while ($run = 1) {


# capture image using fswebcam
if ($debug == 1) {print $capture,"\n"};
system("$capture");

sleep(5);

# archive files
my $date = strftime "%Y-%m-%d", localtime;
my $datetime = strftime "%Y-%m-%d_%Hh%M-%S", localtime;

chdir ($archive);
unless (-d $date) {
mkdir ($date) or die "can't create directory";
}
copy("$image","$archive/$date/$datetime-image.jpg");


# ftp my image to WU
if ($debug == 1) {print "Start FTP \n"};
my $f = Net::FTP->new($host) or die "Can't open $host\n";
$f->login($user, $password) or die "Can't log $user in\n";
$f->binary();
$f->put($image) or die "Can't put file";

if ($debug == 1) {print "Sleep for 60 seconds \n"};
sleep($interval-5);

}
