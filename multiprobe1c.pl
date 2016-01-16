#!/usr/bin/perl -w
# multiprobe1c.pl 
# 12/06/04
# M. Stalteri

# finds number of probe sets per gene symbol

# 20/08/04 note: the regex doesn't match the control
# probe sets, they have non-word characters like -

# script reads output from moe430aSYMBOL txt file,
# the list of probe set IDs and gene symbols
# produced by the BioConductor moe430a Annotation package

# sorts BioC annotation symbol output into
# list of gene symbols and number of probe sets
# per gene symbol

# call script with two arguments
# the file containing the BioC annotation
# symbol output,
# and the file to write output to

# make hash with gene name as key
# no. of probe sets as value

# 06/07/04  - modified so that the regex for gene symbol
# will match 'NA' without any quotes

# 06/07/04 modified to sort output first by  value,
# then alphabetically by gene symbol

# 07/07/04 modified to count number of gene symbols
# and number of probe sets

# 07/07/04 alphabetical sort modified to be case-insensitve
 
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
    if ($line =~ /^\$"(\w+)"$/) {
        my $probeId = $1;
        $probeCount++;

        # check if regex matches anything
        # print to monitor
        print $probeId, "\n";

        my $line2 = <INFILE>;
        # note that original regex would have missed any lines with 
        # [1] NA 
        # because no quote marks

        if ($line2 =~/^\[1]\s+"?(\w+)"?$/) {
            my $geneSymbol =$1;

            # check if regex matches anything
            print $geneSymbol, "\n";           

            $mouse{$geneSymbol}++;
        }
    }
}    
close (INFILE);

# count no of different Gene Symbols by
# counting hash keys
        
my $noOfGenes = keys(%mouse);

print OUTFILE "No of Probe Sets: $probeCount\n";        
print OUTFILE "No of Different Gene Symbols: $noOfGenes\n\n";

print OUTFILE "gene:   no. of probe sets\n";
        
# sort hash by value to find genes with multiple probe sets
# for each value, sort alphabetically by gene symbol

foreach my $gene (sort{$mouse{$b}<=>$mouse{$a} or lc($a) cmp lc( $b)} keys %mouse){
    print OUTFILE "$gene  $mouse{$gene}\n";
}   

close(OUTFILE)
    or die "Unable to close output file $ARGV[1]\n";
