package tests;

class ArrayCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function run() {
		assertEq("[].length", 0);
		assertEq("[1].length", 1);
		assertEq("[1,2,3].length", 3);
		assertEq("var a = [];\na[4] = 1;\na.length", 5);
		assertEq("var a = [];\na[4] = 1;\na[a.length] = 1;\na.length", 6);
	}

	override function teardown() {
		super.teardown();
	}
}