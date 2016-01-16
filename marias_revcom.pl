#!/usr/bin/perl -w
# ex12_3a.pl
# Maria Stalteri 24/06/04
# modified to give reverse complement of sequence

# call script wih two arguments
# a file in fasta format for input
# and a fasta file for output to be written to

use strict;
use Bio::SeqIO;

#create SeqIO objects $in and $out
my $in =Bio::SeqIO->new('-file'=>$ARGV[0],
                        '-format'=>'fasta');
my $out = Bio::SeqIO->new('-file'=>"> $ARGV[1]", '-format'=>'fasta');

#read in the seq using the in object's next_seq method which
#creates a nucleicAcid obj
#use the nucleicAcid objects's revcom method
#use the out object's write method to print out the  seq

while (my $seq = $in->next_seq()){

    my $revComp = $seq->revcom();
    $out->write_seq($revComp);

}

