package benchmark;

@:dce(off)
class TestBenchmark extends Benchmark {
	public function new() {
		super("Test", 10000);
	}

	var hscript = "var a:Array<Float> = []; for (i in 0...1000) a.push(i * 2 + 1 / 6);";

	public override function reset() {
		super.reset();
		a = [];
		if(interp != null)
			interp.variables.remove("a");
		cacheExpr(hscript);
	}

    public var a:Array<Float> = [];
	public override function haxeBenchmark() {
		for (i in 0...1000) a.push(i * 2 + 1 / 6);
	}

	public override function hscriptBenchmark() {
		execute(hscript);
	}
}