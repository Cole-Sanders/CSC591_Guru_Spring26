BEGIN { FS="," }
{
    NR > 1 { seen[$0]++; if (seen[$0] == 2) dup_key[++ndup] = $0 }
}
END {
     print "\n=== S5: Duplicate rows ==="
    total_dup = 0
    for (k = 1; k <= ndup; k++) {
        key = dup_key[k]
        cnt = seen[key]
        print "  " cnt " copies: " key
        total_dup += cnt
    }
    if (ndup == 0) print "  (none)"
    else print "  Total duplicate rows: " total_dup
}