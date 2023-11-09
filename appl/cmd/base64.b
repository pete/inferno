implement Base64;

include "sys.m"; sys: Sys;
include "draw.m";
include "encoding.m";

Base64: module {
	init: fn(nil: ref Draw->Context, args: list of string);
};

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	base64 := load Encoding Encoding->BASE64PATH;

	enc := 1;

	args = tl args;
	if(args != nil && len args == 1 && hd args == "-d") {
		enc = 0;
	} else if(args != nil) {
		sys->fprint(sys->fildes(2), "usage:  base64 [-d]\n");
		raise "fail:bad args";
	}

	stdin := sys->fildes(0);
	buf := array[Sys->ATOMICIO] of byte;
	fullbuf := array[0] of byte;
	while((n := sys->read(stdin, buf, len buf)) > 0) {
		tmpbuf := array[(len fullbuf) + n] of byte;
		i: int;
		for(i = 0; i < len fullbuf; i++)
			tmpbuf[i] = fullbuf[i];
		for(j := 0; j < n; j++)
			tmpbuf[i+j] = buf[j];
		fullbuf = tmpbuf;
	}

	if(enc) {
		result := base64->enc(fullbuf);
		sys->print("%s", result);
	} else {
		stdout := sys->fildes(1);
		fullbuf = base64->dec(string fullbuf);
		while(len fullbuf > 0) {
			n = sys->write(stdout, fullbuf, len fullbuf);
			if(n == len fullbuf)
				break;
			if(n <= 0) {
				sys->fprint(sys->fildes(2), "base64: %r\n");
				raise "fail:errors";
			}
			fullbuf = fullbuf[n:];	
		}
	}
}
