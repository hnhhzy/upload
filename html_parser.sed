#n
/^[ \t]*<!--/{
	s//@HTML_LC/1
:nc
	/-->/!{
		N
		s/\n/@HTML_CR/1
		b nc
	}
	s/-->/@HTML_RC/1
	s/\(@HTML_RC\)\(.\)/\1@HTML_SEP\n\2/1
	P
	D
}
/^[ \t]*<?/{
	s//@HTML_LQM/1
:nqm
	/?>/!{
		N
		s/\n/@HTML_CR/1
		b nqm
	}
	s/?>/@HTML_RQM/1
	s/\(@HTML_RQM\)\(.\)/\1@HTML_SEP\n\2/1
	P
	D
}
/^[ \t]*</{
	s//@HTML_LAB/1
	/^@HTML_LAB\//{
		s/>/@HTML_RAB/1
		s/\(@HTML_RAB\)\(.\)/\1@HTML_SEP\n\2/1
		P
		D
	}
	/^@HTML_LAB[A-Za-z][A-Za-z0-9]*[ \t][ \t]*/{
		s/[ \t][ \t]*/@HTML_ATT/1
:nes
		/^[^=]*=[ \t]*['"]/!{
			N
			s/\n/@HTML_CR/1
			b nes
		}
		/^[^=]*=[ \t]*"/{
			s/"/@HTML_LQ/1
		##########
}
