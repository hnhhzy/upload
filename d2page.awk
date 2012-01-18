BEGIN {
	maxdeep = m;
	deep[1] = 0;
	from[1] = 0;
	pagelist[1] = 1;
	last = 1;

	for (i = 1; deep[pagelist[i]] < maxdeep; ++i) {
		page = pagelist[i];
		pdeep = deep[page];
		#print i, page, pdeep;
		nextpage = page + 1;
		caldeep(page, nextpage, pdeep);
		nextpage = page - 1;
		caldeep(page, nextpage, pdeep);
		nextpage = (int(page / 10) + 1) * 10;
		caldeep(page, nextpage, pdeep);
		nextpage = (int(page / 10) - 1) * 10;
		caldeep(page, nextpage, pdeep);
		nextpage = (int(page / 100) + 1) * 100;
		caldeep(page, nextpage, pdeep);
		nextpage = (int(page / 100) - 1) * 100;
		caldeep(page, nextpage, pdeep);
	}
	for (i = 1; i <= last; ++i) {
		page = pagelist[i];
		printf("%2d: %4d", deep[page], page);
		while (page > 1) {
			printf(" <-%4d", from[page]);
			page = from[page];
		}
		printf("\n");
	}
	printf("M=%d, T=%d\n", maxdeep, last);
}

function caldeep(page, nextpage, pdeep) {
	if (nextpage < 1 || nextpage in deep) {
		return;
	} else {
		pagelist[++last] = nextpage;
		deep[nextpage] = pdeep + 1;
		from[nextpage] = page;
	}
}
