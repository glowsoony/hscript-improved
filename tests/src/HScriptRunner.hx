package;

@:access(hscript.Interp)
@:access(hscript.Parser)
class HScriptRunner {
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

	public function execute(script:String):Dynamic {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		var expr = Util.parse(headerCode + script + tailCode);
		if(expr == null)
			return "ERROR";
		if (clearPrevious)
			return interp.execute(expr);
		else
			return interp.exprReturn(expr);
	}
}