#!/usr/bin/perl -w

# affyCompare2.pl
# Maria Stalteri 24/06/05

# 24/06/05 modified from affyCompare2TargDesc.pl

# compares one field from the affy annotation files
# for 2 files at a time
# this version uses a subroutine that works for generic columns
# without multiple identifiers, like the Representative
# Public Identifier, column 9

# uses sub ReadAffy from ReadAffy.pm

# sub returns hash with probeset id as keys and the contents of the 
# requested field as values

# call script with 5  parameters, two of which will be passed to 
# the sub each time it is called
# parameters: first file to read, number of field to extract, second  file
# to read, number of field to extract (should be same as for first
# file except when Affy file format has changed),
# file to write output to

# what do you have to do for the file to find the subroutine?
# make package export its subroutines or type the full name!

use strict;
use ReadAffy;

# @_ is parameters passed to sub
# @ARGV is parameters from command line

if (scalar(@ARGV != 5)) {
     die "Usage $0: first file to read, number of field to extract,
          second file to read, number of field to extract, output file\n";
}


my $file1 = $ARGV[0];
my $field1 = $ARGV[1];

my $file2 = $ARGV[2];
my $field2 = $ARGV[3];

my $output = $ARGV[4];

# test that it works right
print "Program $0\n"; 
print "First file to read: $file1\n";
print  "Number of field to extract: $field1\n";

print "Second file to read: $file2\n";
print  "Number of field to extract: $field2\n";

print "File to write to: $output\n";

my %affy1 = &ReadAffy::ReadAffy($file1, $field1);
my %affy2 = &ReadAffy::ReadAffy($file2, $field2);

# now do something with the hashes
# build a hash of arrays
# keys are probe set ids, values are anonymous arrays
# first element of array is field extracted from file1
# second element of array is field extracted from file2   
# compare element 1 and element 2 and count differences

my %genbank;
foreach my $probeset (sort keys %affy1) {
      $genbank{$probeset} ->[0] = $affy1{$probeset};
}

foreach my $id (sort keys %affy2) {
      $genbank{$id} ->[1] = $affy2{$id}; 
}
 
my $noOfProbesets1 = keys(%affy1);
my $noOfProbesets2 = keys(%affy2);
my $noOfProbesets3 = keys(%genbank);

# print output to file $output
# check that output file doesn't already exist

if (-e $output) {
      die "Output file $output already exists\n";
}

open(OUT, ">$output")
   or die "Unable to open output file $output\n"; 

my $todaysDate = `date`;

print OUT "Date: $todaysDate\n";
print OUT "Output from program: $0\n\n";

print OUT "Results from field number $field1 of file $file1\n";
print OUT "AND from field number $field2 of file $file2:\n\n";

print OUT "COMPARISON OF REPRESENTATIVE PUBLIC ID\n\n";


print OUT "Number of probesets from file 1: $noOfProbesets1\n";
print OUT "Number of probesets from file 2: $noOfProbesets2\n";
print OUT "Number of keys in hash with both sets of records: $noOfProbesets3\n\n";

print OUT "SEE END OF OUTPUT FOR MORE RESULTS\n\n";

print OUT "PROBE SET ID\tACCNUM1\tACCNUM2\tDIFFERENCE\n\n";

# do comparisons and print results

my $differences = 0;
foreach my $identifier (sort keys %genbank) {
     print OUT "$identifier\t";
     print OUT "$genbank{$identifier}->[0]\t$genbank{$identifier}->[1]\t";
     if ($genbank{$identifier}->[0] ne $genbank{$identifier}->[1]) {
          print OUT "*";
          $differences++;
     }
     print OUT "\n";
}



print OUT "Number of differences between the two files: $differences\n";

close(OUT)
  or die "Unable to close output file $output\n";
