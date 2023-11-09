implement APlus;

include "sys.m"; sys: Sys;
include "draw.m";
include "bufio.m"; bufio: Bufio;
	Iobuf: import bufio;
include "env.m"; env: Env;
include "string.m"; str: String;

APlus: module {
	init: fn(nil: ref Draw->Context, args: list of string);
};

pname: string;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	env = load Env Env->PATH;
	str = load String String->PATH;

	indents: string;

	if(args != nil) {
		pname = hd args;
		args = tl args;
	} else {
		pname = "a+";
	}

    indents = env->getenv("indent");
    if(indents == nil || len indents < 1)
    	indents = "\t";
    else if(indents[0] == '\'')
		indents = hd str->unquoted(indents);
	if(args != nil)
		indents = hd args;

	indent(indents);
}

indent(s: string)
{
	stdin := bufio->fopen(sys->fildes(0), bufio->OREAD);
	if(stdin == nil) {
		sys->fprint(sys->fildes(2), "%s: Couldn't create a bufio:  %r\n", pname);
		raise "fail:errors";
	}

	while((line := stdin.gets('\n')) != nil) {
		if(line == "\n") {
			sys->print("\n");
		} else {
			sys->print("%s%s", s, line);
		}
	}
}
