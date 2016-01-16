#!/usr/bin/perl -w
# sortBlastResultsDeMelloNM.pl
# Maria Stalteri 18/02/07

# 21/03/07 regex modified to match accession versions >9
# DeMello variation, 18/02/07
# only probe sets where all probes match to a RefSeq
# NM_ identifier
# probe sets may map to more than 1 identifier
# and probes may align to more than 1 place

# calculate how many probe sets have all probes
# mapping to a RefSeq transcript as in DeMello et al, 2006
# get only probe sets where all 11 probes map to a NM_ RefSeq
# DeMello don't seem to count XM_, XR_, NR_ transcripts
# at least their final table seems only have NM_ IDs

# use ParseBlastD3.pm module to read D3 format output from BLAST
# call subroutine with 2 parameters
# name of blast output file to read
# name of Affymetrix array in capital letter (e.g. MOE430A)


########## parameters ################## 


use strict;
use ParseBlastD3;


my $blastFile = $ARGV[0];
my $chip = $ARGV[1];
my $output = $ARGV[2];

if (scalar(@ARGV) != 3) {
     die "Usage $0: file with BLAST output in D3 format,
          name of Affymetrix array in capital letters,
          output file";
}


# check that output file doesn't already exist

if (-e $output) {
      die "Output file $output already exists\n";
}

open(OUT, ">$output")
   or die "Unable to open output file $output\n"; 



my %probesets;

%probesets = &ParseBlastD3::ParseBlastD3($blastFile,$chip);


# hash returned is hash of hashes;
# the hashes are hashes of arrays
# main hash has keys - Affy probeset IDs;
# vlaues are hashes with RefSeqIDs as keys
# values are arrays containing the list of probe identifiers
# probe set ID plus probe x,y location on chip

# see if I can print the hash, to see if it seems to be working!

foreach my $affy (sort keys %probesets) {
     foreach my $refseq (sort keys %{$probesets{$affy}}) {
           foreach my $loc (sort @{$probesets{$affy}{$refseq}}){
#               print "$affy\t$refseq\t$loc\n\n";
           }
     }
}

# it seems to work

# count number of non-control probe sets with matches in blast results
my $blastProbes = keys(%probesets);

############## print headers for output file ##############################
my $todaysDate = `date`;

print OUT "# Date: $todaysDate\n";
print OUT "# Output from program: $0\n\n";

print OUT "# Results from megablast output file $blastFile\n";
print OUT "# AND probe sets from Affymetrix array $chip.\n\n";

print OUT "# See end of this file for more results\n\n";


print OUT "# MAPPING OF PROBES AND PROBE SETS TO REFSEQ SEQUENCES\n\n";
print OUT "# PROBESET ID\tREFSEQ IDs\tPROBES\n\n";

# make hash to take results for DeMello mapping
# my %demello;

# count probe sets with all 11 probes matching
# $manyProbes counts RefSeqs with 11 or more matches
# could be one probe matching more than once;
# so a probe set could be counted more than once
# because it is counting RefSeqs not probe sets

my $manyProbes = 0;
my %allProbes;

# probe sets with fewer than 11 unique probes matching
# probe sets (if any) with more than 11 unique probes matching
my ($notAll, $largeProbeset) = (0, 0);

# count number of lines printed
# one line for each affy ID and each RefSeq with 11 matching probes
my $noOfLines = 0;


foreach my $affyID (sort keys %probesets) {
    foreach my $rs (sort keys %{$probesets{$affyID}}) {
        # filter out XM_, NR_, XR_ refseqs;
        # use a regex that only matches NM_ refseqs
        # regex modified to match accession versions >9
	if($rs =~ /^NM_\d+\.?\d?\d?/){
            # filter out RefSeqs where fewer than 11 probes match
            # for moe430a and rae230a I think only the control
            # probe sets have more than or less than 11 probes            
            
            # note that at this point probe sets could have some
            # probes matching more than once, and not all 11 probes
            # matching            
            # make hash with unique probes as keys
            # occurrences as values
            if (scalar(@{$probesets{$affyID}{$rs}}) >= 11 ) {
               $manyProbes++;

               my %uniqueProbes;
               foreach my $xyIndex (@{$probesets{$affyID}{$rs}}) {
                   $uniqueProbes{$xyIndex}++;
               }

               # count number of different probes matching RefSeq
               my $noOfUniqueMatches = keys(%uniqueProbes);
               
               # only keep probe sets with 11 or more probes matching
               # note any with more than 11 probes

               if (11 == $noOfUniqueMatches) {
                     $allProbes{$affyID}++;

                     print OUT "$affyID\t$rs\t";
                     $noOfLines++;

                     foreach my $xy (sort @{$probesets{$affyID}{$rs}}){
                         print OUT "$xy, ";
                         
                     }  # end foreach array of probes
               } # endif
               elsif ( 11 < $noOfUniqueMatches) {
                     $allProbes{$affyID}++;
                     $largeProbeset++;
                     
                     # print to screen, cases of probes matching more than 11 times
                     print "More than 11 matches\n $affyID \t $rs \t @{$probesets{$affyID}{$rs}} \n";

                     print OUT "$affyID\t$rs\t";
                     $noOfLines++;

                     foreach my $xy (sort @{$probesets{$affyID}{$rs}}){
                        print OUT "$xy, ";
                      }  # end foreach array of probes
                } # end elsif
                else{
                   # fewer than 11 unique probes
                   $notAll++;                   
                   print "Fewer than 11 probes match\n $affyID\t$rs\tnumber of probes: $noOfUniqueMatches\n\n";
                }
                print OUT "\n";
             }# endif2 
         } # endif1
     } # end foreach %{$probesets{$affyID}}
} # end foreach %probesets 

# count probe sets with all 11 probes matching at least 1 RefSeq
my $noWithAllProbes = keys(%allProbes);


# print out statistics
print OUT "\n\n";
print OUT "# Number of probe sets in blast results: $blastProbes\n\n";

print OUT "# Number of probe sets and RefSeqs with 11 or more probes matching: $manyProbes\n";
print OUT "# a probe set with 11 or more probes matching more than 1 RefSeq will be counted more than once.\n\n";

print OUT "# Number of probe sets with 11 or more unique probes matching: $noWithAllProbes\n";
print OUT "# Number of probe sets with fewer than 11 unique probes matching: $notAll\n";
print OUT "# Number of probe sets with more than 11 unique probes matching: $largeProbeset\n\n";

print OUT "# Number of lines printed, one for each Affy ID and each RefSeq all probes map to: $noOfLines\n";


close(OUT)
  or die "Unable to close output file $output\n";






