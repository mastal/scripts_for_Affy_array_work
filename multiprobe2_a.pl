#!/usr/bin/perl -w
# multiprobe2_a.pl
# 12/06/04
# M. Stalteri

# script to read output from moe430aSYMBOL txt file
# make hash with gene name as key
# values are anonymous arrays with names of probe ids

# 20/08/04 Note: regex doesn't match control probe sets
# because they contain non-word chars (AFFX- )

# 06/07/04 modified to count no. of gene symbols
# 07/07/04 second regex modified to match 'NA' without quotes
# 07/07/04 case-insensitive sort for gene symbols

use strict;
my %probes;

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

while (my $line = <INFILE>) {
    if ($line =~ /^\$"(\w+)"$/) {
        my $probeId = $1;

        # check if regex matches anything
        print $probeId, "\n";

        my $line2 = <INFILE>;
        if ($line2 =~/^\[1]\s"?(\w+)"?$/) {
            my $geneSymbol =$1;

            # check if regex matches anything
            print $geneSymbol, "\n";           

            push @{$probes{$geneSymbol}}, $probeId;
        }
    }
}    
close (INFILE);

# count no of different Gene Symbols by
# counting hash keys
        
my $noOfGenes = keys(%probes);
        
print OUTFILE "No of Different Gene Symbols: $noOfGenes\n\n";
print OUTFILE "Gene Symbol:  no. of probe sets\n";
        
# need case-insensitive sort
foreach my $gene (sort {lc($a) cmp lc($b)} keys %probes) {
    print OUTFILE $gene, ":\n";
    foreach my $id (sort @{$probes{$gene}}) {
    print OUTFILE $id, " "; 
   }
   print OUTFILE "\n\n";
}   

close(OUTFILE)
    or die "Unable to close output file $ARGV[1]\n";
