BEGIN { FS = ", *" }
NR > 1 { 
    # Store counts with Class ($NF) as the primary key
    cross[$NF, $1]++ 
}
END {
    # Use the system 'sort' command to order the output.
    # By default, 'sort' orders by the first column (Class), grouping them.
    cmd = "sort"
    
    for (key in cross) {
        split(key, parts, SUBSEP)
        # Send output to the sort command
        print parts[1], parts[2], cross[key] | cmd
    }
    
    # Close the pipe to ensure the sort command runs and finishes
    close(cmd)
}
