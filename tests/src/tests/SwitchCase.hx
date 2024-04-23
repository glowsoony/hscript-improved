package tests;

class SwitchCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function run() {
		assertEq("switch(1) { case 1: 1; case 2: 2; default: -1; }", switch(1) { case 1: 1; case 2: 2; default: -1; });
		assertEq("switch(3) { case 1: 1; case 2: 2; case 3: 3; default: -1; }", switch(3) { case 1: 1; case 2: 2; case 3: 3; default: -1; });
		assertEq("switch(3) { case 1: 1; case 2: 2; case 3: 3; default: -1; }", switch(3) { case 1: 1; case 2: 2; case 3: 3; default: -1; });
		assertEq("switch(6) { case 1: 1; case 2: 2; case 3: 3; default: -1; }", switch(6) { case 1: 1; case 2: 2; case 3: 3; default: -1; });

		// TODO: add https://haxe.org/manual/lf-pattern-matching-enums.html
		// TODO: add https://haxe.org/manual/lf-pattern-matching-variable-capture.html (including case _)
		// TODO: add https://haxe.org/manual/lf-pattern-matching-structure.html
		// TODO: add https://haxe.org/manual/lf-pattern-matching-array.html
		// TODO: add https://haxe.org/manual/lf-pattern-matching-guards.html
		// TODO: add https://haxe.org/manual/lf-pattern-matching-tuples.html
		// TODO: add https://haxe.org/manual/lf-pattern-matching-extractors.html
		// TODO: detect https://haxe.org/manual/lf-pattern-matching-exhaustiveness.html
		// TODO: maybe? https://haxe.org/manual/lf-pattern-matching-unused.html
		// TODO: add https://haxe.org/manual/lf-pattern-matching-single.html

		assertEq("switch(5) { case 1|4: 'error'; case 5: 0; default: -1; }", switch(5) { case 1|4: 'error'; case 5: 0; default: -1; });
		assertEq("switch(5) { case 1|4: 'error'; default: -1; }", switch(5) { case 1|4: 'error'; default: -1; });
		assertEq("switch(5) { case (1|4): 'error'; default: -1; }", switch(5) { case (1|4): 'error'; default: -1; });
		assertEq("switch(5) { case 1,4: 'error'; case 5: 0; default: -1; }", switch(5) { case 1,4: 'error'; case 5: 0; default: -1; });
	}

	override function teardown() {
		super.teardown();
	}
}