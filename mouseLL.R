# R program to get mapping between probe set IDs 
# and LocusLink IDs
# 06/07/04
# Maria Stalteri

library(moe430a)
sink ("mouseLL.txt")
xx <- as.list(moe430aLOCUSID)

# I prefer to know how many probe sets map to 'na'
# so I leave out the line that tells the program
# to skip them
# see the BioC package html pages

if(length(xx) > 0){
    xx
+ }
sink()
