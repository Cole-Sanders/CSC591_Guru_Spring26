BEGIN { FS="," }
    NR==1 { expect = NF }
    NF != expect { print "Line " NR " has " NF " fields (expected " expect ")" }
END{
     print "=== S1: Ragged rows ==="
    n = 0
    for (r in ragged) { print "  Row " r ": " ragged[r] " fields (expected " ncols ")"; n++ }
    if (n == 0) print "  (none)"
}

