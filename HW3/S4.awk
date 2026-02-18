BEGIN { FS="," }
NR > 1 && $NF !~ /^[1-5]$/ { bad[NR] = $NF; n++ }
END {
    for (r in bad) print "  Row " r ": class!=" bad[r]
}