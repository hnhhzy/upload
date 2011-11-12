#!/usr/bin/awk -f

BEGIN {
	if (ARGC < 2) {
		print("usage: export_to d=DIR [s=STRIP] [FILE]");
		exit 1;
	}
	FS = "/";
}

$0 !~ /^[[:blank:]]*#/ {
	t = d;
	if ($0 !~ /^\//)
		$0 = ENVIRON["PWD"] "/" $0;
	for (i = s + 1; i < NF; ++i)
		t = t "/" $i;
	if (system("mkdir -vp " t) == 0)
		system("cp -vur " $0 " " t "/" $NF);
}
