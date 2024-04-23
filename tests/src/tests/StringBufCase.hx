package tests;

class StringBufCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("Std", Std);
		interp.variables.set("StringBuf", StringBuf);
		return interp;
	}

	override function run() {
		var x = new StringBuf();
		x.addSub("abcdefg", 1);
		assertEq('var x = new StringBuf(); x.addSub("abcdefg", 1); x.toString()', x.toString());

		Util.runKnownBug("Emojis dont work", () -> {
			var x = new StringBuf();
			x.add("👽");
			assertEq('var x = new StringBuf(); x.add("👽"); x.toString()', x.toString());
		});

		var x = new StringBuf();
		x.add(0x1F47D);
		assertEq('var x = new StringBuf(); x.add(0x1F47D); x.toString()', x.toString());
	}

	override function teardown() {
		super.teardown();
	}
}