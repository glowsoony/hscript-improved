package tests;

class StringCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("Std", Std);
		interp.variables.set("String", String);
		return interp;
	}

	override function run() {
		assertEq('"foo"', "foo");
		var str = "foo";
		assertEq('var str = "foo"; str == new String(str)', str == new String(str));

		assertEq('"foo".toUpperCase()', "foo".toUpperCase());
		assertEq('"_bar".toUpperCase()', "_bar".toUpperCase());
		assertEq('"123b".toUpperCase()', "123b".toUpperCase());
		assertEq('"".toUpperCase()', "".toUpperCase());
		assertEq('"A".toUpperCase()', "A".toUpperCase());
		assertEq('"FOO".toLowerCase()', "FOO".toLowerCase());
		assertEq('"_BAR".toLowerCase()', "_BAR".toLowerCase());
		assertEq('"_BAR".toLowerCase()', "_BAR".toLowerCase());
		assertEq('"123B".toLowerCase()', "123B".toLowerCase());
		assertEq('"".toLowerCase()', "".toLowerCase());
		assertEq('"a".toLowerCase()', "a".toLowerCase());

		headerCode = 'var s = "foo1bar";';
		var s = "foo1bar";

		assertEq("s.charAt(0)", s.charAt(0));
		assertEq("s.charAt(1)", s.charAt(1));
		assertEq("s.charAt(2)", s.charAt(2));
		assertEq("s.charAt(3)", s.charAt(3));
		assertEq("s.charAt(4)", s.charAt(4));
		assertEq("s.charAt(5)", s.charAt(5));
		assertEq("s.charAt(6)", s.charAt(6));
		assertEq("s.charAt(7)", s.charAt(7));
		assertEq("s.charAt(-1)", s.charAt(-1));
		assertEq('"".charAt(0)', "".charAt(0));
		assertEq('"".charAt(1)', "".charAt(1));
		assertEq('"".charAt(-1)', "".charAt(-1));

		headerCode = 'var s = "foo1bar";';
		var s = "foo1bar";

		assertEq("s.charCodeAt(0)", s.charCodeAt(0));
		assertEq("s.charCodeAt(1)", s.charCodeAt(1));
		assertEq("s.charCodeAt(2)", s.charCodeAt(2));
		assertEq("s.charCodeAt(3)", s.charCodeAt(3));
		assertEq("s.charCodeAt(4)", s.charCodeAt(4));
		assertEq("s.charCodeAt(5)", s.charCodeAt(5));
		assertEq("s.charCodeAt(6)", s.charCodeAt(6));
		assertEq("s.charCodeAt(7)", s.charCodeAt(7));
		assertEq("s.charCodeAt(-1)", s.charCodeAt(-1));

		headerCode = '';

		Util.runKnownBug("string.code doesnt work", () -> {
			assertEq('"f".code', "f".code);
			assertEq('"o".code', "o".code);
			assertEq('"1".code', "1".code);
			assertEq('"b".code', "b".code);
			assertEq('"a".code', "a".code);
			assertEq('"r".code', "r".code);
			assertEq('"foo".code', null); // multiple chars causes error
			assertEq('"bar".code', null); // multiple chars causes error
		});

		Util.runKnownBug("String.fromCharCode doesnt work", () -> {
			assertEq('String.fromCharCode(65)', String.fromCharCode(65));
			assertEq('String.fromCharCode(97)', String.fromCharCode(97));
			assertEq('String.fromCharCode(98)', String.fromCharCode(98));
			assertEq('String.fromCharCode(99)', String.fromCharCode(99));
			assertEq('String.fromCharCode(100)', String.fromCharCode(100));
			assertEq('String.fromCharCode(101)', String.fromCharCode(101));
			assertEq('String.fromCharCode(102)', String.fromCharCode(102));
			assertEq('String.fromCharCode(103)', String.fromCharCode(103));
		});

		headerCode = '';

		assertEq('("3" > "11")', ("3" > "11"));
		assertEq('(" 3" < "3")', (" 3" < "3"));
		assertEq('("a" < "b")', ("a" < "b"));
		assertEq('("a" <= "b")', ("a" <= "b"));
		assertEq('("a" > "b")', ("a" > "b"));
		assertEq('("a" >= "b")', ("a" >= "b"));

		assertEq('"foo".toUpperCase()', "foo".toUpperCase());
		assertEq('"_bar".toUpperCase()', "_bar".toUpperCase());
		assertEq('"123b".toUpperCase()', "123b".toUpperCase());
		assertEq('"".toUpperCase()', "".toUpperCase());
		assertEq('"A".toUpperCase()', "A".toUpperCase());
		assertEq('"FOO".toLowerCase()', "FOO".toLowerCase());
		assertEq('"_BAR".toLowerCase()', "_BAR".toLowerCase());
		assertEq('"_BAR".toLowerCase()', "_BAR".toLowerCase());
		assertEq('"123B".toLowerCase()', "123B".toLowerCase());
		assertEq('"".toLowerCase()', "".toLowerCase());
		assertEq('"a".toLowerCase()', "a".toLowerCase());

		assertEqPrintable("' \\t\\n\\x0b\\x0c\\r16'", " \t\n\x0b\x0c\r16");
		assertEqPrintable("' \\t\\n\\x0b\\x0c\\r0xa'", " \t\n\x0b\x0c\r0xa");
		assertEqPrintable("' \\t\\n\\x0b\\x0c\\r1.6'", ' \t\n\x0b\x0c\r1.6');

		assertEqPrintable("'The \\x54\\141b\\tch\\141r\\141ct\\145r:\\n'", 'The \x54\141b\tch\141r\141ct\145r:\n');
		assertEqPrintable("'\\t\\\"\\101scii\\\"\\n'", '\t\"\101scii\"\n');
		assertEqPrintable("'\\tcontains\\n'", '\tcontains\n');
		assertEqPrintable("'\\tspecial\\\\backslash\\\\codes,\\n'", '\tspecial\\backslash\\codes,\n');
		assertEqPrintable("'\\tdouble quotes \\\"like this\\\",\\n'", '\tdouble quotes \"like this\",\n');
		assertEqPrintable("'\\tsingle quotes \\'and this\\',\\n'", '\tsingle quotes \'and this\',\n');
		assertEqPrintable("'\\tASCII bell\\x07and others.\\n'", '\tASCII bell\x07and others.\n');
		assertEqPrintable("'Unicode samples: Greek \\u03B1 (alpha), smiley \\u263A,\\n'", 'Unicode samples: Greek \u03B1 (alpha), smiley \u263A,\n');
		assertEqPrintable("'regional indicators \\u{1F1FA}\\u{1F1F8}, and musical note \\u{1F3B5}.'", 'regional indicators \u{1F1FA}\u{1F1F8}, and musical note \u{1F3B5}.');
		assertEqPrintable("'\\u{10FFFF}\\u{1F1FA}\\u{3042}\\u{3B1}\\u{F1}\\u{A}'", '\u{10FFFF}\u{1F1FA}\u{3042}\u{3B1}\u{F1}\u{A}');

		//trace(hscript.Printer.getEscapedString("\u{10FFFF}\u{1F1FA}\u{3042}\u{3B1}\u{F1}\u{A}"));

		assertEq('"\\""', "\"");
		assertEq("'\\''", '\'');
		assertEq("'\\\\'", '\\');
		assertEq("'\\n'", '\n');
		assertEq("'\\r'", '\r');
		assertEq("'\\t'", '\t');
		assertEq("'\\101'", '\101');
		assertEq("'/'", '/');

		assertEq('"$${5}"', "${5}");
		assertEq('"$${5},$${({})}"', "${5},${({})}");
		assertEq('"$${5},$${\\"Hello\\"}"', "${5},${\"Hello\"}");
		assertEq('"$${5},$${\'Hello\'}"', "${5},${'Hello'}");
		assertEq("'$${({})}'", '$${({})}');

		assertEq("'${5},${({})}'", '${5},${({})}');
		assertEq("'${5},${\"Hello\"}'", '${5},${"Hello"}');
		assertEq("'${5},${'Hello'}'", '${5},${'Hello'}');
		assertEq("'$${5}'", '$${5}');
		assertEq("'${5}'", '${5}');
		assertEq("'${'${6}world'}'", '${'${6}world'}');
		var a = 5;
		headerCode = 'var a = 5;';
		assertEq("'$a'", '$a');
		assertEq("'$$a'", '$$a');
		assertEq("'$ '", '$ ');
		assertEq("'$0'", '$0');
		assertEq("'$a+5 Hello ${a+5}'", '$a+5 Hello ${a+5}');
		//assertEq("'$a+5 Hello ${a+5}'", "" + a + "+5 Hello " + a + 5);
		headerCode = '';

		assertEq("'hello ${5} world'", 'hello ${5} world');
		assertEq("'hello ${5}'", 'hello ${5}');
	}

	override function teardown() {
		super.teardown();
	}
}