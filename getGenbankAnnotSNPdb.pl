use Bio::SeqIO;
use strict;

# getGenbankAnnotSNPdb.pl
# 21/08/2008
# Maria Stalteri

# 21/08/08 modified from getGenbankAnnotSNP.pl -
# separate start and end coordinates into separate columns;
# also, print one allelic variation per line
# need a way to represent NULLs, i.e. a deletion/insertion situation,
# where one allele returns "";

# 25/07/08 modified to only print list of SNP annotations ('variation')
# modified from getGenbankAnnot.pl
# print statements designed to check that the program works have been commented out

# count number of records in refseq rna file
my $records = 0;

# set up hash with snp data
# variation may pick up other types of polymorphisms, try it and see
my %snps;

my $in = Bio::SeqIO->new('-file'=>$ARGV[0], '-format'=>'genbank');
while (my $seq= $in->next_seq()) {
     $records++;
     
     # get RefSeq accession
     # Notes:
     # the functions display->id and accession->number give the RefSeq accession number, but no version
     # try the primary_id() function; 
     # Notes:
     #  returns the gi number

     #  my $id = $seq->display_id();
     my $accession = $seq->accession_number();
     # my $gi = $seq->primary_id();

     #  print "---------------------------------------------------------------\n";
     # print "record IDs, ID: $id, accession: $accession, primary id: $gi\n";      
     # print "record ID: accession: $accession\n";

     my @topLevelFeatures = $seq->top_SeqFeatures();
     my $noOfFeatures = scalar(@topLevelFeatures);
     # print "the number of top level features in this record is: $noOfFeatures\n\n"; 

     foreach my $feature (@topLevelFeatures){
         # get transcript coordinates for the feature
         # Notes:
         # for single base features, such as SNPs, where the record gives
         # just one coordinate rather than a range as start..end,
         # the $feature->end function returns the same value as $feature->start       

         my $start = $feature->start;
         my $end = $feature->end;
         my $coords = join ":", $start, $end; 
        
         # problem: how do you get the name of the feature?
         # what is the primary tag and the source tag?
         # Notes: 
         # the primary tag seems to give the name of the feature, e.g. exon
         # the source tag seems to be Embl/GenBank/SwissProt for every feature, 
         # although that isn't written anywhere in the record or the features table
         # perhaps because these are refseq records; primary gb records might have different source tags         

         # Notes:
         # the name of features reporting SNP positions is 'variation'

         my $primary = $feature->primary_tag;
         # my $feat_src = $feature->source_tag;
          
         my @tags = $feature->all_tags;
         my $noOfTags = scalar(@tags);
         
         # note $feature is an object, that is why it prints a hash code 
         #  print "the transcript coordinates of the feature are $start to $end.\n";
         # print "the number of tags in feature $primary is: $noOfTags\n";         
         # print "the primary tag is: $primary\n";
         # print "the source tag is: $feat_src\n\n";       
      
         # add snps to snp file
         if ($primary eq 'variation'){
            
            my $dbase = ""; 
            if ($feature->has_tag('db_xref')){
                  # check if any entries have more than 1 dbxref and flag
                  my @dbValues = $feature->each_tag_value('db_xref');
                  if (1 < scalar(@dbValues)){
                       print "record $accession, snp at $coords has more than 1 db_xref\n\n";
                  }   
                  foreach my $dbID (@dbValues){
                      my $new_dbID = "$dbID"."; ";
                      $dbase .= $new_dbID;
                  }# end foreach get all the values for db
             }#endif snp has a dbxref tag

             if ($feature->has_tag('replace')){
                  my @snpValues = $feature->each_tag_value('replace');
                  foreach my $allele (@snpValues){
                      push @{$snps{$accession}{$coords}{$dbase}}, $allele;
                  }# end foreach get all the values for snp alleles
             }#endif snp has a replace tag
         }# endif feature is a snp    

         foreach my $tag (@tags){
             # print "the tag is: $tag\n";
             my @values = $feature->each_tag_value($tag);
             # print "the values associated with tag $tag are:\n";
             foreach my $item (@values){
                 # print "$item;\n";
             }# end foreach values
            #  print "\n\n";
         }# end foreach tags
     }#end foreach top level features  
}# end while
# print "\nThe number of records in the genbank file was: $records\n";       

foreach my $transcript (sort keys %snps){
    foreach my $coordinates (sort keys %{$snps{$transcript}}){
        my ($var_start, $var_end) = split /:/, $coordinates;
        foreach my $identifier (sort keys %{$snps{$transcript}{$coordinates}}){
#           print "$transcript\t$coordinates\t$identifier\t";
            foreach my $variant (@{$snps{$transcript}{$coordinates}{$identifier}}){
#                print "$transcript\t$var_start\t$var_end\t$identifier\t$variant\n";
            }
#           print "\n";
        }
    }
}
