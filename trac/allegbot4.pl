#!/usr/bin/perl

# Imago <imagotrigger@gmail.com>
#  AllegBot - IRC interfaces to Trac (via. XML-RPC & Postgres) and JSON-RPCs to/from ZONE

use common::sense;
use DBI;
use AnyEvent;
use AnyEvent::IRC::Client;
use AnyEvent::JSONRPC::Lite::Server;
use RPC::XML::Client;
use String::IRC;
use POSIX qw(floor);
use URI::Escape;
use WWW::Mechanize;
use JSON;
#use Data::Dumper;

#setup!
my $tracurl = "http://trac.spacetechnology.net";
my $githuburl = "https://github.com/AllegianceZone/Allegiance";
my $chan = '#FreeAllegiance';
my $server = 'irc.quakenet.org';
my $name = 'AllegZoneBot';
open(PASS,'/home/imago/pass.txt'); my $pass = <PASS>; close PASS;

#play nice
setpriority(0, $$, 120);
my $cmd = "cpulimit -p $$ -l 15 -b";
system($cmd);

#IRC/JSON events
our $snow = time;
my $c = AnyEvent->condvar;
our $con = AnyEvent::IRC::Client->new( send_initial_whois => 1 );
our $srv = AnyEvent::JSONRPC::Lite::Server->new( port => 53312 ); #49153 outside
our $mech = WWW::Mechanize->new();

#callbacks
my $w = AnyEvent->idle (cb => sub { doIdle(time);});
$con->reg_cb(disconnect => sub { Connect(); });
#$con->reg_cb(debug_send => sub { print "Sending: ".Dumper(@_); });
#$con->reg_cb(debug_recv => sub { print "Received: ".Dumper(@_); });
$con->reg_cb(publicmsg => sub { my (undef,$chan,$msg) = @_; doMsg($msg); });
$srv->reg_cb(echo => sub {my ($res_cv, @params) = @_; $res_cv->result(@params); Echo(@params); });

#TODO Github!
#$srv->reg_cb(ping => sub {my ($res_cv, @params) = @_; $res_cv->result(@params); print Dumper(@params); });

#RPC & DB init
our $rpc = RPC::XML::Client->new("$tracurl/rpc");
our $cli = RPC::XML::Client->new("$tracurl/ircannouncer_service");
our $dbh = DBI->connect('dbi:Pg:dbname=trac', 'tracuser', $pass) or die "$!";
our $selb = $dbh->prepare(q{SELECT * FROM bitten_build WHERE id = ?}) or die $!;
our $selr = $dbh->prepare(q{SELECT * FROM revision WHERE rev = ?}) or die $!;
our $sela = $dbh->prepare(q{SELECT * FROM attachment WHERE type = 'build' AND id = ?}) or die $!;
our $sele = $dbh->prepare(q{SELECT * FROM bitten_error WHERE build = ? ORDER BY orderno DESC LIMIT 1}) or die $!;
our $sell = $dbh->prepare(q{SELECT * FROM bitten_build WHERE config = 'Allegiance' AND status = 'S' ORDER BY id DESC LIMIT 1}) or die $!;
our $selrl = $dbh->prepare(q{SELECT * FROM revision ORDER BY time DESC LIMIT 1}) or die $!;
our $seltl = $dbh->prepare(q{SELECT * FROM ticket ORDER BY changetime DESC LIMIT 1}) or die $!;
our $sels = $dbh->prepare(q{SELECT bitten_step.build, bitten_step.status, bitten_step.name, bitten_step.started, bitten_step.stopped, bitten_build.rev FROM bitten_step, bitten_build WHERE
        bitten_build.id = bitten_step.build AND slave = 'win-2cmgqr70q91' ORDER BY bitten_step.stopped DESC LIMIT 1;}) or die $!;

#DB events (yay postgres!)
our $sent = 0; #build start/end
$dbh->do("LISTEN ticket_update");
$dbh->do("LISTEN ticket_insert");
$dbh->do("LISTEN revision_insert");
$dbh->do("LISTEN bitten_insert");

#Join the IRC channel
Connect();

#Do callbacks
$c->wait;

#Done
$selb->finish;
$selr->finish;
$sela->finish;
$sele->finish;
$sell->finish;
$sels->finish;
$selrl->finish;
$seltl->finish;
$dbh->disconnect;
exit 0;  #Quit OK

#Helper to (re) join the IRC channel
sub Connect {
        print "Connecting to $server/$chan\n";
        $con->send_srv ("JOIN", $chan);
        $con->connect ($server, 6667, { nick => $name });
}

#Callback when no other callbacks are being called - Keeps DB cnxn alive, DBD::Pg will NOTIFY every 5 seconds (if available) - Sends chat announcment.
sub doIdle {
        my $now = shift;
        if ($now - 6 > $snow) {
                my $notify = $dbh->pg_notifies;
                if ($notify) {
                        my ($name, $pid, $payload) = @$notify;
                        if ($name eq 'ticket_update' || $name eq 'ticket_insert') {
                                $seltl->execute() or die $!;
                                my $tl = $seltl->fetchrow_hashref;
                                my $status = ($name eq 'ticket_update') ? String::IRC->new('Modified')->inverse->bold : String::IRC->new('Added')->inverse->bold;
                                #TODO: Make ticket update messages 'smarter' (look in ticket_change table)!
                                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, GetTicket($tl->{id}).' '.$status);
                                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$githuburl/issues/".$tl->{id})->light_blue);
                        } elsif($name eq 'revision_insert') {
                                $selrl->execute() or die $!;
                                my $rl = $selrl->fetchrow_hashref;
                                my $status = String::IRC->new('Added')->inverse->bold;
                                my $rev = $rl->{rev};
                                $rev =~ s/^0*//;
                                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, GetChange($rev).' '.$status);
                                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$githuburl/commit/".$rev)->light_blue);
                        } elsif($name eq 'bitten_insert') {
                                $sels->execute() or die $!;
                                my $s = $sels->fetchrow_hashref;
                                my $status = ($s->{status} eq 'S') ? String::IRC->new('Passed')->white('green')->bold : String::IRC->new('Failed')->white('red')->bold;
                                my $intro = String::IRC->new('Build')->bold->underline;
                                my $min = floor((($s->{stopped} - $s->{started}) / 60) + 0.5); #round up
                                my $msgprog = $intro .' b'.$s->{build}.' - Step: '.$s->{name}.' '.$status." took $min min.";
                                my $msgstart = $intro .' b'.$s->{build}.': In progress...';
                                my $valid = (time - $s->{stopped} < 30) ? 1 : 0; # never show old messages
                                if ($s->{name} eq 'Checkout' && $valid && !$sent) {
                                        $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, $msgstart); #start
                                        $sent = 1;
                                } elsif (($s->{status} eq 'F' || $s->{name} eq 'Finished') && $valid && $sent) {
                                        $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, GetBuild($s->{build})); #finish
                                        $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$tracurl/build/Allegiance/".$s->{build})->light_blue);
                                        $sent = 0;
                                        if ($s->{status} eq 'S') {
                                                my $build = $s->{build};
                                                my $rev = $s->{rev};
                                                open(LATEST,'>/etc/nginx/conf.d/installer.conf');
                                                print LATEST qq{server {
    listen   80;
    server_name installer.allegiancezone.com installer.spacetechnology.net installer;
    location / {
      rewrite ^ http://cdn.allegiancezone.com/install/AllegSetup_${build}.exe permanent;
    }
    location /latest {
      rewrite ^ http://cdn.allegiancezone.com/install/AllegSetup_${build}.exe permanent;
    }
    location /latest.exe {
      rewrite ^ http://cdn.allegiancezone.com/install/AllegSetup_${build}.exe permanent;
    }
}};
                                                close LATEST;
                                                system("sv restart nginx");
                                                DiscourseBuildPost("New update delivered! (build $build)","deployed-b${build}_$rev","The Allegiance Zone continuous delivery system has published a new version of the game!  Get it here: <a href=\"http://cdn.allegiancezone.com/install/AllegSetup_${build}.exe\">http://installer.allegiancezone.com/latest.exe?$snow</a><hr>$tracurl/build/Allegiance/$build","$tracurl/build/Allegiance/$build","http://cdn.allegiancezone.com/install/AllegSetup_${build}.exe");
                                        }
                                } else {
                                        #$con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, $msgprog) if ($valid); #step
                                }
                        }
                }
                $dbh->ping() or $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, "It seems I've lost the connection to trac, reconnected or quit."),
                        $dbh = DBI->connect('dbi:Pg:dbname=trac', 'tracuser', $pass) or die "$!";
                $snow = $now;
                sleep 5;
        }
}

#Callback when a chat is entered into the public channel - Sends chat reply
sub doMsg { # TODO: timer! (no flood)
        my $msg = shift;
        my $str = $msg->{params}[1];
        #URL titles just for fun...
        if ($msg->{prefix} !~ /AllegGitHubBot/)  {
                while ($str =~ /((http:\/\/|https:\/\/|www\.){1}.+)/gi) {
                        my $match = $1;
                        $match =~ s/^www\./http:\/\/www./gi;
                        my @parts = split(/\s/,$match);
                        if (my $title = GetTitle($parts[0])) {$con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, $title);}
                }
        }
        #tickets via Trac RPC API Plugin
        while ($str =~ /(ticket|bug|issue){1}\s?\#?\s?(\d+)/gi) {
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, GetTicketGithub($2));
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$githuburl/issues/$2")->light_blue);
        }
        #changesets via Trac IRCAnnouncer Plugin #TODO GITHUB!
        while ($str =~ /(change|changeset|commit){1}\s?\#?\s?(\w{7,})/gi) {
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, GetChangeGithub($2));
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$githuburl/commit/$2")->light_blue);
        }
        #builds via PgSQL
        while ($str =~ /(build|install|installer){1}\s?\#?\s?(\d+)/gi) {
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, GetBuild($2));
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$tracurl/build/Allegiance/$2")->light_blue);

        }
        #games via JSON
        GetGames() if ($str =~ /^\!games$/);

        #latest via PgSQL
        if ($str =~ /^\!latest$/) {
                my $ret = GetLatest();
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, $ret->{msg});
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$tracurl/build/Allegiance/".$ret->{id})->light_blue);
        }
        #search via PgSQL
        if ($str =~ /^\!search (.*)/) {
                my $q = uri_escape($1);
                #$con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, "Pshhh, find it yourself you lazy SOB...");
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, String::IRC->new("$githuburl/search?q=$q")->light_blue);
        }
}

#Helper when doMsg has a Ticket # - Formats IRC reply
sub GetTicket {
        my $tnum = shift;
        my @resp = $rpc->simple_request('ticket.get',$tnum);
        if ($resp[0] && $resp[0][0] == $tnum) {
                my $ticket = $resp[0][3];
                my $desc = $ticket->{description};
                $desc =~ s/\n+/ ** /gi;
                my $intro = String::IRC->new('Ticket')->bold->underline;
                #TODO: Color priority if >= major defect, Color grey priority if enhancment
                return $intro.' '.$ticket->{status}.' '.$ticket->{priority}.' '.$ticket->{type}." #$tnum: ".$ticket->{summary}.' By '.$ticket->{reporter}.' - '.$desc.' updated '.$ticket->{changetime};
        }
}
sub GetTicketGithub {
        my $issue = shift;
        $mech->get("https://api.github.com/repos/AllegianceZone/Allegiance/issues/$issue");
        if ($mech->success()) {
                my $res = $mech->res();
                my $ticket = decode_json($res->decoded_content);
                my $intro = String::IRC->new('Issue')->bold->underline;
                return $intro.' '.$ticket->{state}.' '.@{$ticket->{labels}}[0]->{name}." #$issue:  By ".$ticket->{user}->{login}.' - '.$ticket->{title}.' updated '.$ticket->{updated_at};
        }
}

sub GetChange {
        my $rev = shift;
        my $resp = $cli->simple_request('ircannouncer.getChangeset',$rev);
        if ($resp->{rev} == $rev) {
                my $desc = $resp->{message};
                $desc =~ s/\n+/ ** /gi;
                my $intro = String::IRC->new('Revision')->bold->underline;
                return $intro.' in '.$resp->{path}.' ('.$resp->{file_count}." files) for change $rev: By ".$resp->{author}.' - '.$desc;
        }
}
sub GetChangeGithub {
        my $rev = shift;
        $mech->get("https://api.github.com/repos/AllegianceZone/Allegiance/commits/$rev");
        if ($mech->success()) {
                my $res = $mech->res();
                my $commit = decode_json($res->decoded_content);
                my $intro = String::IRC->new('Commit')->bold->underline;
                my $desc = $commit->{commit}->{message};
                $desc =~ s/\n+/ ** /gi;
                return $intro.' in '.$githuburl.' ('.scalar @{$commit->{files}}." files) for change $rev: By ".$commit->{commit}->{author}->{name}.' - '.$desc;
        }
}

sub GetBuild {
        my $bid = shift;
        $selb->execute($bid) or die $!;
        my $b = $selb->fetchrow_hashref;
        if ($bid == $b->{id}) {
                my $status = ($b->{status} eq 'S') ? String::IRC->new('Passed')->white('green')->bold : String::IRC->new('Failed')->white('red')->bold;
                my $min = floor((($b->{stopped} - $b->{started}) / 60) + 0.5); #round up
                my $aid = $b->{config}.'/'.$bid;
                #$selr->execute($b->{rev}) or die $!;
                #my $r = $selr->fetchrow_hashref;
                $sela->execute($aid) or die $!;
                my $a = $sela->fetchrow_hashref;
                $sele->execute($bid) or die $!;
                my $e = $sele->fetchrow_hashref;
                my $intro = String::IRC->new('Build')->bold->underline;
                my $error = ($e->{build} && $b->{status} eq 'F') ? ' ** Step: '.$e->{step}.' last words were: "'.$e->{message}.'"' : '';
                my $attach = ($a->{id} && !$error) ? ' ** '. $a->{description}." - $tracurl/raw-attachment/build/$aid/".$a->{filename} : '';
                my $change = substr($b->{rev},0,10);
                return $intro ." b$bid: For change $githuburl/commit/$change $status in $min min.$attach$error";
        }
}

#Helper when doMsg has a !latest - calls GetBuild with latest green build ID
sub GetLatest {
        $sell->execute() or die $!;
        my $b = $sell->fetchrow_hashref;
        my $msg = GetBuild($b->{id});
        my %ret = (id => $b->{id}, msg => $msg);
        return \%ret;
}

sub GetTitle {
        my $url = shift;
        $mech->get($url);
        return ($mech->success()) ? $mech->title() : undef;
}

sub GetGames {
        $mech->get("http://allegiancezone.com/lobbyinfo.ashx");
        if ($mech->success()) {
                my $res = $mech->res();
                my $info = decode_json($res->decoded_content);
                my $intro = String::IRC->new('Total Players:')->bold->underline;
                my $totalplayers = 0;
                foreach my $info (@$info) {
                        $totalplayers += $info->{nNumPlayers};
                        my $link = String::IRC->new("http://azforum.cloudapp.net/launch.cgi?game=".$info->{dwCookie})->light_blue;
                        $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan,$info->{GameName} . " (".$info->{nNumPlayers}. ") $link");
                }
                $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan,"$intro $totalplayers");
        }
}

#Callback when a RPC using JSON via TCP is recieved for method `echo` - Sends chat reply
sub Echo {
        my @params = @_;
        $con->send_long_message ("iso-8859-1", 0, "PRIVMSG", $chan, $params[0]);
}

sub DiscourseBuildPost {
        my ($title,$meta,$text,$link,$dl) = @_;
        my $dbh = DBI->connect('dbi:Pg:dbname=discourse', 'discourse', undef) or die "$!";

        my $inst = $dbh->prepare(q{INSERT INTO topics (title, last_posted_at, created_at, updated_at, views, posts_count, user_id, last_post_user_id, reply_count, featured_user1_id, 
        featured_user2_id, featured_user3_id, avg_time, deleted_at, highest_post_number, image_url, off_topic_count, like_count, incoming_link_count, bookmark_count, 
        category_id, visible, moderator_posts_count, closed, archived, bumped_at, has_summary, vote_count, archetype, featured_user4_id, notify_moderators_count, spam_count, 
        illegal_count, inappropriate_count, pinned_at, score, percent_rank, notify_user_count, subtype, slug, auto_close_at, auto_close_user_id, auto_close_started_at, 
        deleted_by_id, participant_count, word_count, excerpt, pinned_globally) VALUES
        (?,NOW(),NOW(),NOW(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}) or die $!;

        my $inst2 = $dbh->prepare(q{INSERT INTO posts (user_id, topic_id, post_number, raw, cooked, created_at, updated_at, reply_to_post_number, reply_count, quote_count, deleted_at, 
        off_topic_count, like_count, incoming_link_count, bookmark_count, avg_time, score, reads, post_type, vote_count, sort_order, last_editor_id, hidden, hidden_reason_id, 
        notify_moderators_count, spam_count, illegal_count, inappropriate_count, last_version_at, user_deleted, reply_to_user_id, percent_rank, notify_user_count, like_score, 
        deleted_by_id, edit_reason, word_count, version, cook_method, wiki, baked_at, baked_version, hidden_at, self_edits, reply_quoted, via_email) VALUES
        (?,?,?,?,?,NOW(),NOW(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),?,?,?,?,?,?,?,?,?,?,?,NOW(),?,?,?,?,?)}) or die $!;

        my $inst3 = $dbh->prepare(q{INSERT INTO topic_links (topic_id, post_id, user_id, url, domain, internal, link_topic_id, created_at, updated_at, reflection, clicks, 
        link_post_id, title, crawled_at, quote)  VALUES (?,?,?,?,?,?,?,NOW(),NOW(),?,?,?,?,?,?)}) or die $!;

        $inst->execute($title,3,1,-1,-1,0,undef,undef,undef,undef,undef,1,undef,0,0,0,0,9,'t',0,'f','f','f',0,'regular',undef,0,0,0,0,undef,0,0,0,undef,$meta,undef,undef,undef,undef,1,128,"This is an AllegZoneBot generated message from: $link",'f');
        my $tid = $dbh->last_insert_id(undef,undef,"topics",undef);

        $inst2->execute(-1,$tid,1,$text,$text,undef,0,0,undef,0,0,0,0,0,2,3,1,0,1,-1,0,undef,0,0,0,0,0,undef,0,0,0,undef,undef,43,2,2,'f',1,undef,0,0,0);
        my $pid = $dbh->last_insert_id(undef,undef,"posts",undef);

        $inst3->execute($tid,$pid,-1,$dl,"cdn.allegiancezone.com",'t',undef,'f',0,undef,undef,undef,'f');

        $inst->finish;
        $inst2->finish;
        $inst3->finish;
        $dbh->disconnect;
}


__END__

-- Begin PL/PgSQL to enhance Trac database with external async. event notifications

-- Ticket Insert
CREATE FUNCTION notify_ticket_insert() RETURNS trigger AS $$
DECLARE
BEGIN
 execute 'NOTIFY ticket_insert';
 return new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER ticket_trigger_insert AFTER insert ON ticket EXECUTE PROCEDURE notify_ticket_insert();

-- Ticket Update
CREATE FUNCTION notify_ticket_update() RETURNS trigger AS $$
DECLARE
BEGIN
 execute 'NOTIFY ticket_update';
 return new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER ticket_trigger_update AFTER update ON ticket EXECUTE PROCEDURE notify_ticket_update();

-- Revision Insert
CREATE FUNCTION notify_revision_insert() RETURNS trigger AS $$
DECLARE
BEGIN
 execute 'NOTIFY revision_insert';
 return new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER revision_trigger_insert AFTER insert ON revision EXECUTE PROCEDURE notify_revision_insert();

-- Build Step Insert
CREATE FUNCTION notify_bitten_insert() RETURNS trigger AS $$
DECLARE
BEGIN
 execute 'NOTIFY bitten_insert';
 return new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER bitten_step_trigger_insert AFTER insert ON bitten_step EXECUTE PROCEDURE notify_bitten_insert();

-- End Procedures

