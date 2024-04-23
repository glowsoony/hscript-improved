package tests;

@:access(hscript.Interp)
@:access(hscript.Parser)
class TestCase {
	public var interp:Interp;
	public var headerCode:String = "";
	public var tailCode:String = "";

	public var clearPrevious:Bool = true;

	public function new() {}

	public function getNewInterp() {
		var interp = Util.getInterp();
		interp.errorHandler = Util.errorHandler;
		return interp;
	}

	public function setup() {
		interp = getNewInterp();
	}
	public function run() {}
	public function teardown() {}

	public function assertEq(script:String, expected:Dynamic, ?message:String) {
		if(message == null)
			message = script;
		Util.assertEq(execute(headerCode + script + tailCode), expected, message);
	}
	public function assertNeq(script:String, expected:Dynamic, ?message:String) {
		if(message == null)
			message = script;
		Util.assertNeq(execute(headerCode + script + tailCode), expected, message);
	}

	public function execute(script:String) {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		var expr = Util.parse(headerCode + script + tailCode);
		if (clearPrevious)
			return interp.execute(expr);
		else
			return interp.exprReturn(expr);
	}
}