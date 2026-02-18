BEGIN { FS="," }
{
    for(i=1; i<=NF; i++) {
        if ($i == "?") {
            missing_cols[i] = 1
            print "Line " NR ": Contains missing value '?'"
            break # Move to next row once one '?' is found
        }
    }
}
END {
    printf "Columns with missing values: "
    for (i in missing_cols) printf i " "
    print ""
}