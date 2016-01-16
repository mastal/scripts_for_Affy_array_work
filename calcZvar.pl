#!/usr/bin/perl -w
# calcZvar.pl
# 05/08/04
# M. Stalteri

# calcs variance for z-scores of probesets with same LL id
# try to put the variances back into the document

# call program with 3 arguments
# file with mapping of probesets and z-scores to LL id
# format of columns is: probesetid LLid zscore m i;
#  2 file to write output to
# output1 is list of LL ids and Z-score var sorted by decreasing var
# output2 is file with probeset id, z-score var, LL id, z-score, m, i

# use output file from sortZscores.pl as input

use strict;

unless (3 == scalar(@ARGV)) {
   die "Usage: $0 inputfile outputfile1 outputfile2\n";
}

open(IN1, $ARGV[0])
    or die "Unable to open input file $ARGV[0]\n";

if (-e "$ARGV[1]") {
    die "Output file $ARGV[1] already exists\n";
}
open (OUT, ">$ARGV[1]")
    or die "Unable to open output file $ARGV[1]\n";

if (-e "$ARGV[2]") {
    die "Output file $ARGV[2] already exists\n";
}
open (OUT4, ">$ARGV[2]")
    or die "Unable to open output file $ARGV[2]\n";


# note that rat control probe sets may have 'NotFound' as LL id
# other probe sets may have 'NA' as LL id


# count no of probe sets and probe sets with mapping to 'NA'
# or 'Not Found'

my ($probeCount, $locusNA) = (0, 0);
        
# read in file with the gc-rma and LL id data
# make two hashes

# hash %zScores 
# make hash with the probeset id as key
# the rest of data as value

# hash %zVar
# extract LL id and z-score into another hash, just as for calcZvar2.pl
# do the calc and put the results back into the first hash

my (%zScores, %zVar);
   
while (my $line = <IN1>) {
    # extract probeset id from line
    # extract rest of line
    # extract LL id
    # extract z-score

    if ($line =~ /^(.+?_at)\t((\w+)\t(\S+)\t.+)$/) {
        my $gcrmaProbeId = $1;
        my $locusId = $3;
        my $restOfLine = $2;
        my $zedScore = $4;
        $probeCount++;

        $zScores{$gcrmaProbeId} = $restOfLine;

        if ($locusId eq 'NA' or $locusId eq 'NotFound'){
             $locusNA++;    
        }
        else{
            push @{$zVar{$locusId}}, $zedScore;
        }
     }  # end regex if
} # end while


        
my $zScoreKeys = keys(%zScores);
my $zVarKeys = keys(%zVar);

# print stats for  hashes to screen
print "No of probe sets in file $ARGV[1]: $probeCount\n";
print "No of probe sets with 'NotFound' or 'NA' as LL id: $locusNA\n";
print "No of keys in hash zScores : $zScoreKeys\n";
print "No of keys in hash zVar: $zVarKeys\n\n";

close(IN1);

# go through hash and calc the variances for each locus
# make a new hash with variances as value LL id as key
# so it can be sorted by variance
# only put in variances for more than 1 Z-score

# count loci with > 1 Z-score (ie probe set) 

my %sortedZVar;
my $ZLoci = 0;

foreach my $locus (sort {$a <=> $b } keys %zVar){

    my $nZ = scalar(@{$zVar{$locus}});
    my $totZ = 0;
    foreach my $score (@{$zVar{$locus}}){       
      $totZ += $score;
    }
   
    my $meanZ = $totZ/$nZ;
    my $sumDiffSq = 0;    
    foreach my $score (@{$zVar{$locus}}){
       $sumDiffSq += ($score - $meanZ)**2;
    }
    my $varZ;
    if ($nZ > 1) {
        $varZ =  $sumDiffSq/($nZ - 1);
        $sortedZVar{$locus} = $varZ;
        $ZLoci++;
    }
    else {
        # return '*' for variance if there is only 1 z-score value
        $varZ = "*";
    }
}

my $noOfKeys = keys(%sortedZVar);

# print number of entries in hash $sortedZVar
print "Number of entries in hash %sortedZVar: $ZLoci\n";
print "Number of keys in hash sortedZVar: $noOfKeys\n";

foreach my $id (sort{$sortedZVar{$b} <=> $sortedZVar{$a}} keys %sortedZVar) {
    print OUT "$id\t$sortedZVar{$id}\n";
}

foreach my $probeSet (sort {lc($a) cmp lc($b)}  keys %zScores){
       print OUT4 "$probeSet\t";
       # extract LL id from hash (values are LLid z m i)
      
       my $LLid; 
       if ($zScores{$probeSet} =~ /^(\w+)\t/){
           $LLid = $1;
       }
       # if there is a Z-score var for the LL id
       if (exists $sortedZVar{$LLid}) {
       print OUT4 "$sortedZVar{$LLid}\t$zScores{$probeSet}\n";
       }
       else{
       print OUT4 "---\t$zScores{$probeSet}\n";

      }
}
       



close(OUT)
    or die "Unable to close output file $ARGV[1]\n";
            
close(OUT4)
    or die "Unable to close output file $ARGV[2]\n";






