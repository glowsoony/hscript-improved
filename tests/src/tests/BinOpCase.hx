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

	}

	override function teardown() {
		super.teardown();
	}
}