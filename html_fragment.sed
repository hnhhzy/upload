#n
/^<!--/{
	/-->/{
		s/-->/-->\n/1
		P
		D
	}
	b next
}
/^</{
	/>/{
		s/>/>\n/1
		P
		D
	}
	b next
}
/</{
	s//\n</1
	P
	D
}
:next
N
s/\n//1
s/^/\n/
D