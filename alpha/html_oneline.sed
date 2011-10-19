#!/bin/sed -nf

/^[[:blank:]]*</{
	/>$/{
		p
		d
	}
	h
	d
}
/>$/{
	H
	s/.*//
	x
	s/\n/$/g
	p
	d
}
x
/^$/{
	x
	p
	d
}
x
H
