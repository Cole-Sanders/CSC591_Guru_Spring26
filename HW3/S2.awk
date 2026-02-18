BEGIN { FS="," }
{ for(i=1; i<=NF; i++) if($i=="?") { missing[i]=1; print "Line " NR ": Contains missing value '?'"; break } }
END { printf "Columns with missing values: "; for(i in missing) printf i " "; print (length(missing) ? "" : "(none)") }