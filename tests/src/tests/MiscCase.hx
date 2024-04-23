package tests;

class MiscCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function run() {
		assertEq("", null);
		assertEq("true", true);
		assertEq("false", false);
		assertEq("null", null);

		if(Main.SHOW_KNOWN_BUGS) {
			// Redefining a function with the same name as a variable
			var a = 1; function a() { return 4; }
			assertEq("var a = 1; function a() { return 4; }; a", a);
		}

		var a = 1; var a = 2;
		assertEq("var a = 1; var a = 2; a", a);
	}

	override function teardown() {
		super.teardown();
	}
}