#!/usr/bin/perl -w

# subroutine ReadBioC
# Maria Stalteri
# 27/06/05

# 27/07/06 regex modified to cope with HG-U133 probe set IDs
# 09/05/06 modified to cope with the Apr/06 release
# which has the probe set id bet. backticks instead of quotes
# 27/6/05 modification to cope with BioC LOCUSID mapping
# ACCNUM output has quotes around the accession nos
# LOCUSID doesn't have quotes
# for a generic solution, change the regex to make the quotes optional

# adapted from ReadAffy.pm
# reads file with one of the BioC mappings
# lists of probe set IDs and corresponding LOCUSID, symbol, ACCNUM mappings, etc.

# returns hash with probeset ID as keys, contents of mapping as values

# call subroutine with name of file to read

package ReadBioC;
use strict;

sub ReadBioC{
         
    # parameters are in @_
    # first parameter is name of file to read
  

    print "Subroutine ReadBioC, parameters:\n";
    foreach my $value (@_) {
         print "$value\n";
    }          
    
    # open filehandle for reading
 
    my $file = $_[0];        

    open(INFILE, "< $file")
       or die "Unable to read file $file\n";

    my %locusLink;
    my ($probesetId, $locusId);
    
    # count no of matches to regex, no of hash keys;
    my $matches = 0;   
    # extract probeset id and required field with regex
    while (my $line =<INFILE>) {
        if ($line =~ /^\$["`](\d+_?[a-z]?_at)["`]$/) {
             $probesetId = $1;
             $line = <INFILE>;
            
             if ($line =~ /^\[1]\s+"?(\w+)"?$/) {
                 $locusId = $1;
                 $matches++;
                 $locusLink{$probesetId} = $locusId;
              }
         }

    }

    close(INFILE);
    my $noOfKeys = keys(%locusLink);
    
    print "Results of reading file $_[0] with program $0:\n";
    print "No. of matches to regex: $matches\n";
    print "No of keys in hash locusLink: $noOfKeys\n\n";
    
    # how do you return a hash from a subroutine? by reference;
    # same as arrays, one hash can be returned
    # more than one is returned by reference or else
    # you get list flattening

    return %locusLink;
}

1;



