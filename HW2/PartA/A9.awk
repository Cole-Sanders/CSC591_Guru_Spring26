BEGIN { FS=", *"; Total=0; correct=0; checked=0; if (wait=="") wait=10 }
NR==1 { next }
NR <= wait + 1 { train(); next }
{
    c=classify()
    if (c == $NF) correct++
    checked++
    # print $NF","c
    train()
}
END {
    if (checked > 0)
        print "Accuracy: " (correct/checked)*100 "%"
}

function train(    i,c) {
  Total++; c=$NF; Classes[c]++
  for(i=1; i<NF; i++) {
    if($i=="?") continue
    Freq[c,i,$i]++
    if(++Seen[i,$i]==1) Attr[i]++ }}

function classify(    i,c,t,best,bestc) {
  best=-1e30
  for(c in Classes) {
    t=log(Classes[c]/Total)
    for(i=1; i<NF; i++) {
      if($i=="?") continue
      t+=log((Freq[c,i,$i]+1)/(Classes[c]+Attr[i])) }
    if(t>best) { best=t; bestc=c }}
  return bestc }


# A9: No the accuracy does not significantly change with Wait=20 or Wait=50. At wait = 20 the accuracy decreased by .1%. 
# At wait = 50 the accuracy increased by .8%.