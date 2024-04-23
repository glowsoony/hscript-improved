package tests;

class LambdaCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("Lambda", Lambda);
		return interp;
	}

	override function run() {
		// has
		assertEq("Lambda.has([1,2,3],1)", Lambda.has([1,2,3],1));
		assertEq("Lambda.has([1,2,3],4)", Lambda.has([1,2,3],4));
		assertEq("Lambda.has([],null)", Lambda.has([],null));
		assertEq("Lambda.has([null],null)", Lambda.has([null],null));

		// exists
		assertEq("Lambda.exists([1, 2, 3], function(i) return i == 2)", Lambda.exists([1, 2, 3], function(i) return i == 2));
		assertEq("Lambda.exists([1, 2, 3], function(i) return i == 4)", Lambda.exists([1, 2, 3], function(i) return i == 4));
		assertEq("Lambda.exists([], function(x) return true)", Lambda.exists([], function(x) return true));

		// foreach
		assertEq("Lambda.foreach([2, 4, 6],function(i) return i % 2 == 0)", Lambda.foreach([2, 4, 6],function(i) return i % 2 == 0));
		assertEq("Lambda.foreach([2, 4, 7],function(i) return i % 2 == 0)", Lambda.foreach([2, 4, 7],function(i) return i % 2 == 0));
		assertEq("Lambda.foreach([], function(x) return false)", Lambda.foreach([], function(x) return false));
	}

	override function teardown() {
		super.teardown();
	}
}