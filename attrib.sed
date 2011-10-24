#n
/^<[^!]*[[:blank:]]/{
	s/\([a-zA-Z][a-zA-Z0-9]*="[^"]*"\)[[:blank:]]*/\1\n/g
	s/^\(<[a-zA-Z][a-zA-Z0-9]*\)[[:blank:]]*/\1\n/
}
p
