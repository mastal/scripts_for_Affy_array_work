#!/usr/bin/perl -w
# ParseBlastD3.pm
# 16/02/07
# Maria Stalteri

# 28/05/07 added code to specifically exclude control probe sets
# 27/05/07 regex changed to match probeset IDs for older generation chips
# 20/03/07 regex changed to match RefSeq accession version with 2 digits

# subroutine reads D3 format output from blast/megablast
# searches of Affy probe sequences against RefSeq mRNA sequences;

# returns hash of 2D arrays with probe set ID as key,
# array of arrays as value
# first array is list of RefSeq ids

# parameters - the name of the file to read,
# the name of the Affy chip in capital letters

package ParseBlastD3;
use strict;

sub ParseBlastD3{
         
    # parameters are in @_
    # first parameter is name of file to read
    # second parameter is name of Affy array in capitals

    print "Subroutine ParseBlastD3, parameters:\n";
    foreach my $value (@_) {
         print "$value\n";
    }          

    # open filehandle for reading
    my $file = $_[0];        
    open(INFILE, "< $file")
       or die "Unable to read file $file\n";
    
    my $chip = $_[1];

    my %probes;
    my $noOfHeaders = 0;
    my $noOfLines = 0;
    my $noOfControls = 0;
    my $noOfMatches = 0;
    my $noOfMatchesExclControlProbes = 0;

    while (my $line = <INFILE> ) {
       $noOfLines++;
       
       # count number of header lines present
       if ($line =~ /^#/) {
           $noOfHeaders++;
       }
             
       if ($line =~ /^probe:/){
           $noOfMatches++;

         # exclude control probesets
         if ($line !~ /^probe:$chip:AFFX/){
           # continue    
           
           # the following values apply to the regex below for non-control probesets;
           # $1 is probe set ID plus probe x,y
           # $2 is Affy probe set ID
           # $3 is probe x,y on chip
           # $4 is refSeq ID
           # $5 is %identity
           # $6 is length
           
           # change regular expression to match older generation chips
           # will not match control probesets ending in _st
           # rat 230A array matches an NM_ RefSeq with accession version 15!
           # rat U34 array probeset IDs include the symbols # and -                                            
           if ($line =~ 
/^probe:$chip:(((?:rc_)?[A-Z\d]{1,2}\d+[\w#\-]+_?[asxfgir]?_at):(\d{1,3}:\d{1,3}));\t([NX][MR]_\d+\.?\d?\d?)\t(\d{1,3}\.\d{2})\t(\d{1,2})\t/) {
               $noOfMatchesExclControlProbes++;
               # before adding to hash, check that it's a perfect match
               my $align = $5;
               my $len = $6;

               if (100.00 == $align and 25 == $len) {
                   push @{$probes{$2}{$4}}, $3;
               } # endif4

               else {
                  print "Not a perfect alignment, $1 and $4\n";
                  } # end else4
           } # endif3
           else {
               # line doesn't match probeset ID or Refseq ID
               print "No match for line:\n";
               print "$line\n\n";
          
           } # end else3                       
         }  # endif2
         else {
             # probeset ID starts with AFFX
             $noOfControls++;
         } # end else2
        
        } # endif1     
        else {
             # line is a header or blank line, not a blast match to a probe
             print "No match for line:\n";
             print "$line\n\n";
        }# end else1

    } # end while

    close(INFILE)
      or die "Unable to close input file $_[0]";

    my $noOfProbesets = keys(%probes);        

    print "Number of lines: ", $noOfLines, "\n";
    print "Number of header lines throughout file: ", $noOfHeaders, "\n";
    print "Number of lines with matches to RefSeq: ", $noOfMatches, "\n";
    print "Number of lines with matches to RefSeq excluding control probe sets: ", $noOfMatchesExclControlProbes, "\n";
    print "Number of lines for control probesets starting with AFFX: $noOfControls\n";
    print "Number of non-control probesets matching RefSeqs:", $noOfProbesets, "\n";



  return %probes;
}
1;


