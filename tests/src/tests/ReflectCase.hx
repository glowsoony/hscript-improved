package tests;

class ReflectCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("Reflect", Reflect);
		return interp;
	}

	override function run() {
		headerCode = "var x = { a: 1, b: null };";
        var x = { a: 1, b: null };

		assertEq("Reflect.field(x, 'a')", Reflect.field(x, 'a'));
		assertEq("Reflect.field(x, 'b')", Reflect.field(x, 'b'));
		assertEq("Reflect.field(x, 'c')", Reflect.field(x, 'c'));

		assertEq("Reflect.hasField(x, 'a')", Reflect.hasField(x, 'a'));
		assertEq("Reflect.hasField(x, 'b')", Reflect.hasField(x, 'b'));
		assertEq("Reflect.hasField(x, 'c')", Reflect.hasField(x, 'c'));

		headerCode = "var n = null;";
		var n = null;

		assertEq("Reflect.field(n, n)", Reflect.field(n, n));
		assertEq("Reflect.field(1, 'foo')", Reflect.field(1, "foo"));

		headerCode = "var x = { a: 1, b: null };";

		Reflect.setField(x, 'a', 2); assertEq("Reflect.setField(x, 'a', 2); x.a", x.a);
		Reflect.setField(x, 'c', 'foo'); assertEq("Reflect.setField(x, 'c', 'foo'); Reflect.field(x, 'c')", Reflect.field(x, 'c'));

		headerCode = "var x = { a: 1, b: null };";

		Reflect.setProperty(x, 'a', 2); assertEq("Reflect.setProperty(x, 'a', 2); x.a", x.a);
		Reflect.setProperty(x, 'c', 'foo'); assertEq("Reflect.setProperty(x, 'c', 'foo'); Reflect.field(x, 'c')", Reflect.field(x, 'c'));
		
		headerCode = "var x = function(t) return 1;  var y = function(t) return -1;  var z = function(t) return 1;";
		var x = function(t) return 1;
		var y = function(t) return -1;
		var z = function(t) return 1;

		assertEq("Reflect.compareMethods(x,y)", Reflect.compareMethods(x,y));
		assertEq("Reflect.compareMethods(x,z)", Reflect.compareMethods(x,z));
		assertEq("Reflect.compareMethods(y,z)", Reflect.compareMethods(y,z));
		assertEq("Reflect.compareMethods(x,x)", Reflect.compareMethods(x,x));
		assertEq("Reflect.compareMethods(y,y)", Reflect.compareMethods(y,y));
		assertEq("Reflect.compareMethods(z,z)", Reflect.compareMethods(z,z));
	}

	override function teardown() {
		super.teardown();
	}
}