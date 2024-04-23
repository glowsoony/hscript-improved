import hscript.Expr.Error;

using StringTools;

class Util {
	public static function assert(value:Bool, message:String) {
		if (value) {
			passedTestUnits++;
		} else {
			Sys.println("Assertion failed: " + message);
			failedTestUnits++;
		}
	}

	public static function assertEq(value:Dynamic, expected:Dynamic, message:String) {
		var passed = value == expected;
		if (Std.isOfType(value, Array) && Std.isOfType(expected, Array)) {
			if (deepCompareArrays(value, expected))
				passed = true;
		}

		if (passed) {
			passedTestUnits++;
		} else {
			Sys.println("Assertion failed: " + message + " Expected: " + expected + " Got: " + value);
			failedTestUnits++;
		}
	}

	public static function assertNeq(value:Dynamic, expected:Dynamic, message:String) {
		var passed = value != expected;
		if (Std.isOfType(value, Array) && Std.isOfType(expected, Array)) {
			if (!deepCompareArrays(value, expected))
				passed = true;
		}

		// WARNING THIS MIGHT NOT WORK

		if (passed) {
			passedTestUnits++;
		} else {
			Sys.println("Assertion failed: " + message + " Expected: " + expected + " Got: " + value);
			failedTestUnits++;
		}
	}

	static var currentTestPath:Array<String> = [];
	static var totalTestUnits:Int = 0;
	static var passedTestUnits:Int = 0;
	static var failedTestUnits:Int = 0;

	public static function startUnitTest(path:String) {
		//Sys.println("Running unit tests " + path);
		currentTestPath.push(path);
		totalTestUnits++;
	}

	public static function endUnitTest() {
		var path = currentTestPath.pop();
		//Sys.println("Finished unit tests " + path);
	}

	public static function printTestResults() {
		Sys.println("-----------------------------------------------------------");
		Sys.println("Total Units: " + totalTestUnits);
		Sys.println("Total tests passed: " + passedTestUnits);
		Sys.println("Total tests failed: " + failedTestUnits);
		//Sys.println("Finished unit tests " + currentTestPath.pop());
	}

	public static function parse(str:String) {
		var p = new Parser();
		p.allowTypes = true;
		p.allowMetadata = true;
		p.allowJSON = true;
		return p.parseString(str);
	}

	public static function getInterp() {
		var interp = new Interp();
		//interp.importEnabled = true;
		//interp.allowStaticVariables = true;
		//interp.allowPublicVariables = true;
		interp.variables.set("Math", Math);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		return interp;
	}

	public static inline function getTime():Float {
		return untyped __global__.__time_stamp();
	}

	// expandScientificNotation but its WAY too long to write out
	public static function exScienceN(value:Float):String {
		var parts = Std.string(value).split("e");
		var coefficient = Std.parseFloat(parts[0]);
		var exponent = parts.length > 1 ? Std.parseInt(parts[1]) : 0;
		var result = "";

		if (exponent > 0) {
			result += StringTools.replace(Std.string(coefficient), ".", "");
			var decimalLength = Std.string(coefficient).split(".")[1].length;
			var additionalZeros:Int = Std.int(Math.abs(exponent - decimalLength));
			result += StringTools.lpad("", "0", additionalZeros); // repeat
		} else {
			result += "0.";
			var leadingZeros:Int = Std.int(Math.abs(exponent) - 1);
			result += StringTools.lpad("", "0", leadingZeros); // repeat
			result += StringTools.replace(Std.string(coefficient), ".", "");
		}

		return result;
	}

	public static function convertToReadableTime(seconds:Float) {
		if (seconds >= 1) return seconds + " s";
		var milliseconds = seconds * 1000;       // 1 second = 1,000 ms
		if (milliseconds >= 1) return milliseconds + " ms";
		var microseconds = seconds * 1000000;   // 1 second = 1,000,000 μs
		if (microseconds >= 1) return microseconds + " μs";
		var nanoseconds = seconds * 1000000000; // 1 second = 1,000,000,000 ns
		return nanoseconds + " ns";
	}

	public static function errorHandler(error:hscript.Error) {
		var fileName = error.origin;
		var fn = '$fileName:${error.line}: ';
		var err = error.toString();
		if (err.startsWith(fn)) err = err.substr(fn.length);

		Sys.println(fn + err);
		//Logs.traceColored([
		//	Logs.logText(fn, GREEN),
		//	Logs.logText(err, RED)
		//], ERROR);
	}

	public static function deepCompareArrays(a1: Array<Dynamic>, a2: Array<Dynamic>): Bool {
		if (a1.length != a2.length) {
			return false;
		}

		for (i in 0...a1.length) {
			var item1 = a1[i];
			var item2 = a2[i];

			if (Std.isOfType(item1, Array) && Std.isOfType(item2, Array)) {
				if (!deepCompareArrays(item1, item2))
					return false;
			} else if (item1 != item2) {
				return false;
			}
		}

		return true;
	}
}