BEGIN { FS="," }
NR==1 { expect = NF }
NF != expect { print "Line " NR " has " NF " fields (expected " expect ")" }