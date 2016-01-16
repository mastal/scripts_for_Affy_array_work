#!/usr/bin/perl -w

# ReadAffy.pm
# subroutine ReadAffy
# Maria Stalteri
# 23/06/05


# reads Affymetrix csv annotation file
# extracts probe set ID and one other field
# returns hash with probeset ID as keys, contents of other field as values

# call subroutine with name of file to read, and number of the
# field to extract (LocusLink is usually 19th field in Affy csv annotation files)
# 18th field in Oct04 release;

package ReadAffy;
use strict;

sub ReadAffy{
         
    # parameters are in @_
    # first parameter is name of file to read
    # second parameter is number of field to read

    print "Subroutine ReadAffy, parameters:\n";
    foreach my $value (@_) {
         print "$value\n";
    }          
    
    # open filehandle for reading
    # gives uninitialized value error message
    # wrong name used for command line par in calling program!
    my $file = $_[0];        

    open(INFILE, "< $file")
       or die "Unable to read file $file\n";

    # change code; extract only the field I want
    # to capture the 19th field,
    # match probe set id, followed by 17 fields, followed by the 19th
    my $field = $_[1] - 2;
    my %locusLink;
    my ($probesetId, $locusId);
    
    # count no of matches to regex, no of hash keys;
    my $matches = 0;   
    # extract probeset id and required field with regex
    while (my $line =<INFILE>) {
         # 22/07/05 removed /o modifier from regex
         # CAUSES PROBLEMS IF YOU CALL SUB TWICE FROM SAME
         # PROGRAM WANTING A DIFF VALUE FOR $field
         # /o means compile once only during execution!!!
         # not during the loop

         if($line =~ /^"(\d+\w*?_at)",(?:"[^"]+",){$field}"([^"]+)"/) {
               $probesetId = $1;
               $locusId = $2;
               $matches++;
               $locusLink{$probesetId} = $locusId;
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



