package benchmark;

@:dce(off)
class TestBenchmark extends Benchmark {
	public function new() {
		super("Test", 10000);
	}

	//var hscript = "var a:Array<Float> = []; for (i in 0...1000) a.push(i * 2 + 1 / 6); if(true == true) a.push(1);";
	var hscript = "
	var a:Array<Float> = [];
	for(i in 0...1000) {
		switch(5) {
			case true: a.push(1);
			default: a.push(i / 1);
		}
	}
	if(('a' == 'a') ? true : false) a.push(1);
	if(true == true)
		a.push(1);";

	function test() {
		return 5;
	}

	var aaa = null;

	public override function reset() {
		super.reset();
		aaa = {
			test: test
		};
		if(expr == null)
			cacheExpr(hscript);
		interp.variables.remove("a");
		//interp.variables.set("aaa", aaa);
		interp.variables.set("test", test);
	}

	public override function haxeBenchmark() {
		var a:Array<Float> = [];
		//for (i in 0...1000) a.push(i * 2 + 1 / 6);
		//for (i in 0...1000) a.push(i / 2 + 3 / 6);
		for(i in 0...1000) {
			switch(5) {
				case 0: a.push(1);
				default: a.push(i / 1);
			}
		}
		if(('a' == 'a') ? true : false) a.push(1);
		if(true == true) a.push(1);
	}

	public override function hscriptBenchmark() {
		interp.execute(expr);
	}
}