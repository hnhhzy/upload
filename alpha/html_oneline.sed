#!/bin/sed -nrf

/<.+>/{
	p
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
/^[[:blank:]]*</{
	h
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
