implement CgiEsc;

include "sys.m"; sys: Sys;
include "draw.m";
include "string.m"; str: String;

CgiEsc: module {
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	str = load String String->PATH;
	buf := array[Sys->ATOMICIO] of byte;
	stdin := sys->fildes(0);
	trans := ucvt;

	if(args != nil)
		args = tl args;

	if(args != nil && hd args == "-d") {
		args = tl args;
		trans = tvcu;
	}

	if(args != nil) {
		sys->fprint(sys->fildes(2), "usage: cgiesc [-d]\n");
		raise "fail:usage";
	}

	while((n := sys->read(stdin, buf, len buf)) > 0) {
		o := trans(string buf[0:n]);
		if(sys->print("%s", o) < len o) {
			sys->fprint(sys->fildes(2), "cgiesc: error writing stdout: %r\n");
		}
	}

	if(n < 0) {
		sys->fprint(sys->fildes(2), "cgiesc: error reading stdin: %r\n");
		raise "fail:read error";
	}
}

# The rest of this file (until tvcu) is almost from
# /appl/charon/charon.b:1287,1313
# Actually, we should probably use /appl/lib/w3c/uris.b:/^enc\(/
# See w3c-uris(2).

hexdigit := "0123456789ABCDEF";
urlchars := array [128] of {
	'a' to 'z' => byte 1,
	'A' to 'Z' => byte 1,
	'0' to '9' => byte 1,
	' ' or '_' or '-' or '.' => byte 1,
	# Charon uses:
	# '-' or '/' or '$' or '_' or '@' or '.' or '!' or '*' or '\'' or '(' or ')' => byte 1,
	* => byte 0
};

ucvt(s: string): string
{
	b := array of byte s;
	u := "";
	for(i := 0; i < len b; i++) {
		c := int b[i];
		if(c == ' ')
			u[len u] = '+';
		else if (c < len urlchars && int urlchars[c])
			u[len u] = c;
		else {
			u[len u] = '%';
			u[len u] = hexdigit[(c>>4)&15];
			u[len u] = hexdigit[c&15];
		}
	}
	return u;
}

tvcu(s: string): string
{
	# The bug here is that we don't handle I/O boundaries.
	for(i := 0; i < len s; i++) {
		if(s[i] == '&') {
			s[i] = '\n';
		} else if(s[i] == '+') {
			s[i] = ' ';
		} else if(s[i] == '%' && i + 2 < len s) {
			(c, nil) := str->toint(s[i+1:i+3], 16);
			s[i] = c;
			s = s[:i+1] + s[i+3:];
		}
	}
	return s;
}
