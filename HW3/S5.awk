BEGIN { FS="," }
NR > 1 { seen[$0]++ }
END { print "\n=== S5: Duplicate rows ==="; for (k in seen) if (seen[k] > 1) { print "  " seen[k] " copies: " k; n += seen[k] }
    if (!n) print "  (none)"; else print "  Total duplicate rows: " n }