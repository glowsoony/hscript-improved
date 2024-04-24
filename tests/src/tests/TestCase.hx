package tests;

import hscript.Printer;

@:access(hscript.Interp)
@:access(hscript.Parser)
class TestCase extends HScriptRunner {
	public function assertEq(script:String, expected:Dynamic, ?message:String, ?vars:Dynamic, ?pos:haxe.PosInfos) {
		if(message == null)
			message = script;
		var result = if(vars != null)
			executeWithVars(script, vars);
		else
			execute(script);
		if(!Util.assertEq(result, expected, message, pos)) {
			Sys.println("> " + Printer.convertExprToString(lastExpr));
			return false;
		}
		return true;
	}

	public function assertEqPrintable(script:String, expected:Dynamic, ?message:String, ?vars:Dynamic, ?pos:haxe.PosInfos) {
		if(message == null)
			message = script;
		var result = if(vars != null)
			executeWithVars(script, vars);
		else
			execute(script);
		if(!Util.assertEqPrintable(result, expected, message, pos)) {
			Sys.println("> " + Printer.convertExprToString(lastExpr));
			return false;
		}
		return true;
	}

	public function assertNeq(script:String, expected:Dynamic, ?message:String, ?vars:Dynamic, ?pos:haxe.PosInfos) {
		if(message == null)
			message = script;
		var result = if(vars != null)
			executeWithVars(script, vars);
		else
			execute(script);
		if(!Util.assertNeq(result, expected, message, pos)) {
			Sys.println("> " + Printer.convertExprToString(lastExpr));
			return false;
		}
		return true;
	}
}