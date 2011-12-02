function get_section(sec_end) {
	
}

BEGIN {
	exitcode = 0x0;
	RS = "<";
	FS = "";
	section_stack = "";
	while (getline) {
		printf("$0 = %s", $0);
		prefix = $0;
		if (RS = "<") {
			get_section(">");
		} else if (RS = "\"") {
			get_section("\"");
		} else if (RS = "'") {
			get_section("'");
		}

	}
	printf("EOF\n");
	exit exitcode;
}
