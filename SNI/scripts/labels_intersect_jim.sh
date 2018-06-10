#! /bin/tcsh -f

# set echo=1

set f1=$1
set f2=$2
set f3=$3

if (( $f1 == "" ) || ( $f2 == "" ) || ( $f3 == "") ) then
  echo "usage:   $0 <label1> <label2> <outputname>"
  echo "example: $0 rh.BA3a.label rh.BA3b.label rh.BA3ab.intersect.label"
  exit 1
endif

# save-away header 
grep "^#" $f1 > $$.tmp.f1.header
grep "^#" $f2 > $$.tmp.f2.header

# save-away no-header
grep -v "`cat $$.tmp.f1.header`" $f1 > $$.tmp.f1.noheader
grep -v "`cat $$.tmp.f2.header`" $f2 > $$.tmp.f2.noheader

# save-away line counts
head -n 1 $$.tmp.f1.noheader > $$.tmp.f1.vertexcount
head -n 1 $$.tmp.f2.noheader > $$.tmp.f2.vertexcount

if ("`cat $$.tmp.f1.vertexcount`" <= "`cat $$.tmp.f2.vertexcount`") then
  set small=f1
  set big=f2
else
  set big=f1
  set small=f2
endif

# strip header and vertex count lines from label files
cat $$.tmp.$big.noheader | tail -`cat $$.tmp.$big.vertexcount` > $$.tmp.$big.stripped
cat $$.tmp.$small.noheader | tail -`cat $$.tmp.$small.vertexcount` > $$.tmp.$small.stripped

# sort
sort -n $$.tmp.$big.stripped > $$.tmp.$big.sorted
sort -n $$.tmp.$small.stripped > $$.tmp.$small.sorted

# get vertices
cat $$.tmp.$small.sorted | awk '{print $1}' > $$.tmp.$small.vertices

# find intersect
rm -f $$.tmp.f3 >& /dev/null

foreach vno (`cat $$.tmp.$small.vertices`)
  echo -n ${vno}... 
  grep --word-regexp "^${vno}" $$.tmp.$big.sorted > $$.tmp.grep
  cat $$.tmp.grep >> $$.tmp.f3
end

# append header and vertex count
cat $$.tmp.$small.header > $f3
set vertexcount=`wc -l $$.tmp.f3 | awk '{print $1}'`
echo $vertexcount >> $f3
cat $$.tmp.f3 >> $f3

# delete junk files
rm -f $$.tmp.*
echo finished.


