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

	public function executeWithVars(script:String, vars:Dynamic):Dynamic {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		var expr = Util.parse(headerCode + script + tailCode);
		if(expr == null)
			return "ERROR";
		for(v in Reflect.fields(vars))
			interp.variables.set(v, Reflect.field(vars, v));
		if (clearPrevious)
			return interp.execute(expr);
		else
			return interp.exprReturn(expr);
	}
}