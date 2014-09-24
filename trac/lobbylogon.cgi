#!/usr/bin/perl

# ImagoTrigger@gmail.com
use common::sense;
use CGI qw(:standard -nph);
use CGI::Carp qw (fatalsToBrowser);
use DBI;

my $q = CGI->new;
print $q->header();
my %headers = map { $_ => $q->http($_) } $q->http();
if ($headers{HTTP_USER} && $q->user_agent() eq 'Allegiance') {
	my $dbh = DBI->connect('dbi:Pg:dbname=discourse', 'discourse', undef) or die "$!";
	my $sel = $dbh->prepare(q{select id, username, password_hash, salt, active, suspended_till from users where username = ?}) or die $!;
	$sel->execute($headers{HTTP_USER}) or die $!;
	my $user = $sel->fetchrow_hashref;
	print "OK\t".$user->{id}."\t".$user->{username}."\t".$user->{password_hash}."\t".$user->{salt}."\t".$user->{active}."\t".$user->{suspended_till}."\n";
	$sel->finish;
	$dbh->disconnect;
	exit 0;
}
exit 1;
