package tests;

using StringTools;

class StringToolsCase extends TestCase {
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
		Util.runKnownBug("Using StringTools; not working", () -> {
		});
	}

	override function teardown() {
		super.teardown();
	}
}