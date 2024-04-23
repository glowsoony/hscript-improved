package tests;

class IntIteratorCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("assertEq", Util.assertEq);
		interp.variables.set("IntIterator", IntIterator);
		return interp;
	}

	override function run() {
		var ii = new IntIterator(0, 2);
		var line = 19;
		execute('
		var ii = new IntIterator(0, 2);
		assertEq(ii.hasNext(), ${ii.hasNext()}, "l${line++}");
		assertEq(ii.next(), ${ii.next()}, "l${line++}");
		assertEq(ii.hasNext(), ${ii.hasNext()}, "l${line++}");
		assertEq(ii.next(), ${ii.next()}, "l${line++}");
		assertEq(ii.hasNext(), ${ii.hasNext()}, "l${line++}");
		');

		var ii = new IntIterator(0, 2);
		var r = [];
		for (i in ii)
			r.push(i);
		assertEq('
		var ii = new IntIterator(0, 2);
		var r = [];
		for (i in ii)
			r.push(i);
		r
		', r);

		var ii = new IntIterator(0, 2);
		var r = [];
		for (i in ii)
			r.push(i);
		for (i in ii)
			r.push(i);
		assertEq('
		var ii = new IntIterator(0, 2);
		var r = [];
		for (i in ii)
			r.push(i);
		for (i in ii)
			r.push(i);
		r
		', r);
	}

	override function teardown() {
		super.teardown();
	}
}