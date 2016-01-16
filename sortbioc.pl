#!/usr/bin/perl -w
# sortbioc.pl 
# 14/07/04
# M. Stalteri

# 15/08/04 renamed sortbioc.pl
# previous name was affylocusidbioc.pl

# 14/07/04 also modified to sort the BioC Symbol output

# 14/07/04 modified to use the BioConductor annotation
# package LOCUSID mapping
# and sort output by probe set id

# BioC output is in random order

# use a more general regex to match
# control probe set ids

# sorts files into list of 
# probe set ID and matching LL identifier

# probe sets that don't match to an LL id may return
# NA or na, with or without quotes

# remember that the moe430a package has a bug that returns
# 1 as LL id or A1BG as gene symbol

# make hash with probe set ID/LL id as key/value pairs
# probe set id is unique string identifier
# more than 1 probe set ID will map to same LL id

# call script with two arguments
# the file containing the BioC LocusId output
# and the file to write output to

use strict;
my %mouse;

unless (2 == scalar(@ARGV)) {
   die "Usage: $0 inputfile outputfile\n";
}

open(INFILE, $ARGV[0])
    or die "Unable to open input file $ARGV[0]\n";

if (-e "$ARGV[1]") {
    die "Output file $ARGV[1] already exists\n";
}
open (OUTFILE, ">$ARGV[1]")
    or die "Unable to open output file $ARGV[1]\n";

# count no of probe set ids in file
my $probeCount = 0;

while (my $line = <INFILE>) {
    # extract info from line beginning with $ (probe set ID))
    if ($line =~ /^\$"?(.+?)"?$/) {
        my $probeId = $1;
        $probeCount++;

        # if line is probe set id, look for LocusLink id
        # on next line        
        my $line2 = <INFILE>;
        my $locusId;
        if ($line2 =~ /^\[1]\s*"?(\S+?)"?$/) {
             $locusId = $1;
        }
        
        $mouse{$probeId} = $locusId;       
     } # end first if
        # check if regex matches anything
        # print to monitor
        #  print $probeId, "\n";

}    # end while
close (INFILE);

# count no of different probe set ID's by
# counting hash keys

my $noOfProbes = keys(%mouse);

print OUTFILE "OUTPUT FROM PROGRAM: $0\n";
print OUTFILE "INPUT FILE: $ARGV[0]\n\n";

print OUTFILE "No. of Probe Sets: $probeCount\n";
print OUTFILE "No of key/value pairs: $noOfProbes\n\n";
print OUTFILE "Probe Set ID:  LocusLink ID\n";

foreach my $entry (sort {lc($a) cmp lc($b)} keys %mouse) {
    print OUTFILE "$entry   $mouse{$entry}\n";
}   

close(OUTFILE)
    or die "Unable to close output file $ARGV[1]\n";


