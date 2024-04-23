package benchmark;

class Benchmark {
	public var times:Array<Float> = [];

	public function new(name:String, iterations:Int) {
		times = cast new haxe.ds.Vector<Float>(iterations);
		
		for (i in 0...iterations) {
			var startTime:Float = Util.getTime();
			benchmark();
			var endTime:Float = Util.getTime();
			times[i] = endTime-startTime;
		}
		times.sort(Reflect.compare);

		var total:Float = 0;
		for (time in times)
			total += time;

		Sys.println('--------------------$name BENCHMARK--------------------');
		Sys.println('Running $iterations times...');
		// Sys.println('Lowest Time: ${Util.exScienceN(times[0])}');
		// Sys.println('Average Time: ${Util.exScienceN(total/iterations)}');
		// Sys.println('Highest Time: ${Util.exScienceN(times[times.length-1])}');
		Sys.println('Lowest Time: ${Util.convertToReadableTime(times[0])}');
		Sys.println('Average Time: ${Util.convertToReadableTime(total/iterations)}');
		Sys.println('Highest Time: ${Util.convertToReadableTime(times[times.length-1])}');
		graph();
		Sys.println('--------------------$name BENCHMARK--------------------');
	}

	public function graph() {
		var size:{width:Int, height:Int} = {width: 20, height: 14};

		var collumRange:Float = times[times.length-1]-times[0];
		var counts:Array<Int> = cast new haxe.ds.Vector<Int>(size.width);

		for (time in times) {
			var index:Int = Std.int((time - times[0]) / (collumRange / size.width));
			counts[index]++;
		}

		var normalizedCounts:Array<Float> = [for (count in counts) count / times.length];
		var gridFilling:Array<Int> = [for (count in normalizedCounts) Math.round(count*size.height)];

		trace(normalizedCounts,gridFilling);
		for (y in 0...size.height) {
			for (x in 0...size.width) {
				Sys.print("*");
			}
			Sys.print("\n");
				
		}
	}

	// public static function remapToRange(value:Float, start1:Float, stop1:Float, start2:Float, stop2:Float):Float
	// {
	//     return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
	// }

	public function benchmark() {
		var array:Array<Float> = [];

		for (i in 0...10000)
			array.push(Math.random());
	}
}