BEGIN { FS="," }

    NR == 1 { ncols = NF; for (i=1; i<=NF; i++) hdr[i] = $i }
    R == 2 { for (i=1; i<=NF; i++) first_val[i] = $i }
    NR  > 2 { for (i=1; i<=NF; i++) if ($i != first_val[i]) not_const[i]++ }

END{
     print "\n=== S3: Constant columns ==="
    n = 0
    for (i = 1; i <= ncols; i++)
        if (!(i in not_const)) { print "  Col " i ": " hdr[i] " (value=" first_val[i] ")"; n++ }
    if (n == 0) print "  (none)"
}