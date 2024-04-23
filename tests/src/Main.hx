#if BENCHMARK
import benchmark.*;
#else
import tests.*;
#end

class Main {
	public static var SHOW_KNOWN_BUGS:Bool = false;

	static function main() {
		#if BENCHMARK
		Sys.println("Running benchmark");

		new Benchmark("Test", 1000);
		#else
		Sys.println("Beginning tests");
		runTest("Array", new ArrayCase());
		runTest("BinOp", new BinOpCase());
		runTest("EvalOrder", new EvalOrderCase());
		runTest("Math", new MathCase());
		runTest("Misc", new MiscCase());
		Util.printTestResults();
		#end
	}

	#if !BENCHMARK
	static function runTest(name:String, test:TestCase) {
		Util.startUnitTest("Math");
		test.setup();
		test.run();
		test.teardown();
		Util.endUnitTest();
	}
	#end
}
