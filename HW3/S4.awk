BEGIN { FS="," }

    NR > 1 && $13 !~ /^[1-5]$/ { bad_class[NR] = $13 }

END {
     print "\n=== S4: Bad class labels ==="
    n = 0
    for (r in bad_class) { print "  Row " r ": class!=" bad_class[r]; n++ }
    if (n == 0) print "  (none)"
}