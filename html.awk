function in_section(sec_bg, sec_ed) {
	if (remain !~ "^" sec_bg) return 0;
	while (remain !~ sec_ed "$") {
		if (getline)
			remain = remain ">" $0;
	}
	printf("in section\n");
	printf("<%s>\n", remain);
	return 1;
}

BEGIN {
	RS = ">";
	FS = "";
	ptag = "";

	while (getline) {
		remain = $0;
		lab = index(remain, "<");
		if (lab > 1)
			before = substr(remain, 1, lab - 1);
		else
			before = "";
		remain = substr(remain, lab + 1);
		#printf("remain: %s\n", remain);

		if (in_section("!--", "--") ||
		    in_section("!", "") ||
		    in_section("?", "?"))
			continue;

		tag = remain;
		sub("[ \t\n][ \t\n]*.*$", "", tag);
		if (substr(tag, 1, 1) == "/") {
			tag = substr(tag, 2);
			sli = index(ptag, "/");
			while (sli > 1 && substr(ptag, 1, sli - 1) != tag) {
				ptag = substr(ptag, sli + 1);
				sli = index(ptag, "/");
			}
			if (sli > 1) {
				if (before !~ "^[ \t\n]*$")
					printf("%s\n", before);
				printf("TAG_ED: %s\n", ptag);
				ptag = substr(ptag, sli + 1);
			} else {
				printf("no match\n");
				exit;
			}
		} else {
			ptag = tag "/" ptag;
			printf("TAG_BG: %s\n", ptag);
		}
		
		sub("[^ \t\n][^ \t\n]*[ \t\n]*", "", remain);
		#printf("remain: %s\n", remain);
		if (remain == "")
			continue;

		while (remain != "") {
			if (remain ~ /[A-Za-z][^"]*=[ \t\n]*"/) {
				att = remain;
				sub("[ \t\n]*=.*$", "", att);
				#printf("att: %s\n", att);
				remain = substr(remain, index(remain, "\"") + 1);
				#printf("remain: %s\n", remain);

				rqd = index(remain, "\"");
				while (rqd == 0) {
					if (getline)
						remain = remain ">" $0;
					else
						exit;
					rqd = index(remain, "\"");
				}
				quo = substr(remain, 1, rqd - 1);
				printf("  TAG_AT: %s='%s'\n", att, quo);
				sub(/[^"]*"[ \t\n]*/, "", remain);
				#printf("remain: %s\n", remain);
			} else if (remain ~ /[A-Za-z][^']*=[ \t\n]*'/) {
				att = remain;
				sub("[ \t\n]*=.*$", "", att);
				#printf("att: %s\n", att);
				remain = substr(remain, index(remain, "'") + 1);
				#printf("remain: %s\n", remain);

				rqd = index(remain, "'");
				while (rqd == 0) {
					if (getline)
						remain = remain ">" $0;
					else
						exit;
					rqd = index(remain, "'");
				}
				quo = substr(remain, 1, rqd - 1);
				printf("  TAG_AT: %s='%s'\n", att, quo);
				sub(/[^']*'[ \t\n]*/, "", remain);
				#printf("remain: %s\n", remain);
			} else {
				remain = "";
				#printf("why\n");
			}
		}
	}
}

