#!/usr/bin/perl

# ImagoTrigger@gmail.com
use common::sense;
use CGI qw(:standard -nph);
use CGI::Carp qw (fatalsToBrowser);

my $q = CGI->new;
my %vars = $q->Vars();

print $q->redirect('allegiance://'.$vars{game});

exit 0;

