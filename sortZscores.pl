#!/usr/bin/perl -w
# sortZscores.pl
# 01/08/04
# M. Stalteri

# sorts gcrma zscores by LL id

# call program with 3 arguments
# file with mapping of probe set ids to genes
# file with gcrma Z-scores
# file to write output to

# mapping of probe set ids to genes:
# use LL ids from BioC or from affy annot(csv) file

# read the file with probe set id mappings into hash
# key is probe set id, value is gene(LL id, or other)

# read the gcrma file, lookup gene(LL id) from hash
# add LL id to the line with Z-scores
# store as another hash (probeid as key, rest of line
# starting with locus id as value)
# sort by locusid 
# print as tab delimited lines
# probeid locusid zscore m i

use strict;

unless (3 == scalar(@ARGV)) {
   die "Usage: $0 inputfile1 inputfile2 outputfile\n";
}

open(IN1, $ARGV[0])
    or die "Unable to open input file $ARGV[0]\n";

open(IN2, $ARGV[1])
    or die "Unable to open input file $ARGV[1]\n";

if (-e "$ARGV[2]") {
    die "Output file $ARGV[2] already exists\n";
}
open (OUT, ">$ARGV[2]")
    or die "Unable to open output file $ARGV[2]\n";

# read BioC output with Locusid mappings 
# extract probe ids and LL ids into hash

# note that the rae230 BioC packages have no mappings 
# for the control genes

my %locus;

# count no of probe sets and probe sets with mapping to 'NA'
my ($probeCountBioC, $BioCNoId) = (0, 0);

while (my $line = <IN1>) {
    # extract probeset id from line beg. with $   
    if ($line =~ /^\$"(.+_at)"$/) {
        my $BioCProbeId = $1;
        $probeCountBioC++;

        # extract LL id from line beg. with [1]
        # LL id is either numbers or 'NA'
        my $line = <IN1>;
        my $BioCLocusId;
        if ($line =~ /^\[1]\s+(\w+)$/) {
            $BioCLocusId = $1;
        }
         if ($BioCLocusId eq "NA" or $BioCLocusId eq "na"){
            $BioCNoId++;
         }
        
         $locus{$BioCProbeId} =  $BioCLocusId;
    } # end main if
} # end while

# sort the hash and print to screen
foreach my $probe (sort{lc($a) cmp lc($b)} keys %locus){
        print "$probe\t$locus{$probe}\n";
}

# print stats for BioC hash to screen
print "No of probe sets in file $ARGV[0]: $probeCountBioC\n";
print "No of probe sets with 'NA' as LL id in file $ARGV[0]: $BioCNoId\n\n";

close(IN1);

# read in file with the gc-rma data
# make hash with the probeset id as key
# the rest of data as value, but
# insert the locusid as the first column of data

my %zScores;
    
# count no of probe sets 
my ($probeCountGcrma, $locusNotFound) = (0, 0);

while (my $line = <IN2>) {
    # extract probeset id from line
    # extract rest of line
    if ($line =~ /^(.+?_at)\t(.+)$/) {
        my $gcrmaProbeId = $1;
        my $restOfLine = $2;
        $probeCountGcrma++;

        # get locus id from the hash %locus
        if (exists $locus{$gcrmaProbeId}){
            # insert the locus id into the data
            $zScores{$gcrmaProbeId} = $locus{$gcrmaProbeId} . "\t$restOfLine";
        }
        else{
            # what to do if probe set id not found in the %locus hash 
            # this will be the case for the control probe sets
            $zScores{$gcrmaProbeId} = "NotFound\t$restOfLine";
            $locusNotFound++;
        }
     }
}

# sort the hash by locusid


# sort the hash and print to output
# the sorts aren't quite right
foreach my $probe (sort{$zScores{$a} <=> $zScores{$b} or lc($a) cmp lc($b)} keys %zScores){
        print OUT "$probe\t$zScores{$probe}\n";
}
        
# print stats for gcrma hash to screen
print "No of probe sets in file $ARGV[1]: $probeCountGcrma\n";
print "No of probe sets with 'NotFound' as LL id in output file $ARGV[2]: 
$locusNotFound\n\n";

close(IN2);
close(OUT)
    or die "Unable to close output file $ARGV[2]\n";
            

