package tests;

class StdCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("Std", Std);
		interp.variables.set("String", String);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Int", Int);
		return interp;
	}

	override function run() {
        var known:String = null; assertEq('var known:String = null; known is String;', known is String);
        var unknown = null; assertEq('var unknown = null; unknown is String;', unknown is String);
        assertEq('null is String;', null is String);

        assertEq('"" is String;', ("" is String));
		assertEq('false is Bool;', (false is Bool));
		assertEq("1 is Int;", (1 is Int));
		assertEq("1.5 is Int;", (1.5 is Int));
		assertEq("1.5 is Float;", (1.5 is Float));
		assertEq("[] is Array;", ([] is Array));

		// isOfType
		assertEq("var known:String = null; Std.isOfType(known, String);", Std.isOfType(known, String));

		assertEq("var unknown = null; Std.isOfType(unknown, String);", Std.isOfType(unknown, String));
		assertEq("Std.isOfType(null, String);", Std.isOfType(null, String));

		assertEq("Std.isOfType('', String);", Std.isOfType("", String));
		assertEq("Std.isOfType(false, Bool);", Std.isOfType(false, Bool));
		assertEq("Std.isOfType(1, Int)", Std.isOfType(1, Int));
		assertEq("Std.isOfType(1.5, Int);", Std.isOfType(1.5, Int));
		assertEq("Std.isOfType(1.5, Float);", Std.isOfType(1.5, Float));
		assertEq("Std.isOfType([], Array);", Std.isOfType([], Array));
		// Std.isOfType(cast unit.MyEnum.A, Array) == false;

		// instance
		#if !js
		assertEq("Std.downcast('', String)", Std.downcast("", String));
		Std.downcast("", String) == "";
		#end
		
		var a = [];
		assertEq("var a = []; Std.downcast(a, Array)", Std.downcast(a, Array));
		assertEq("Std.downcast(null, Array)", Std.downcast(null, Array));
		assertEq("Std.downcast(null, String)", Std.downcast(null, String));

		// string
		/*var cwts = new ClassWithToString();
		var cwtsc = new ClassWithToStringChild();
		var cwtsc2 = new ClassWithToStringChild2();

		Std.string(cwts) == "ClassWithToString.toString()";
		Std.string(cwtsc) == "ClassWithToString.toString()";
		Std.string(cwtsc2) == "ClassWithToStringChild2.toString()";

		Std.string(SomeEnum.NoArguments) == "NoArguments";
		Std.string(SomeEnum.OneArgument("foo")) == "OneArgument(foo)";*/

		assertEq("Std.string(null)", Std.string(null));

		// int
		assertEq("Std.int(-1.7)", Std.int(-1.7));
		assertEq("Std.int(-1.2)", Std.int(-1.2));
		assertEq("Std.int(-0.7)", Std.int(-0.7));
		assertEq("Std.int(-0.2)", Std.int(-0.2));
		assertEq("Std.int(0.7)", Std.int(0.7));
		assertEq("Std.int(0.2)", Std.int(0.2));

		// general
		assertEq("Std.parseInt('0')", Std.parseInt("0"));
		assertEq("Std.parseInt('-1')", Std.parseInt("-1"));

		// preceeding zeroes
		assertEq("Std.parseInt('0001')", Std.parseInt("0001"));
		assertEq("Std.parseInt('0010')", Std.parseInt("0010"));
		// trailing text
		assertEq("Std.parseInt('100x123')", Std.parseInt("100x123"));
		assertEq("Std.parseInt('12foo13')", Std.parseInt("12foo13"));
		assertEq("Std.parseInt('23e2')", Std.parseInt("23e2"));
		assertEq("Std.parseInt('0x10z')", Std.parseInt("0x10z"));
		assertEq("Std.parseInt('0x10x123')", Std.parseInt("0x10x123"));
		assertEq("Std.parseInt('0x10x123\\n')", Std.parseInt("0x10x123\n"));
		assertEq("Std.parseInt('0xff\\n')", Std.parseInt("0xff\n"));

		// hexadecimals
		assertEq("Std.parseInt('0xff')", Std.parseInt("0xff"));
		assertEq("Std.parseInt('0x123')", Std.parseInt("0x123"));
		assertEq("Std.parseInt('0XFF')", Std.parseInt("0XFF"));
		assertEq("Std.parseInt('0X123')", Std.parseInt("0X123"));
		assertEq("Std.parseInt('0X01')", Std.parseInt("0X01"));
		assertEq("Std.parseInt('0x01')", Std.parseInt("0x01"));

		// signs
		assertEq("Std.parseInt('123')", Std.parseInt("123"));
		assertEq("Std.parseInt('+123')", Std.parseInt("+123"));
		assertEq("Std.parseInt('-123')", Std.parseInt("-123"));
		assertEq("Std.parseInt('0xa0')", Std.parseInt("0xa0"));
		assertEq("Std.parseInt('+0xa0')", Std.parseInt("+0xa0"));
		assertEq("Std.parseInt('-0xa0')", Std.parseInt("-0xa0"));

		// whitespace: space, horizontal tab, newline, vertical tab, form feed, and carriage return
		assertEq("Std.parseInt('   5')", Std.parseInt("   5"));

		// whitespace and signs
		assertEq("Std.parseInt('  	16')", Std.parseInt("  	16"));
		assertEq("Std.parseInt('  	-16')", Std.parseInt("  	-16"));
		assertEq("Std.parseInt('  	+16')", Std.parseInt("  	+16"));
		assertEq("Std.parseInt('  	0x10')", Std.parseInt("  	0x10"));
		assertEq("Std.parseInt('  	-0x10')", Std.parseInt("  	-0x10"));
		assertEq("Std.parseInt('  	+0x10')", Std.parseInt("  	+0x10"));

		// binary and octal unsupported
		assertEq("Std.parseInt('010')", Std.parseInt("010"));
		assertEq("Std.parseInt('0b10')", Std.parseInt("0b10"));
		// null
		assertEq("Std.parseInt(null)", Std.parseInt(null));
		// no number
		assertEq("Std.parseInt('')", Std.parseInt(""));
		assertEq("Std.parseInt('abcd')", Std.parseInt("abcd"));
		assertEq("Std.parseInt('a10')", Std.parseInt("a10"));
		// invalid use of signs
		assertEq("Std.parseInt('++123')", Std.parseInt("++123"));
		assertEq("Std.parseInt('+-123')", Std.parseInt("+-123"));
		assertEq("Std.parseInt('-+123')", Std.parseInt("-+123"));
		assertEq("Std.parseInt('--123')", Std.parseInt("--123"));
		assertEq("Std.parseInt('+ 123')", Std.parseInt("+ 123"));
		assertEq("Std.parseInt('- 123')", Std.parseInt("- 123"));
		assertEq("Std.parseInt('++0x123')", Std.parseInt("++0x123"));
		assertEq("Std.parseInt('+-0x123')", Std.parseInt("+-0x123"));
		assertEq("Std.parseInt('-+0x123')", Std.parseInt("-+0x123"));
		assertEq("Std.parseInt('--0x123')", Std.parseInt("--0x123"));
		assertEq("Std.parseInt('+ 0x123')", Std.parseInt("+ 0x123"));
		assertEq("Std.parseInt('- 0x123')", Std.parseInt("- 0x123"));

		// hexadecimal prefix with no number
		//unspec(Std.parseInt.bind("0x"));
		//unspec(Std.parseInt.bind("0x C"));
		//unspec(Std.parseInt.bind("0x+A"));

		// parseFloat

		// general
		assertEq("Std.parseFloat('0')", Std.parseFloat('0'));
		assertEq("Std.parseFloat('0.0')", Std.parseFloat('0.0'));
		// preceeding zeroes
		assertEq("Std.parseFloat('0001')", Std.parseFloat('0001'));
		assertEq("Std.parseFloat('0010')", Std.parseFloat('0010'));
		// trailing text
		assertEq("Std.parseFloat('100x123')", Std.parseFloat('100x123'));
		assertEq("Std.parseFloat('12foo13')", Std.parseFloat('12foo13'));
		assertEq("Std.parseFloat('5.3 ')", Std.parseFloat('5.3 '));
		assertEq("Std.parseFloat('5.3 1')", Std.parseFloat('5.3 1'));
		// signs
		assertEq("Std.parseFloat('123.45')", Std.parseFloat('123.45'));
		assertEq("Std.parseFloat('+123.45')", Std.parseFloat('+123.45'));
		// whitespace: space, horizontal tab, newline, vertical tab, form feed, and carriage return
		// whitespace and signs
		assertEq("Std.parseFloat('  	1.6')", Std.parseFloat('  	1.6'));
		assertEq("Std.parseFloat('  	-1.6')", Std.parseFloat('  	-1.6'));
		assertEq("Std.parseFloat('  	+1.6')", Std.parseFloat('  	+1.6'));
		// exponent
		assertEq("Std.parseFloat('2.426670815e12')", Std.parseFloat('2.426670815e12'));
		assertEq("Std.parseFloat('2.426670815E12')", Std.parseFloat('2.426670815E12'));
		assertEq("Std.parseFloat('2.426670815e+12')", Std.parseFloat('2.426670815e+12'));
		assertEq("Std.parseFloat('2.426670815E+12')", Std.parseFloat('2.426670815E+12'));
		assertEq("Std.parseFloat('2.426670815e-12')", Std.parseFloat('2.426670815e-12'));
		assertEq("Std.parseFloat('2.426670815E-12')", Std.parseFloat('2.426670815E-12'));

		#if !interp
		assertEq("Std.parseFloat('6e')", Std.parseFloat('6e'));
		assertEq("Std.parseFloat('6e')", Std.parseFloat('6e'));
		#end
		// null
		assertEq("Math.isNaN(Std.parseFloat(null))", Math.isNaN(Std.parseFloat(null)));
		// no number
		assertEq("Math.isNaN(Std.parseFloat(''))", Math.isNaN(Std.parseFloat("")));
		assertEq("Math.isNaN(Std.parseFloat('abcd'))", Math.isNaN(Std.parseFloat("abcd")));
		assertEq("Math.isNaN(Std.parseFloat('a10'))", Math.isNaN(Std.parseFloat("a10")));
		// invalid use of signs
		assertEq("Math.isNaN(Std.parseFloat('++12.3'))", Math.isNaN(Std.parseFloat("++12.3")));
		assertEq("Math.isNaN(Std.parseFloat('+-12.3'))", Math.isNaN(Std.parseFloat("+-12.3")));
		assertEq("Math.isNaN(Std.parseFloat('-+12.3'))", Math.isNaN(Std.parseFloat("-+12.3")));
		assertEq("Math.isNaN(Std.parseFloat('--12.3'))", Math.isNaN(Std.parseFloat("--12.3")));
		assertEq("Math.isNaN(Std.parseFloat('+ 12.3'))", Math.isNaN(Std.parseFloat("+ 12.3")));
		assertEq("Math.isNaN(Std.parseFloat('- 12.3'))", Math.isNaN(Std.parseFloat("- 12.3")));

		// random
		// var x = Std.random(2);
		// //x in [0,1];
		// Std.random(1) == 0;
		// Std.random(0) == 0;
		// Std.random(-100) == 0;


		Util.runKnownBug("Not all escape sequences are supported", () -> {
			assertEq("Std.parseInt(' \\t\\n\\x0b\\x0c\\r16')", Std.parseInt(" \t\n\x0b\x0c\r16"));
			assertEq("Std.parseInt(' \\t\\n\\x0b\\x0c\\r0xa')", Std.parseInt(" \t\n\x0b\x0c\r0xa"));
			assertEq("Std.parseFloat(' \\t\\n\\x0b\\x0c\\r1.6')", Std.parseFloat('\t\n\x0b\x0c\r1.6'));
		});
	}

	override function teardown() {
		super.teardown();
	}
}