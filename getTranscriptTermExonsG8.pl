#!/usr/bin/perl -w
# getTranscriptTermExonsG8.pl
# 22/11/07
# Maria Stalteri

# 22/11/07 changes so it uses the subroutine ExtractBlatTermExonG8, which
# merges gaps < 9 bp in the alignments when calculating the coordinates of
# the 3' terminal exon

# 14/07/07 program name changed from mapProbesToTermExon.pl to
# getTranscriptTermExons.pl to more accurately describe what it does

# uses subroutine ExtractBlatTerminalExon which parses BLAT output in psl format
# the subroutine takes the highest scoring (greatest number of matching bases)
# alignment for each RefSeq NM_ transcript
# and returns the number of matching bases, and the start and end positions
# on the transcript, of the last alignment block 
# ASSUMPTION: THAT THE LAST ALIGNMENT BLOCK IS THE 3' TERMINAL EXON

# parameters
# 1. file with BLAT output in psl format for the subroutine to read
# 2. file to write the output to

use strict;
use ExtractBlatTermExonG8;

if (scalar(@ARGV) != 2) {
     die "Usage $0: file with BLAT output in psl format,
          name of output file\n";
}

my $file = $ARGV[0];
my $out = $ARGV[1];

# the subroutine returns a hash of arrays
# keys are RefSeq accession.version
# values are arrays - 
# [0] number of matching bases in alignment, 
# [1] start pos of last alignment block on transcript, 
# [2] end pos of last alignment block on transcript

my %termExon;
%termExon = &ExtractBlatTermExonG8::ExtractBlatTermExonG8($file);

# open filehandle for output
if (-e $out) {
     die "Output file $out already exists\n";
}

open(OUT, ">$out")
    or die "Output file $out already exists\n";

# print headers
my $todaysDate = `date`;

print OUT "# Date: $todaysDate\n";
print OUT "# Output from program: $0\n\n";

print OUT "# Results from blat  output file $file\n\n";

print OUT "# See end of this file for more results\n\n";


print OUT "BLAT ALIGNMENTS - START AND END POS OF 3' TERMINAL EXON\n\n";

print OUT "REFSEQ ID\tNUM OF MATCHING BASES\tSTART POS\tEND POS\n";

# print hash with results
foreach my $refseq (sort keys %termExon){
    print OUT "$refseq\t$termExon{$refseq}->[0]\t$termExon{$refseq}->[1]\t$termExon{$refseq}->[2]\n";
}    

close(OUT)
  or die "Unable to close output file $out\n";


