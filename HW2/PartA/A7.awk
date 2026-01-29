BEGIN { FS = ", *"; srand() }
NR == 1 { next }
{
    if (count < 20) {
        reservoir[count] = $0
        count++
    } else {
        count++
        k = int(rand() * count)
        if (k < 20) {
            reservoir[k] = $0
        }
    }
}
END {
    for (i = 0; i < 20; i++) {
        if (i in reservoir) print reservoir[i]
    }
}
