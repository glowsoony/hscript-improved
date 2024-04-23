package tests;

class FinalCase extends TestCase {
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
		interp.variables.set("IntIterator", IntIterator);
		return interp;
	}

	override function run() {
        headerCode = "var i = 5; var x = 10;";

        var i = 5; var x = 10;

		hscript.Parser.optimize = false;

		assertDisplay("(i - x) * 30 + 90", ((i-x) * 30) + 90);
		assertDisplay("i - x * 30 + 90", i-x * 30 + 90);

		// Test operator precedence
		assertDisplay("i / x * 30 + 90", i / x * 30 + 90);
		assertDisplay("i / (x * 30) + 90", i / (x * 30) + 90);

		assertDisplay("x * 30 / i + 90", x * 30 / i + 90);
		//assertEq("(x * 30) / i + 90", x * 30 / i + 90);
	}

	function assertDisplay(script:String, expected:Dynamic) {
		var _script = script;
		script = '"${script}";\n' + script;
		assertEq(script, expected, _script);
	}

	override function teardown() {
		super.teardown();
	}
}