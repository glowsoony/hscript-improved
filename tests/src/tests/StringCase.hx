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

		//Util.runKnownBug("Using StringTools; not working", () -> {
		//});
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

		assertEq("'${5}'", '${5}');
		assertEq("'${5},${({})}'", '${5},${({})}');
		assertEq("'${5},${\"Hello\"}'", '${5},${"Hello"}');
		assertEq("'${5},${'Hello'}'", '${5},${'Hello'}');
		assertEq("'$${5}'", '$${5}');
		assertEq("'$${({})}'", '$${({})}');

		assertEq('"$${5}"', "${5}");
		assertEq('"$${5},$${({})}"', "${5},${({})}");
		assertEq('"$${5},$${\\"Hello\\"}"', "${5},${\"Hello\"}");
		assertEq('"$${5},$${\'Hello\'}"', "${5},${'Hello'}");

	}

	override function teardown() {
		super.teardown();
	}
}