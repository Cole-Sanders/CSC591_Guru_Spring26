BEGIN { FS=", *"; Total=0; correct=0; checked=0;
                         if (wait=="") wait=10
                         if (k=="") k=1
                         if (m=="") m=2
                         NumClasses=0
                       }
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
  Total++; c=$NF;
  if (Classes[c]++ == 0) NumClasses++
  for(i=1; i<NF; i++) {
    if($i=="?") continue
    Freq[c,i,$i]++
    if(++Seen[i,$i]==1) Attr[i]++ }}

function classify(    i,c,t,best,bestc) {
  best=-1e30
  for(c in Classes) {
    # Prior: (Classes[c]+m)/(Total+m*NumClasses)
    t=log((Classes[c]+m)/(Total + m * NumClasses))
    for(i=1; i<NF; i++) {
      if($i=="?") continue
      # Likelihood: (Freq + k) / (Classes[c] + k * Attr[i])
      t+=log((Freq[c,i,$i]+k)/(Classes[c] + k * Attr[i])) }
    if(t>best) { best=t; bestc=c }}
  return bestc }
