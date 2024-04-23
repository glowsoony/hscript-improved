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

		if (total == 0 || times.length <= 0) {
			Sys.println('BENCHMARK UNNOTICABLE, TOOK 0 SECONDS');
		} else {
			Sys.println('Running $iterations times...');
			Sys.println('Lowest Time: ${Util.convertToReadableTime(times[0])}');
			Sys.println('Average Time: ${Util.convertToReadableTime(total/iterations)}');
			Sys.println('Highest Time: ${Util.convertToReadableTime(times[times.length-1])}');
		}

		Sys.println('--------------------$name BENCHMARK--------------------');
	}

	public function benchmark() {}
}