#!/usr/bin/perl -w
# match1c.pl
# 25/06/04
# Maria Stalteri

# compares file with Affymetrix probe sequences to fasta sequence
# call script with three args - text file with probe sequences,
# fasta file with target, consensus, or genbank seq
# third arg is name of file to write output to

# revised to report string pos starting from 1 for biol sequences
# to avoid confusion, modified so that failure to match returns -1

# note that changing sequence to lc could cause problems
# because ucsc may write masked bases in lower case
# note that at the moment match will fail unless 
# probes and target/consensus/genome sequence are written in the same 
# case

use strict;

# check that script is called with right no. of arguments
unless( 3 == scalar(@ARGV)) {
    die "Usage $0: probe_file sequence_file output_file\n";
}

# open filehandles for input and output
open(IN1, $ARGV[0])
    or die "Unable to open input file $ARGV[0]\n"; 

open(IN2, $ARGV[1])
    or die "Unable to open input file $ARGV[1]\n"; 

# check that the output file doesn't already exist
if (-e $ARGV[2]) {
   die "Output file $ARGV[2] already exists\n";
}

open(OUT, ">$ARGV[2]")
    or die "Unable to open output file $ARGV[2]\n";

# check that it's in fasta format(first line starts with >)
# chomp the following lines and concatenate

my $target = "";
my $header;

# read the fasta file into an array and check that the first line
# begins with >
# if it does, remove the first line from the array
# and join the sequence into a single string

my @seq=  <IN2>;

if ($seq[0] =~ /^>/) {
     chomp(@seq);
     $header = shift(@seq);
     $target = join "", @seq;

}

# calculate length of sequence
my $seqLen = length($target);

# check that code is working- print to screen
print "target sequence:\n";
print "$target\n";

print OUT "OUTPUT FROM PROGRAM:  $0\n";
print OUT "PROBESET FILE: $ARGV[0]\n";
print OUT "SEQUENCE FILE: $ARGV[1]\n\n";

print OUT "Sequence length: $seqLen bases\n";
print OUT "Sequence header:   $header\n \n";  
print OUT "Probe \t Position in Sequence\n";

# probe sequence files are in the format given in the 
# Affymetrix probeset records:
# probe seq, probe x, probe y, interrogation pos, strandedness
# 25-oligo probe seqs are at start of line in probe file
# match each of the 11 probes in turn

my $probe = "";
while (my $line = <IN1>) {
   if ($line =~ /^([AaTtGgCc]{25})\s/){
       $probe = $1;  
       # check code
       print "$probe\n";
       
       # use the function index() to return first occurrence of 
       # probe sequence in larger sequence (target, consensus or genbank seq)    
       # note this returns pos of the first base in probe, not middle base       

       my $match = index($target, $probe, 0);
       # check code
       print "$match\n";       

       # convert string position to biological seq position
       # but only if a match is found
       # otherwise return -1 to avoid confusion

       my $biolPos = (-1 == $match) ? $match : $match + 1;

       print OUT "$probe \t  $biolPos \n";     

   }   
}

# close filehandles
close(IN1);
close(IN2);
close(OUT)
    or die "Unable to close outputfile $ARGV[2]\n";

