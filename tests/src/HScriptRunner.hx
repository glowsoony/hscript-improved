package;

import _hscript.Interp;
import _hscript.Expr;

@:access(_hscript.Interp)
@:access(_hscript.Parser)
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

	private var lastExpr:Expr;

	public function execute(script:String):Dynamic {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		lastExpr = Util.parse(headerCode + script + tailCode);
		if(lastExpr == null)
			return "ERROR";
		if (clearPrevious)
			return interp.execute(lastExpr);
		else
			return interp.exprReturn(lastExpr);
	}

	public function executeWithVars(script:String, vars:Dynamic):Dynamic {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		lastExpr = Util.parse(headerCode + script + tailCode);
		if(lastExpr == null)
			return "ERROR";
		for(v in Reflect.fields(vars))
			interp.variables.set(v, Reflect.field(vars, v));
		if (clearPrevious)
			return interp.execute(lastExpr);
		else
			return interp.exprReturn(lastExpr);
	}

	public function executeUnsafe(script:String):Dynamic {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		lastExpr = Util.parseUnsafe(headerCode + script + tailCode);
		if (clearPrevious)
			return interp.execute(lastExpr);
		else
			return interp.exprReturn(lastExpr);
	}

	public function executeWithVarsUnsafe(script:String, vars:Dynamic):Dynamic {
		var interp = clearPrevious ? getNewInterp() : this.interp;
		lastExpr = Util.parseUnsafe(headerCode + script + tailCode);
		for(v in Reflect.fields(vars))
			interp.variables.set(v, Reflect.field(vars, v));
		if (clearPrevious)
			return interp.execute(lastExpr);
		else
			return interp.exprReturn(lastExpr);
	}
}