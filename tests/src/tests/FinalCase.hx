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

		assertDisplay("(i - x) * 30 + 90", ((i-x) * 30) + 90);
		assertDisplay("i - x * 30 + 90", i-x * 30 + 90);

		// Test operator precedence
		assertDisplay("i / x * 30 + 90", i / x * 30 + 90);
		assertDisplay("i / (x * 30) + 90", i / (x * 30) + 90);

		assertDisplay("x * 30 / i + 90", x * 30 / i + 90);
		//assertEq("(x * 30) / i + 90", x * 30 / i + 90);

		// (_) -> {a = false;}
		// Shouldnt be converted to  (_) -> return {a = false;}

		Util.parse("openCodesList(false, codesOpened ? false : true, previousOpen != open ? true : false);");
		Util.parse("openCodesList(false, 'HELLO' ? false : false, 'WORLD' ? true : true);");
		Util.parse('FlxTween.tween(newSprite, {"scale.x": 1, "scale.y": 1, alpha: 1, angle: 0}, 0.3, {ease: FlxEase.qaudInOut});');
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