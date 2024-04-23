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
	}

	override function teardown() {
		super.teardown();
	}
}