	

    #Imago <imagotrigger@gmail.com>
    # corecheck.pl
    # Run from your text core folder in the Artwork subdirectory
     
    # This is a prototype for what is to come as upgrades to core2text
    #and text2core in allsrv -  Making it possible for core devs to easily
    #specify sound effects by name when developing/modding a core.
     
    use strict;
    use Spreadsheet::Read;
    use Data::Dumper;
     
     
    our $VERBOSE = 0;
     
     my $artpath = $ARGV[0];
     my $csvpath = $ARGV[1];
print "ArtPath: $artpath\nCSVPath: $csvpath\n\n";

    print STDERR "\tPROCESSING SOUNDS...\n";
     
    my @csvs = glob $csvpath.'*.csv';
    my @sfxs = ();
     
    foreach my $file (@csvs) {
     
            my $ref = ReadData ($file);
            my %table = %{$ref->[1]};
           
            my $col = 1;
            my $header = "ID";
     
            while ($header) {
                    $header = $table{cell}[$col][1];
                    if ($header =~ /SFX/i || ($file =~ /SFX/ && $header !~ /ID|NAME/)) {
                            my @ids = $table{cell}[$col];
                            push @sfxs, @ids;
                    }
                    $col++;
            }
    }
     
     
    my %wavs = ();
     
     
    open(SOUNDDEF,$artpath."trainingsounddef.mdl");
    my @lines = <SOUNDDEF>;
    close SOUNDDEF;
     
    my $linenum = 1;
    foreach my $line (@lines) {
            next if ($line =~ /\/\//);
            my $key = "";
            if ($line =~ /ImportWave\("(.*)"/) {
                    $key = $1;
                    $key.="__$line";
                    $wavs{$key}{found} = 1;
                    if ($line =~ /(.*)\s*=/) {
                            my $cleanvar = $1;
                            $cleanvar =~ s/\s//g;
                            $wavs{$key}{var} = $cleanvar;;
                    } else {
                            #print "err $linenum\n";
                    }
            }
    $linenum++;
     
    }
     
    open(SOUNDDEF,$artpath."sounddef.mdl");
    my @lines = <SOUNDDEF>;
    close SOUNDDEF;
    my @seen = ();
    my $linenum = 1;
    my $blist = 0;
    foreach my $line (@lines) {
            next if ($line =~ /\/\//);
            my $key = "";
            if ($line =~ /ImportWave\("(.*)"/) {
                    $key = $1;
                    $key.="__$line";
                    $wavs{$key}{found} = 1;
                    if ($line =~ /(.*)\s*=/) {
                            my $cleanvar = $1;
                            $cleanvar =~ s/\s//g;
                            $wavs{$key}{var} = $cleanvar;
                    } else {
                            #print "err $linenum\n";
                    }
            }
            $blist = 1 if ($line =~ /soundList =/);
            if ($blist) {
                    if ($line =~ /\((.+),\s*(.+)\)/) {
                            my $sid = $1;
                            $sid =~ s/\s//gi;
                            my $var = $2;
                            $var =~ s/\s//gi;
                            if ($sid =~ /\d+/ && $sid !~ /\D+/) {
                                    push(@seen,$sid);
                                    foreach my $keys (keys %wavs) {
                                            next if !$wavs{$keys}{var};
                                            my $a1 = $wavs{$keys}{var};
                                            my $a2 = $var;
                                            $a2 =~ s/SoundId//gi;
                                            $a1 =~ s/SoundId//gi;
                                            $a2 =~ s/Sound//gi;
                                            $a1 =~ s/Sound//gi;
                                            #print "checking $a1 vs $a2 for $sid\n";
                                            if ($a1 eq $a2 && $sid) {
                                                    $wavs{$keys}{id} = $sid;
                                            }
                                    }
                            }              
                    }
            }
    $linenum++;
     
    }
     
    my @sfxs = flatten(@sfxs);
     
    my $coretype = "";
    foreach my $id (@sfxs) {
            my $bfound = 0;
            if ($id !~ /\d+/ && $id) {
                    $coretype = $id;
                    next;
            }
            next if $id !~ /\d+/;
            foreach my $key (keys %wavs) {
                    next if !$wavs{$key}{id};
                    if ($id == $wavs{$key}{id}) {
                            #print "found $key for $id\n";
                            $bfound = 1;
                    }
            }
            print "WARNING: Couldn't find DEF for ID: $id ($coretype)\n" if (!$bfound && $id != -1 && $id != 0 && !grep(/$id/, @seen));
     
    }
     
     
    my @files1 = glob $artpath.'*.ogg';
    my @files2 = glob $artpath.'*.wav';
    my @files = flatten(@files1, @files2);
     
    my $size = 0;
    foreach my $artfile (@files) {
            $artfile =~ s/\.\.\///g;
            $artfile =~ s/\.ogg|\.wav//gi;
            my $bfound = 0;
            foreach my $sfxfile (keys %wavs) {
                    my $name = (split(/__/,$sfxfile))[0];
                    $bfound = 1 if(uc($artfile) eq uc($name));
            }
            if ($bfound) {
                    #print "$artfile OK\n";
            } else {
                    $size += -s $artpath."$artfile.ogg";
                    $size += -s $artpath."$artfile.wav";
                    print "INFO: $artfile unused in this core\n" if $VERBOSE;
            }
    }
    print "INFO: About ".( ($size / 1024) / 1024)."MB wasted!\n" if $VERBOSE;
     
     
    my %dedupe = ();
    foreach my $sfxfile (keys %wavs) {
            my $name = (split(/__/,$sfxfile))[0];
            my $bfound = 0;
            foreach my $artfile (@files) {
                    $artfile =~ s/\.\.\///g;
                    $artfile =~ s/\.ogg|\.wav//gi;
                    $bfound = 1 if(uc($artfile) eq uc($name));
                    $bfound = 1 if(uc($artfile) eq uc($wavs{$sfxfile}{var}));
                    #print "$name + $wavs{$sfxfile}{var} vs $artfile\n";
            }
            if ($bfound) {
                    #print "$artfile OK\n";
            } else {
                    $dedupe{$name} = 1;
            }
    }
     
    foreach my $key (keys %dedupe) {print "WARNING: Couldn't find ART for DEF $key\n";}
     
     
    print "\n--------------------------\n\n";
    print STDERR "\tPROCESSING GRAPHICS...\n";
     
    my @csvs = glob $csvpath.'*.csv';
    my @gfxs = ();
     
    foreach my $file (@csvs) {
     
            my $ref = ReadData ($file);
            my %table = %{$ref->[1]};
           
            my $col = 1;
            my $header = "ID";
     
            while ($header) {
                    $header = $table{cell}[$col][1];
                    if ($header =~ /TEXTURE|ICON|MODEL/i) {
                            my @ids = $table{cell}[$col];
                            push @gfxs, @ids;
                    }
                    $col++;
            }
    }
     
     
    my @gfxs = flatten(@gfxs);
    my @files = glob $artpath.'*.mdl';
     
     
    my $size = 0;
    foreach my $artfile (@files) {
            $artfile =~ s/\.\.\///g;
            $artfile =~ s/\.mdl//gi;
            my $bfound = 0;
            foreach my $gfx (@gfxs) {
                    next if !$gfx;
                    next if ($gfx =~ /MODEL|ICON|TEXTURE/);
                    my $bmp = $gfx."bmp";
                    if (uc($artfile) eq uc($gfx) || uc($bmp) eq uc($artfile)) {
                            $bfound = 1;
                    }
            }
            if ($bfound) {
     
            } else {
                    $size += -s $artpath."$artfile.mdl";
                    $size += -s $artpath."${artfile}bmp.mdl";
                    print "INFO: $artfile unused in this core\n" if $VERBOSE;
            }
    }
    print "INFO: About ".( ($size / 1024) / 1024)."MB wasted!\n" if $VERBOSE;
     
    my %dedupe = ();
    foreach my $gfx (@gfxs) {
            next if !$gfx;
            next if ($dedupe{$gfx});
            next if ($gfx =~ /MODEL|ICON|TEXTURE/);
            my $bfound = 0;
            foreach my $artfile (@files) {
                    $artfile =~ s/\.\.\///g;
                    $artfile =~ s/\.mdl//gi;
                    my $bmp = $gfx."bmp";
                    if (uc($artfile) eq uc($gfx) || uc($bmp) eq uc($artfile)) {
                            $bfound = 1;
                    }
            }
            if ($bfound) {
     
            } else {
                    print "WARNING: Couldn't find ART for DEF $gfx\n";
            }
            $dedupe{$gfx} =1;
    }
     
    #print Dumper(\@gfxs);
    #print Dumper(\@files);
     
     
    sub flatten { map ref eq q[ARRAY] ? flatten( @$_ ) : $_, @_ }
     
     
    __END__
    foreach my $file (@files) {
            foreach my $gfx (@gfxs) {
           
            }
    }

