package tests;

class ErrorCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		return interp;
	}

	override function run() {
		Sys.println("TODO: write tests for errors");
	}

	override function teardown() {
		super.teardown();
	}
}