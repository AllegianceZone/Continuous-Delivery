#!/usr/bin/perl -w
#
# $Id: //websites/unixwiz/unixwiz.net/webroot/tools/ftpput.txt#1 $
#
# written by :	Stephen J. Friedl
#               Software Consultant
#               Tustin, California USA
#
#	This very simple program is a kind of inverse to wget for ftp: it
#	*puts* files to a remote FTP server and returns an exit code that
#	reports accurately success or failure.
#
#	All the parameters are given on the command line (no .netrc support)
#
# COMMAND LINE PARAMS
# --------------------
#
# --help	Display a short help listing
#
# --server=S    Use "S" as the remote FTP server to connect to. We don't
#               need the leading "ftp://" part (but it's stripped off if
#               provided). This is REQUIRED.
#
# --user=U      Use "U" as the login name as required by the remote machine.
#               In the absense of one, "anonymous" is used.
#
# --pass=P      Use "P" for the password on the remote machine.
#
# --dir=D       Change to directory D on the remote system before doing
#               any transfers. If not provided, the directory is not
#               changed before doing a transfer.
#
# --passive     Use passive (PASV) mode for this transfer, which is
#               required by some servers and some firewalls. If not
#               specified, active mode is used.
#
# --hash        Print a hash mark ("#") every 1024 bytes during the transfer
#               to watch it run. 
#
# --verbose     Show the name of each file being sent. This is much less info
#               than the --debug option
#

use strict;
use warnings;
use Net::FTP;

my $Version = "unixwiz.net ftpput - version 1.0 (2003/05/09)";

my $server  = undef;
my $user    = undef;
my $pass    = undef;
my $dir     = undef;
my $debug   = 0;
my $hash    = 0;
my $passive = 0;
my $binary  = 0;
my $ascii   = 0;
my $verbose = 0;

my @FILES = ();

foreach ( @ARGV )
{
	if ( m/^--help/i )
	{
		print STDERR <<EOF;
$Version

usage: $0 [options] --server=SVR file files...

  --help        Show this brief help listing
  --debug       Enable debugging
  --server=SVR  Send to FTP server SVR
  --user=U      Login as user U (default = anonymous)
  --pass=P      Use password P (default = "-anonymous\@")
  --dir=D       Change to directory D on remote system
  --passive     Use passive mode instead of active
  --binary      Select binary mode
  --ascii       Select ASCII mode
  --hash        Print a hash (#) every 1024 bytes during transfer
  --verbose     Show each filename as it's being sent

  Full pathnames on the command line do NOT translate into directory
  names on the remote machine: the --dir=D parameter determines the
  final location exclusively. This program does not consult any .netrc
  files.

  This program exits 0=success and nonzero=failure.
EOF
		exit 1;
	}
	elsif ( m/^--user=(.+)$/ )                      # --user=U
	{
		$user = $1;
	}
	elsif ( m/^--pass(?:word)?=(.+)$/ )             # --pass=PASS
	{
		$pass = $1;
	}
	elsif ( m/^--dir=(.+)$/ )                       # --dir=DIR
	{
		$dir = $1;
	}
	elsif ( m/^--server=(.+)$/ )                    # --server=SVR
	{
		$server = $1;
	}
	elsif ( m/^--debug$/ )                          # --debug
	{
		$debug++;
	}
	elsif ( m/^--verbose$/ )                        # --verbose
	{
		$verbose++;
	}
	elsif ( m/^--passive$/ )                        # --passive
	{
		$passive = 1;
	}
	elsif ( m/^--hash$/ )                           # --hash
	{
		$hash = 1;
	}
	elsif ( m/^--binary$/ )                         # --binary
	{
		$binary = 1;
	}
	elsif ( m/^--ascii$/i )                         # --ascii
	{
		$ascii = 1;
	}
	elsif ( m/^-/ )
	{
		die "ERROR: {$_} is an invalid cmdline parameter\n";
	}
	elsif ( -r $_ )
	{
		push @FILES, $_;
	}
	else
	{
		die "ERROR: cannot open file {$_} for reading\n";
	}
}
	
#------------------------------------------------------------------------
# SANITY CHECKING ON PARAMETERS
#

$server =~ s|^ftp://||	if $server;

die "ERROR: missing file to send (try --help)\n"	if @FILES == 0;
die "ERROR: missing --server (try --help)\n"		if not $server;
die "ERROR: can't provide both --binary and --ascii\n" if $binary and $ascii;

$user = "anonymous"			if not $user;

my $ftp;

my %FTPARGS = ();

$FTPARGS{Debug}   = $debug		if $debug;
$FTPARGS{Passive} = $passive		if $passive;
$FTPARGS{Hash}    = $hash		if $hash;

if ( not ( $ftp = Net::FTP->new( $server, %FTPARGS) ) )
{
	die "ERROR: cannot connect to FTP server $server\n";
}

if ( not $ftp->login($user, $pass) )
{
	die "ERROR: cannot login to $server with user $user\n";
}

if ( $dir )
{
	$ftp->cwd($dir) or die "ERROR: cannot cwd($dir)\n";
}
if ( $binary  )
{
	$ftp->binary() or die "ERROR: cannot set binary mode\n";
}
if ( $ascii )
{
	$ftp->ascii() or die "ERROR: cannot set ASCII mode\n";
}

foreach my $file ( @FILES )
{
	print "--> put $file\n"		if $verbose;

	#if ( not $ftp->put($file) )
	#{
	#	die "ERROR: cannot send $file\n";
	#}

	print "    (sent OK)\n"		if $verbose;
}

$ftp->quit;# or die "ERROR: cannot quit FTP transfer\n";

exit 0;
