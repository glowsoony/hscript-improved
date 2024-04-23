package tests;

@:access(hscript.Interp)
@:access(hscript.Parser)
class TestCase extends HScriptRunner {
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
}