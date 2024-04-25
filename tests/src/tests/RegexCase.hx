package tests;

class RegexCase extends TestCase {
	override function setup() {
		super.setup();

		/*headerCode = "
		var r = ~/a/;
		var rg = ~/a/g;
		var rg2 = ~/aa/g;
		";*/
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("assertEq", Util.assertEq);
		interp.variables.set("EReg", EReg);
		return interp;
	}

	override function run() {
		var r = new EReg("a", "");
		var rg = new EReg("a", "g");
		var rg2 = new EReg("aa", "g");

		// TODO: implement better checking for regexes
		//assertEq("new EReg('a', '');", r);
		//assertEq("new EReg('a', 'g');", rg);
		//assertEq("new EReg('aa', 'g');", rg2);

		//@:privateAccess assertEq("new EReg('a', '').toString();", r.toString());
		//@:privateAccess assertEq("new EReg('a', 'g').toString();", rg.toString());
		//@:privateAccess assertEq("new EReg('aa', 'g').toString();", rg2.toString());

		//assertEq(r.match("") == false);
		//assertEq(r.match("b") == false);
		//assertEq(r.match("a") == true);
		//assertEq(r.matched(0) == "a");
		//assertEq(r.matchedLeft() == "");
		//assertEq(r.matchedRight() == "");
		//var pos = r.matchedPos();
		//assertEq(pos.pos == 0);
		//assertEq(pos.len == 1);

		headerCode = "var r = ~/a/;";

		assertEq('[r.match(""), r.match("b"), r.match("a"), r.matched(0), r.matchedLeft(), r.matchedRight(), {var pos = r.matchedPos(); [pos.pos, pos.len];}]', [r.match(""), r.match("b"), r.match("a"), r.matched(0), r.matchedLeft(), r.matchedRight(), {var pos = r.matchedPos(); [pos.pos, pos.len];}]);
		assertEq('[r.match("aa"), r.matched(0), r.match("a"), r.matchedLeft(), r.matchedRight(), {var pos = r.matchedPos(); [pos.pos, pos.len];}]', [r.match("aa"), r.matched(0), r.match("a"), r.matchedLeft(), r.matchedRight(), {var pos = r.matchedPos(); [pos.pos, pos.len];}]);


		headerCode = "var rg = ~/a/g;";

		assertEq('[rg.match("aa"), rg.matched(0), rg.matchedLeft(), rg.matchedRight(), {var pos = rg.matchedPos(); [pos.pos, pos.len];}]', [rg.match("aa"), rg.matched(0), rg.matchedLeft(), rg.matchedRight(), {var pos = rg.matchedPos(); [pos.pos, pos.len];}]);

		headerCode = "var rg2 = ~/aa/g;";

		assertEq('[rg2.match("aa"), rg2.matched(0), rg2.matchedLeft(), rg2.matchedRight(), {var pos = rg2.matchedPos(); [pos.pos, pos.len];}]', [rg2.match("aa"), rg2.matched(0), rg2.matchedLeft(), rg2.matchedRight(), {var pos = rg2.matchedPos(); [pos.pos, pos.len];}]);
		assertEq('[rg2.match("AaaBaaC"), rg2.matched(0), rg2.matchedLeft(), rg2.matchedRight(), {var pos = rg2.matchedPos(); [pos.pos, pos.len];}]', [rg2.match("AaaBaaC"), rg2.matched(0), rg2.matchedLeft(), rg2.matchedRight(), {var pos = rg2.matchedPos(); [pos.pos, pos.len];}]);

		headerCode = "";

		// split
		assertEq('~/a/.split("")', ~/a/.split(""));
		assertEq('~/a/.split("a")', ~/a/.split("a"));
		assertEq('~/a/.split("aa")', ~/a/.split("aa"));
		assertEq('~/a/.split("b")', ~/a/.split("b"));
		assertEq('~/a/.split("ab")', ~/a/.split("ab"));
		assertEq('~/a/.split("ba")', ~/a/.split("ba"));
		assertEq('~/a/.split("aba")', ~/a/.split("aba"));
		assertEq('~/a/.split("bab")', ~/a/.split("bab"));
		assertEq('~/a/.split("baba")', ~/a/.split("baba"));

		// split + g
		assertEq('~/a/g.split("")', ~/a/g.split(""));
		assertEq('~/a/g.split("a")', ~/a/g.split("a"));
		assertEq('~/a/g.split("aa")', ~/a/g.split("aa"));
		assertEq('~/a/g.split("b")', ~/a/g.split("b"));
		assertEq('~/a/g.split("ab")', ~/a/g.split("ab"));
		assertEq('~/a/g.split("ba")', ~/a/g.split("ba"));
		assertEq('~/a/g.split("aba")', ~/a/g.split("aba"));
		assertEq('~/a/g.split("bab")', ~/a/g.split("bab"));
		assertEq('~/a/g.split("baba")', ~/a/g.split("baba"));

		// replace
		assertEq('~/a/.replace("", "z")', ~/a/.replace("", "z"));
		assertEq('~/a/.replace("a", "z")', ~/a/.replace("a", "z"));
		assertEq('~/a/.replace("aa", "z")', ~/a/.replace("aa", "z"));
		assertEq('~/a/.replace("b", "z")', ~/a/.replace("b", "z"));
		assertEq('~/a/.replace("ab", "z")', ~/a/.replace("ab", "z"));
		assertEq('~/a/.replace("ba", "z")', ~/a/.replace("ba", "z"));
		assertEq('~/a/.replace("aba", "z")', ~/a/.replace("aba", "z"));
		assertEq('~/a/.replace("bab", "z")', ~/a/.replace("bab", "z"));
		assertEq('~/a/.replace("baba", "z")', ~/a/.replace("baba", "z"));

		//Util.runKnownBug("Regex Syntax doesn't work", () -> {
		assertCompiles("~/a/;");
		assertCompiles("~/(a)a\\0\\//g;");
		assertCompiles("~/(a)a\\0\\//g+5;");
		assertError("~/(a)a\\0\\//ga;", Parser.getBaseError(ECustom("Invalid regex expression option \"a\"")));
			//assertEq("~/a/+5", null);//~/a/+5);
		//});

		// replace + g
		assertEq('~/a/g.replace("", "z")', ~/a/g.replace("", "z"));
		assertEq('~/a/g.replace("a", "z")', ~/a/g.replace("a", "z"));
		assertEq('~/a/g.replace("aa", "z")', ~/a/g.replace("aa", "z"));
		assertEq('~/a/g.replace("b", "z")', ~/a/g.replace("b", "z"));
		assertEq('~/a/g.replace("ab", "z")', ~/a/g.replace("ab", "z"));
		assertEq('~/a/g.replace("ba", "z")', ~/a/g.replace("ba", "z"));
		assertEq('~/a/g.replace("aba", "z")', ~/a/g.replace("aba", "z"));
		assertEq('~/a/g.replace("bab", "z")', ~/a/g.replace("bab", "z"));
		assertEq('~/a/g.replace("baba", "z")', ~/a/g.replace("baba", "z"));

		// var 0 = 5; // Missing variable identifier
	}

	override function teardown() {
		super.teardown();
	}
}