package benchmark;

@:dce(off)
class TestBenchmark extends Benchmark {
	public function new() {
		super("Test", 10000);
	}

	public override function reset() {
		super.reset();
		a = [];
		if(interp != null)
			interp.variables.remove("a");
	}

    public var a:Array<Float> = [];
	public override function haxeBenchmark() {
		for (i in 0...1000) a.push(i);
	}

	public override function hscriptBenchmark() {
		execute("var a:Array<Float> = []; for (i in 0...1000) a.push(i);");
	}
}