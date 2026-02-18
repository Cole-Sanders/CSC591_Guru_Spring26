BEGIN { FS="," }
NR==1 { next } 
NR==2 { for(i=1;i<=NF;i++) { b[i]=$i; c[i]=1 } }
NR>2  { for(i=1;i<=NF;i++) if($i!=b[i]) c[i]=0 }
END   { for(i in c) if(c[i]) print "Column " i " is constant: " b[i] }