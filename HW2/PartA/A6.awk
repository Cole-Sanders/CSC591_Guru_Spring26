BEGIN { FS = ", *" }
NR > 1 { counts[$NF]++; total++ }
END {
    entropy(counts, total)
}

function entropy(arr, n,   c, p, e) {
    e = 0
    for (c in arr) {
        p = arr[c] / n
        e -= p * log(p)
    }
    print e
}
