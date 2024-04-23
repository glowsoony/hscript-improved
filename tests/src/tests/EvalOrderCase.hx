package tests;

class EvalOrderCase extends TestCase {
	override function setup() {
		super.setup();

		headerCode = '
var a = 1;
var b = 2;
var c = 3;

function func(i1:Dynamic, i2:Dynamic, i3:Dynamic) {
	return i1 + ";" + i2 + ";" + i3;
}
';

		//tailCode = "";
	}

	override function run() {
		var a = 1;
		var b = 2;
		var c = 3;

		function func(i1:Dynamic, i2:Dynamic, i3:Dynamic) {
			return i1 + ";" + i2 + ";" + i3;
		}

		assertEq("func(a, b, c)", func(a, b, c));

		clearPrevious = true;

		var i = 0;
		assertEq("var i = 0; func(i++, i++, i++)", func(i++, i++, i++));
		var i = 0;
		assertEq("var i = 0; var a = [i++, i++, i++]; a.join(';')", [i++, i++, i++].join(";"));

		var i = 0;
		var obj = {
			a: i++,
			b: i++,
			c: i++
		}
		assertEq("var i = 0; var obj = {
			a: i++,
			b: i++,
			c: i++
		}; func(obj.a, obj.b, obj.c)", func(obj.a, obj.b, obj.c));

		var i = 0;
		assertEq("var i = 0; func(i++, [i++, i++].join(';'), i++)", func(i++, [i++, i++].join(";"), i++));

		clearPrevious = true;

		headerCode += '
var buf:Array<Int> = [];

function a() {
	trace("cock");
	trace(buf);
	trace(buf.push);
	buf.push(1);
	return 1;
}

function b() {
	buf.push(2);
	return 2;
}

function c() {
	buf.push(3);
	return 3;
}

function d() {
	buf.push(4);
	return 4;
}

function e() {
	buf.push(5);
	return 5;
}

function f() {
	buf.push(6);
	return 6;
}

function begin() {
	buf = [];
	return function() {
		return buf.join("_");
	}
}

function begin2() {
	buf = [];
	return () -> {
		return buf.join("_");
	}
}
';

var buf:Array<Int> = [];

function a() {
	buf.push(1);
	return 1;
}

function b() {
	buf.push(2);
	return 2;
}

function c() {
	buf.push(3);
	return 3;
}

function d() {
	buf.push(4);
	return 4;
}

function e() {
	buf.push(5);
	return 5;
}

function f() {
	buf.push(6);
	return 6;
}

function begin() {
	buf = [];
	return function() {
		return buf.join("_");
	}
}

function begin2() {
	buf = [];
	return () -> {
		return buf.join("_");
	}
}

		if(Main.SHOW_KNOWN_BUGS) {
			var end = begin();
			(a() + b()) >= 0 && (c() + d()) >= 0;
			assertEq('var end = begin();
			(a() + b()) >= 0 && (c() + d()) >= 0;
			end()', end());
		}

		var end = begin();
		var _ = (a() + b()) >= 0 && (c() + d()) >= 0;
		assertEq('var end = begin();
		var test = (a() + b()) >= 0 && (c() + d()) >= 0;
		trace(buf);
		end()', end());

		var end = begin2();
		var _ = (a() + b()) >= 0 && (c() + d()) >= 0;
		assertEq('var end = begin2();
		var test = (a() + b()) >= 0 && (c() + d()) >= 0;
		trace(buf, a());
		end()', end());
	}

	override function teardown() {
		super.teardown();
	}
}