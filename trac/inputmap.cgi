#!/usr/bin/perl

# ImagoTrigger@gmail.com
use common::sense;
use File::Slurp;
use CGI qw(:standard -nph);
use CGI::Carp qw (fatalsToBrowser); 

my $q = CGI->new;
print $q->header();
my $data = $q->param( 'POSTDATA' );

my %headers = map { $_ => $q->http($_) } $q->http();
if ($headers{HTTP_USER} && $q->user_agent() eq 'Allegiance') {
	if (!$data) {
		print read_file("/var/www/inputmaps/".$headers{HTTP_USER}.".7z", binmode => ':raw');
	} else {
		open(MEM,">/var/www/inputmaps/".$headers{HTTP_USER}.".7z");
		binmode MEM;
		print MEM $data;
		close MEM;	
		print "OK\n";
	}
	exit 0;
}
exit 1;
