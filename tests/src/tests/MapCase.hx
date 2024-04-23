package tests;

class MapCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("IntMap", haxe.ds.IntMap);
		interp.variables.set("ObjectMap", haxe.ds.ObjectMap);
		interp.variables.set("StringMap", haxe.ds.StringMap);
		return interp;
	}

	override function run() {
        Sys.println("TODO: Write tests for Map");
	}

	override function teardown() {
		super.teardown();
	}
}