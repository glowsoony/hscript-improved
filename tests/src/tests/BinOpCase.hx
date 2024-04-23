package tests;

class BinOpCase extends TestCase {
	override function setup() {
		super.setup();

		headerCode = "
var a = 1;
var b = 2;
var c = 3;
";

		//tailCode = "";
	}

	override function run() {
		var a = 1;
		var b = 2;
		var c = 3;

		assertEq("a + b", a + b);
		assertEq("a - b", a - b);
		assertEq("a * b", a * b);
		assertEq("a / b", a / b);
		assertEq("a % b", a % b);
		assertEq("a & b", a & b);
		assertEq("a | b", a | b);
		assertEq("a ^ b", a ^ b);
		assertEq("5 ^ 3", 5 ^ 3);
		assertEq("a << b", a << b);
		assertEq("a >> b", a >> b);
		assertEq("a >>> b", a >>> b);
		assertEq("a == b", a == b);
		assertEq("a != b", a != b);
		assertEq("a >= b", a >= b);
		assertEq("a <= b", a <= b);
		assertEq("a > b", a > b);
		assertEq("a < b", a < b);
		//assertEq("a || b", a || b);
		//assertEq("a && b", a && b);
		//assertEq("a is b", false);

		// Order of operations
		assertEq("a + b * c", a + b * c);
		assertEq("a * b + c", a * b + c);
		assertEq("a * (b + c)", a * (b + c));
		assertEq("(a + b) * c", (a + b) * c);
		assertEq("a / b / c", a / b / c);
		assertEq("a % b % c", a % b % c);
		assertEq("a & b & c", a & b & c);
		assertEq("a | b | c", a | b | c);
		assertEq("a ^ b ^ c", a ^ b ^ c);
		assertEq("a << b << c", a << b << c);
		assertEq("a >> b >> c", a >> b >> c);
		assertEq("a >>> b >>> c", a >>> b >>> c);

		// Precedence
		assertEq("a + b + c", a + b + c);
		assertEq("a + b - c", a + b - c);
		assertEq("a * b / c", a * b / c);
		assertEq("a / b * c", a / b * c);
		assertEq("a % b | c", a % b | c);
		assertEq("a & b ^ c", a & b ^ c);
		assertEq("a << b >> c", a << b >> c);
		assertEq("a >>> b << c", a >>> b << c);


		headerCode = "
		var a = null;
		var b = 'hello';
		var c = 'world';
		var d = '!';
		";

		var a = null;
		var b = 'hello';
		var c = 'world';
		var d = '!';

		assertEq("a + b", a + b);

		#if (haxe >= "4.3.0")
		assertEq("a ?? b", a ?? b);
		assertEq("a ?? b ?? c", a ?? b ?? c);
		assertEq("a ?? b ?? c ?? d", a ?? b ?? c ?? d);
		#else
		Sys.println("Tests are inaccurate with Haxe 4.2.x");
		assertEq("a ?? b", nc(a, b));
		assertEq("a ?? b ?? c", nc(a, nc(b, c)));
		assertEq("a ?? b ?? c ?? d", nc(a, nc(b, nc(c, d))));
		#end

		var tests:Array<Array<Dynamic>> = [
			[null, "null"],
			[{}, "{}"],
			[{a: 1}, "{a: 1}"],
			[{a: {b: 1}}, "{a: {b: 1}}"],
			[{a: {b: {c: 1}}}, "{a: {b: {c: 1}}}"],
			[{a: {b: {c: {d: 1}}}}, "{a: {b: {c: {d: 1}}}}"]
		];

		for(code in tests) {
			headerCode = 'var a = ${code[1]};';
			var a = code[0];

			#if (haxe >= "4.3.0")
			assertEq("a?.b", a?.b);
			assertEq("a?.b?.c", a?.b?.c);
			assertEq("a?.b?.c?.d", a?.b?.c?.d);
			#else
			assertEq("a?.b", nf(a, b));
			assertEq("a?.b?.c", nf(nf(a, b), c));
			assertEq("a?.b?.c?.d", nf(nf(nf(a, b), c), d));
			#end
		}

		headerCode = "
		var a = null;
		var b = 'hello';
		";

		var a = null;
		var b = 'hello';

		#if (haxe >= "4.3.0")
		a ??= b;
		assertEq("a ??"+"= b; a", a);
		#else
		if(a == null) a = b;
		assertEq("a ??"+"= b; a", a);
		#end

		headerCode = "
		var a = 'test';
		var b = 'hello';
		";

		var a = 'test';
		var b = 'hello';

		#if (haxe >= "4.3.0")
		a ??= b;
		assertEq("a ??"+"= b; a", a);
		#else
		if(a == null) a = b;
		assertEq("a ??"+"= b; a", a);
		#end
	}

	inline function nc(a:Dynamic, b:Dynamic):Dynamic {
		return (a == null) ? b : a;
	}

	inline function nf(a:Dynamic, b:String):Dynamic {
		return (a == null) ? null : Reflect.field(a, b);
	}

	override function teardown() {
		super.teardown();
	}
}