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
		if(!Main.SHOW_KNOWN_BUGS) {
			Sys.println("Hiding known bugs [TEMPORARY]");
		}
		runTest("Array", new ArrayCase());
		runTest("BinOp", new BinOpCase());
		runTest("Enum", new EnumCase());
		runTest("EvalOrder", new EvalOrderCase());
		runTest("Float", new FloatCase());
		runTest("IntIterator", new IntIteratorCase());
		runTest("Lambda", new LambdaCase());
		runTest("List", new ListCase());
		runTest("Math", new MathCase());
		runTest("Map", new MapCase());
		runTest("Misc", new MiscCase());
		runTest("Reflect", new ReflectCase());
		runTest("Regex", new RegexCase());
		runTest("Std", new StdCase());
		runTest("String", new StringCase());
		runTest("StringBuf", new StringBufCase());
		runTest("StringTools", new StringToolsCase());
		// TODO: UnicodeCase.hx?
		// TODO: UnicodeStringCase.hx?
		Util.printTestResults();
		#end
	}

	#if !BENCHMARK
	static function runTest(name:String, test:TestCase) {
		Util.startUnitTest(name);
		test.setup();
		test.run();
		test.teardown();
		Util.endUnitTest();
	}
	#end
}
