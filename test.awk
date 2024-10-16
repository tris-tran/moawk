

BEGIN { 
    print "START"
    print FILENAME 
}

/a/ { $0 = "k" }
/k/ { 
    print "a" >> "./test.data" 
}
/c/ { getline < "./test.data" }
/a/ { print }

{ print "Current record: [" $0 "]" }



