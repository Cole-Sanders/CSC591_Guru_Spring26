BEGIN { FS = ", *" }
NR > 1 { counts[$2]++ }
END {
    max_count = 0
    max_val = ""
    for (val in counts) {
        if (counts[val] > max_count) {
            max_count = counts[val]
            max_val = val
        }
    }
    print max_val, max_count
}
