package tests;

class MathCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function run() {
		assertEq("Math.PI", Math.PI);
		assertEq("1 + 2", 3);
		assertEq("1 + 2 + 3", 6);
		assertEq("1 + 2 + 3 + 4", 10);
		assertEq("(1 + 2) + 3", 6);
		assertEq("(1 + 2) + 3 + 4", 10);
		assertEq("(1 + 2) * 3", 9);
		assertEq("(1 + 2) * 3 * 4", 36);
		assertEq("((1 + 2) * 3 * 4) / 2", 18);
	}

	override function teardown() {
		super.teardown();
	}
}