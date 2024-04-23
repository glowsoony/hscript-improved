package tests;

class EvalOrderCase extends TestCase {
	override function setup() {
		super.setup();

		headerCode = '
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

		clearPrevious = true;

		var i = 0;
		assertEq("var i = 0; func(i++, i++, i++)", func(i++, i++, i++));
		var i = 0;
		assertEq("var i = 0; [i++, i++, i++].join(';')", [i++, i++, i++].join(";"));

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

		// &&

		var end = begin();
		(a() + b()) >= 0 && (c() + d()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 0 && (c() + d()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 99 && (c() + d()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 99 && (c() + d()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 0 && (c() + d()) >= 0 && (e() + f()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 0 && (c() + d()) >= 0 && (e() + f()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 99 && (c() + d()) >= 0 && (e() + f()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 99 && (c() + d()) >= 0 && (e() + f()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 0 && (c() + d()) >= 99 && (e() + f()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 0 && (c() + d()) >= 99 && (e() + f()) >= 0;
		end()', end());

		// ||

		var end = begin();
		(a() + b()) >= 0 || (c() + d()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 0 || (c() + d()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 99 || (c() + d()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 99 || (c() + d()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 0 || (c() + d()) >= 0 || (e() + f()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 0 || (c() + d()) >= 0 || (e() + f()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 99 || (c() + d()) >= 0 || (e() + f()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 99 || (c() + d()) >= 0 || (e() + f()) >= 0;
		end()', end());

		var end = begin();
		(a() + b()) >= 99 || (c() + d()) >= 99 || (e() + f()) >= 0;
		assertEq('var end = begin();
		(a() + b()) >= 99 || (c() + d()) >= 99 || (e() + f()) >= 0;
		end()', end());

headerCode += '
function arr(x, y) {
	return [];
}

function idx(x, y) {
	return 0;
}

function f1() {
	buf.push(1);
	return function(i) { };
}

function f2() {
	buf.push(2);
	return 2;
}
';
		// []

function arr(x, y) {
	return [];
}

function idx(x, y) {
	return 0;
}

function f1() {
	buf.push(1);
	return function(i) { };
}

function f2() {
	buf.push(2);
	return 2;
}

		var end = begin();
		var _ = (arr(a(), b()))[idx(c(), d())];
		assertEq('var end = begin();
		var _ = (arr(a(), b()))[idx(c(), d())];
		end()', end());

headerCode += '
var d:Dynamic = { f1: f1 };

function f3() {
	buf.push(3);
	d.f1 = function f3df1(i) {
		buf.push(4);
		return 4;
	}
	return 3;
}
';

var d:Dynamic = { f1: f1 };

function f3() {
	buf.push(3);
	d.f1 = function(i) {
		buf.push(4);
		return 4;
	}
	return 3;
}

		Util.runKnownBug("Function arguments get called first, before function is evaluated", () ->{
			var end = begin();
			d.f1()(f3());
			d.f1(f2());
			assertEq('var end = begin();
			// Expected internal behavior for  `d.f1()(f3());`
			//var func = d.f1();
			//func(f3());

			d.f1()(f3());
			d.f1(f2());
			end()', end());
		});
	}

	override function teardown() {
		super.teardown();
	}
}