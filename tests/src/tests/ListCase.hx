package tests;

class ListCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("List", List);
		return interp;
	}

	override function run() {
		var l4 = new List();
		l4.add(1);
		l4.add(2);
		l4.add(3);
		l4.add(5);
		l4.add(8);

		headerCode = "var l4 = new List();
		l4.add(1);
		l4.add(2);
		l4.add(3);
		l4.add(5);
		l4.add(8);";

		assertEq("[for (k=>v in l4) k]", [for (k=>v in l4) k]);
		assertEq("[for (k=>v in l4) v]", [for (k=>v in l4) v]);
		assertEq("[for (k=>v in l4) k*v]", [for (k=>v in l4) k*v]);
	}

	override function teardown() {
		super.teardown();
	}
}