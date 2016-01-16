#!/usr/bin/perl -w
# extractSpecies.pl
# extracts lines for desired species from gene2refseq file
# Maria Stalteri
# 25/03/07

# get species ID from list of parameters
# read through gene2refseq file
# extract just the lines for the one species
# write to a new file
# so that programs mapping RefSeq ids to gene id
# only need to open a small file in computer memory

# parameters
# 1 - file to read
# 2 - species id to extract - get this from entrez gene
# 3 - file to write species specific lines to

# species codes - the NCBI tax_id from NCBI Taxonomy
# human 9606
# mouse 10090
# rat  10116


use strict;

# check for right number of parameters
unless (3 == scalar(@ARGV)) {
    die "Usage $0: gene2refseq file to extract lines from,
        genbank ID for desired species,
        file to write extracted species-specific lines to.\n";
}
 
my $file1 = $ARGV[0];
my $species = $ARGV[1];
my $output = $ARGV[2];

# check that output file doesn't already exist
if (-e $output) {
    die "Output file $output already exists.\n";
}

# open filehandles for input and output
open(INFILE, "<$file1")
   or die "Unable to read file $file1\n";

open(OUT, ">$output")
   or die "Unable to open outpu file $output\n";

while (my $line = <INFILE>) {
    if ($line =~ /^$species/) {
        print OUT $line;
    }
}


# close filehandles
close(INFILE)
   or die "Unable to close input file $file1.\n";

close(OUT)
   or die "Unable to close output file $output.\n";
