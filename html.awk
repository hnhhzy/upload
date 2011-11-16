function in_section(sec_bg, sec_ed) {
	return 0;
}
BEGIN {
	RS = ">";
	FS = "";
	remain = "";

	while (getline) {
		remain = remain $0;
		start = index(remain, "<");
		if (start > 1)
			before = substr(remain, 1, start - 1);
		else
			before = "";
		remain = substr(remain, start + 1);
		#printf("remain: %s\n", remain);

		if (in_section("!--", "--") ||
		    in_section("!", "") ||
		    in_section("?", "?")) {
			printf("in section");
			remain = "";
			continue;
		}

		tag = remain;
		sub("[ \t\n][ \t\n]*.*$", "", tag);
		printf("tag: %s\n", tag);
		
		sub("[^ \t\n][^ \t\n]*[ \t\n]*", "", remain);
		#printf("remain: %s\n", remain);
		if (remain == "")
			continue;

		while (remain != "") {
			if (remain ~ /[A-Za-z][^"]*=[ \t\n]*"/) {
				att = remain;
				sub("[ \t\n]*=.*$", "", att);
				printf("att: %s\n", att);
				remain = substr(remain, index(remain, "\"") + 1);
				#printf("remain: %s\n", remain);
				remain = substr(remain, 2);

				rqd = index(remain, "\"");
				while (rqd == 0) {
					if (getline)
						remain = remain ">" $0;
					else
						exit;
					rqd = index(remain, "\"");
				}
				quo = substr(remain, 1, rqd - 1);
				printf("quote: %s\n", quo);
				sub(/[^"]*"[ \t\n]*/, "", remain);
				#printf("remain: %s\n", remain);
			} else if (remain ~ /[A-Za-z][^"]*=[ \t\n]*'/) {
				########
			}
		}

	}
}

