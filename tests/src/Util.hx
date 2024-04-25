import hscript.Expr.Error;
import hscript.Printer;
import haxe.Constraints.IMap;

using StringTools;

class Util {
	// TODO: check this for bugs
	static function deepEqual(a:Dynamic, b:Dynamic):Bool {
		if (a == b) {
			return true;
		}

		if (a == null || b == null) {
			return false;
		}

		if ((a is String) && (b is String)) {
			return a == b;
		}

		if ((a is Array) && (b is Array)) {
			var aArray:Array<Dynamic> = cast a;
			var bArray:Array<Dynamic> = cast b;

			if (aArray.length != bArray.length) {
				return false;
			}

			for (i in 0...aArray.length) {
				if (!deepEqual(aArray[i], bArray[i])) {
					return false;
				}
			}

			return true;
		}

		if(Std.isOfType(a, Enum) && Std.isOfType(b, Enum)) {
			if(Type.enumEq(a, b))
				return true;
		}

		// Check Map Equality
		if (Std.isOfType(a, IMap) && Std.isOfType(b, IMap)) {
			var aMap:IMap<Dynamic, Dynamic> = cast a;
			var bMap:IMap<Dynamic, Dynamic> = cast b;

			var aFields = [for(v in aMap.keys()) v];
			var bFields = [for(v in bMap.keys()) v];

			if (aFields.length != bFields.length) {
				return false;
			}

			// Sort fields to ensure consistent comparison
			aFields.sort(Reflect.compare);
			bFields.sort(Reflect.compare);

			for (key in aMap.keys()) {
				if (!bMap.exists(key) || !deepEqual(aMap.get(key), bMap.get(key))) {
					return false;
				}
			}
			return true;
		}

		if (Reflect.isObject(a) && Reflect.isObject(b)) {
			var aFields = Reflect.fields(a);
			var bFields = Reflect.fields(b);

			if (aFields.length != bFields.length) {
				return false;
			}

			// Sort fields to ensure consistent comparison
			aFields.sort(Reflect.compare);
			bFields.sort(Reflect.compare);

			for (i in 0...aFields.length) {
				var field = aFields[i];
				if (field != bFields[i] || !deepEqual(Reflect.field(a, field), Reflect.field(b, field))) {
					return false;
				}
			}

			return true;
		}

		if(!Type.enumEq(Type.typeof(a), Type.typeof(b))) {
			if(Type.typeof(a) == TInt && Type.typeof(b) == TFloat) {
				return cast(a, Int) == cast(b, Float);
			}
			if(Type.typeof(a) == TFloat && Type.typeof(b) == TInt) {
				return cast(a, Float) == cast(b, Int);
			}
		}

		return false;
	}


	public static function assert(value:Bool, message:String, ?pos:haxe.PosInfos) {
		if (value) {
			passedTestUnits++;
			return true;
		} else {
			Sys.println("Assertion failed: " + message);
			Sys.println("> At " + pos.fileName + ":" + pos.lineNumber);
			failedTestUnits++;
			return false;
		}
	}

	public static function assertEq(value:Dynamic, expected:Dynamic, message:String, ?pos:haxe.PosInfos) {
		var equals = deepEqual(value, expected);
		var passed = equals;
		//if (Std.isOfType(value, Array) && Std.isOfType(expected, Array)) {
		//	if (deepCompareArrays(value, expected))
		//		passed = true;
		//}
		//else if (Std.isOfType(value, Enum) && Std.isOfType(expected, Enum)) {
		//	if(Type.enumEq(value, expected))
		//		passed = true;
		//}

		if (passed) {
			passedTestUnits++;
			return true;
		} else {
			Sys.println("Assertion failed: " + message + " Expected: " + expected + " Got: " + value);
			Sys.println("> At " + pos.fileName + ":" + pos.lineNumber);
			failedTestUnits++;
			return false;
		}
	}

	public static function assertEqPrintable(value:Dynamic, expected:Dynamic, message:String, ?pos:haxe.PosInfos) {
		//var passed = value == expected;
		//if (Std.isOfType(value, Array) && Std.isOfType(expected, Array)) {
		//	if (deepCompareArrays(value, expected))
		//		passed = true;
		//}
		//else if (Std.isOfType(value, Enum) && Std.isOfType(expected, Enum)) {
		//	if(Type.enumEq(value, expected))
		//		passed = true;
		//}
		var equals = deepEqual(value, expected);
		var passed = equals;

		if (passed) {
			passedTestUnits++;
			return true;
		} else {
			Sys.println("Assertion failed: " + message + " Expected: " + Printer.getEscapedString(expected) + " Got: " + Printer.getEscapedString(value));
			Sys.println("> At " + pos.fileName + ":" + pos.lineNumber);
			failedTestUnits++;
			return false;
		}
	}

	public static function assertNeq(value:Dynamic, expected:Dynamic, message:String, ?pos:haxe.PosInfos) {
		//var passed = value != expected;
		//if (Std.isOfType(value, Array) && Std.isOfType(expected, Array)) {
		//	if (!deepCompareArrays(value, expected))
		//		passed = true;
		//}
		var equals = deepEqual(value, expected);
		var passed = !equals;

		// WARNING THIS MIGHT NOT WORK

		if (passed) {
			passedTestUnits++;
			return true;
		} else {
			Sys.println("Assertion failed: " + message + " Expected: " + expected + " Got: " + value);
			Sys.println("> At " + pos.fileName + ":" + pos.lineNumber);
			failedTestUnits++;
			return false;
		}
	}

	static var currentTestPath:Array<String> = [];
	static var totalTestUnits:Int = 0;
	static var passedTestUnits:Int = 0;
	static var failedTestUnits:Int = 0;
	static var skippedKnownBugs:Int = 0;

	public static function runKnownBug(name:String, func:Void->Void) {
		if (Main.SHOW_KNOWN_BUGS) {
			Sys.println("Running known bug: " + name);
			func();
		} else {
			skippedKnownBugs++;
		}
	}

	public static function startUnitTest(path:String) {
		Sys.println("Running unit tests in " + path);
		currentTestPath.push(path);
		totalTestUnits++;
	}

	public static function endUnitTest() {
		var path = currentTestPath.pop();
		//Sys.println("Finished unit tests " + path);
	}

	public static function printTestResults() {
		Sys.println(Util.getTitle('RESULTS'));
		Sys.println("Total Units: " + totalTestUnits);
		Sys.println("Total tests passed: " + passedTestUnits);
		Sys.println("Total tests failed: " + failedTestUnits);
		if(skippedKnownBugs > 0)
			Sys.println("Skipped known bugs: " + skippedKnownBugs);
		//Sys.println("Finished unit tests " + currentTestPath.pop());
		Sys.println(Util.getTitle('RESULTS'));
	}

	public static function parse(str:String) {
		var p = new Parser();
		p.allowTypes = true;
		p.allowMetadata = true;
		p.allowJSON = true;
		var result = null;
		try {
			result = p.parseString(str);
		} catch (e:Dynamic) {
			Sys.println("## Error parsing: " + str);
			Sys.println("## Error: " + e);
			// Print stack trace
			var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			Sys.println("## Stack trace: " + stack);
		}
		return result;
	}

	public static function getInterp() {
		var interp = new Interp();
		//interp.importEnabled = true;
		//interp.allowStaticVariables = true;
		//interp.allowPublicVariables = true;
		interp.variables.set("Math", Math);
		interp.variables.set("Std", Std);
		interp.variables.set("Type", Type);
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

		Sys.println("ERROR: " + fn + err);
		//Logs.traceColored([
		//	Logs.logText(fn, GREEN),
		//	Logs.logText(err, RED)
		//], ERROR);
	}

	public static function deepCompareArrays(a1: Array<Dynamic>, a2: Array<Dynamic>): Bool {
		if (a1.length != a2.length)
			return false;

		for (i in 0...a1.length) {
			var item1 = a1[i];
			var item2 = a2[i];

			if (Std.isOfType(item1, Array) && Std.isOfType(item2, Array)) {
				if (!deepCompareArrays(item1, item2))
					return false;
			} else if (item1 != item2)
				return false;
		}
		return true;
	}

	public static function roundDecimal(Value:Float, Precision:Int):Float {
		var mult:Float = 1;
		for (i in 0...Precision)
			mult *= 10;
		return Math.fround(Value * mult) / mult;
	}

	public inline static function roundWith(Value:Float, Mult:Int):Float {
		return Math.fround(Value * Mult) / Mult;
	}

	public static function getTitle(title:String, ?dashsLen:Int = 46) {
		var l = StringTools.lpad("", "-", Std.int((dashsLen - title.length - 2)/2));
		return l + ' $title ' + l;
	}
}