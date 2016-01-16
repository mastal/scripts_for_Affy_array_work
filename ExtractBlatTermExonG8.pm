#!/usr/bin/perl -w
# ExtractBlatTermExonG8.pm
# 22/11/07
# Maria Stalteri

# 24/11/07 modified to take into account cases where there is only 1 alignment block
# or where all existingblocks are merged into one, otherwise end up with
# uniinitialised values in while loop while(gap < 9)

# 22/11/07 modified from ExtractBlatTermExon.pm
# so that it merges gaps of 8 bp or less in the alignments
# when calculating the coordinates for the 5' end of terminal exons 

# 13/06/07 regex modified so that it only matches NM_ sequences

# reads psl output from blat and extracts
# transcript coordinates of terminal exon

# NOTE THIS CODE ASSUMES THE LAST ALIGNMENT BLOCK IS THE 3' TERMINAL EXON
# 22/11/07 modified so that if gap between last alignment block is < 9 bp,
# the block is merged with the previous block, and this is repeated until
# the gap between the merged final blocks and the previous block is > 8 bp

# blat output has 5 -line header, unless 
# you run it with -no header option

package ExtractBlatTermExonG8;
use strict;

sub ExtractBlatTermExonG8{

    # get the subroutine parameters
    print "Subroutine ExtractBlatTermExonG8, parameters:\n";
    foreach my $value (@_) {
         print "$value\n";
    }          

    # open filehandle for reading
    my $file = $_[0];        
    open(INFILE, "< $file")
       or die "Unable to read file $file\n";
    
    # make hash with RefSeq accession.version as keys
    # values - want start and end pos (on the refSeq) of 3' terminal exon
    # taken to be the last alignment block
    # NOTE ASSUMPTION:  that the last alignment block is the 3' terminal exon
    # if there is a 'break' in the alignment won't get the whole of the last exon

    # problem - how to get only 1 alignment for each RefSeq
    # how to discard the minor alignments

    # two ideas for doing this
    # 1. put all the alignments into hash
    # values will be hash of arrays or array of arrays
    # with the secondary hash keys or arrays being the number of matches
    # (problem if there is  more than 1 alignment with same number of matches) 
    # 2. take only the alignment with largest matches value into hash        
    # try method 2 for the time being


    my %threePrime;
    
    # set up all the counters
    # $noOfLines - number of lines in file
    # $noOfAlign - number of alignment lines in file (i.e. not header lines)
    # $noOfHeaders - number of lines that don't match regex for alignment lines
    # $noOfMatchingAlign - number of alignment lines that match the RefSeq
    # $noNotMatchingRegex - number of alignment lines that don't match  my regex        
    my ($noOfLines, $noOfAlign, $noOfHeaders, $noOfMatchingAlign, $noNotMatchingRegex) = (0, 0, 0, 0, 0);
    
    # go through the blat psl output file
    while (my $line = <INFILE>) {
        # count number of lines read
        $noOfLines++;

        # use regex to match the lines with alignments and extract
        # first column, number of matches, 
        # the RefSeq accession version
        # the last qStart
        # the last blockSize

        ###### blat file format, tab delimited ##########
        # there are 21 columns
        # match - the number of matching bases is col 1
        # query name is col 10
        # format is gi|digits|ref|refseq accession.version| - extract accession.version
        # blockSizes is col 19, ends with number followed by comma
        # qStarts is col 20
        
        if ($line =~ /^\d+\t/){
            $noOfAlign++;

            # change regex so that it captures all of the blockSizes and qStarts fields in $3 and $4
            if ($line 
=~/^(\d+)\t(?:[^\t]+\t){8}gi\|\d+\|ref\|(NM_\d+\.\d+)\|\t(?:[^\t]+\t){8}([\d,]+)\t([\d,]+)\t(?:[\d,]+)$/){
                 $noOfMatchingAlign++;
                 # $1 - the number of matching bases in the alignment
                 # $2 - the RefSeq accession.version
                 # $3 is list of  block sizes
                 # $4 is list of start pos of alignment blocks on query sequence (transcript)

                 # process $3 and $4 to get terminal exon, merging blocks with gaps < 9 bp 
                 my @blockSizes = split /,/, $3;
                 my @starts = split /,/,  $4; 

                 # calculate size of last gap - between the nth alignment block and the (n-1)th alignment block
                 # size of gap = qstart(block n) - qend(block n-1)
                 # to get qend(block n-1) = qstart(block n-1) + block size (block n-1)

                 # what happens when there is only one alignment block to begin with,
                 # or only one alignment block remaining after the 'pop' operation? sort this;
            

                 my $endPos = $starts[-1] + $blockSizes[-1];
                 my $startPos = $starts[-1];
                 my ($qEnd, $gap);            
                 if( (scalar(@starts) < 2) or (scalar(@blockSizes) < 2)) {
                     # only 1 align block, so no gaps
                     $qEnd = $endPos;
                     $gap = 0;
                     print "RefSeq ID, nth block end, gap (should be 0): $2, $endPos, $qEnd, $gap\n";

                 } # endif only 1 alignment block

                 else{
                     $qEnd = $starts[-2] + $blockSizes[-2];
                     $gap = $starts[-1] - $qEnd;
                     print "RefSeq ID, nth block end, (n-1)th block end, gap: $2, $endPos, $qEnd, $gap\n";

                     while (($gap > 0) and ($gap < 9)){
                         # check that there is more than 1 alignment block left before proceeding
                         # otherwise stop; exit while loop
                     
                         if( (scalar(@starts) == 2) or (scalar(@blockSizes) == 2)) {
                             # 2 align blocks, so only 1 gap
                             $qEnd = $starts[-2] + $blockSizes[-2];
                             $gap = $starts[-1] - $qEnd;
                             print "RefSeq ID, nth block end, gap: $2, $endPos, $qEnd, $gap\n";
                      
                             # merge blocks if  gap < 9;
                             if ($gap < 9){
                                 $startPos = $starts[-2];
                             } # endif3 
                             else {
                                 $startPos = $starts[-1];
                             } # endelse3
                             print "RefSeq ID, start pos, nth block end, gap: $2, $startPos, $endPos, $qEnd, $gap\n";
                             last;
                          } # endif2 only 2 alignment blocks remain after merging gaps
                          else{
                              # continue with while loop
                              pop @starts;
                              pop @blockSizes;
                              $startPos = $starts[-1];
                              $qEnd = $starts[-2] + $blockSizes[-2];
                              $gap = $starts[-1] - $qEnd;
                              print "next (n-1)th block end, next gap: $qEnd, $gap\n";
                           } # endelse2
                      } #endwhile merge gaps                
                 } # endelse1 only 1 alignment block
                 print "final values for terminal exon start, end, gap: $startPos, $endPos, $gap\n\n";
                
                 # how to calc startPos for merged terminal exon?

                 # hash threePrime;
                 # keys are RefSeq accessions, $2
                 # values are arrays with $1 as [0], $4 as [1], $endPos as [2]
                 # for the moment, take the largest alignment for each RefSeq, ignore rest
                 if (exists($threePrime{$2})) {          

                     if ($1 > $threePrime{$2}->[0]) {
                         $threePrime{$2}->[0] = $1;
                         $threePrime{$2}->[1] = $startPos;
                         $threePrime{$2}->[2] = $endPos;
                     } #endif4
                 } # endif3
                 else{
                     $threePrime{$2}->[0] = $1;
                     $threePrime{$2}->[1] = $startPos;
                     $threePrime{$2}->[2] = $endPos;                
                 } #endelse3
            } # endif2
            else{
                 # alignment line doesn't match the regex
                 $noNotMatchingRegex++;
#                 print "Line doesn't match regex\n$line";

            } # endelse2 
        }   # endif1  
        else{
            # count and print lines that are not alignment lines
            $noOfHeaders++;
            print $line;            

        } # endelse1                  
    } # endwhile

    close(INFILE)
      or die "Unable to close input file $_[0]";

    my $noOfKeys = keys(%threePrime);

    # print stats to screen:
    print "Number of lines: ", $noOfLines, "\n";
    print "Number of header lines throughout file: ", $noOfHeaders, "\n";
    print "Number of alignment lines in file: ", $noOfAlign, "\n";
    print "Number of lines with matches to RefSeq accession and regex: ", $noOfMatchingAlign, "\n";
    print "Number of non-header lines not matching my regex (0 if my code works properly): ", $noNotMatchingRegex, "\n\n";
    print "Number of RefSeqs in hash: $noOfKeys\n";

    return %threePrime;
}

1;













