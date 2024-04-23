package tests;

@:access(hscript.Interp)
@:access(hscript.Parser)
class TestCase extends HScriptRunner {
	public function assertEq(script:String, expected:Dynamic, ?message:String, ?vars:Dynamic, ?pos:haxe.PosInfos) {
		if(message == null)
			message = script;
		var result = if(vars != null)
			executeWithVars(headerCode + script + tailCode, vars);
		else
			execute(headerCode + script + tailCode);
		Util.assertEq(result, expected, message, pos);
	}

	public function assertNeq(script:String, expected:Dynamic, ?message:String, ?vars:Dynamic, ?pos:haxe.PosInfos) {
		if(message == null)
			message = script;
		var result = if(vars != null)
			executeWithVars(headerCode + script + tailCode, vars);
		else
			execute(headerCode + script + tailCode);
		Util.assertNeq(result, expected, message, pos);
	}
}