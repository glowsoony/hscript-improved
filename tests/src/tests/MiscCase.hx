package tests;

class MiscCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("Std", Std);
		interp.variables.set("String", String);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Int", Int);
		interp.variables.set("IntIterator", IntIterator);
		return interp;
	}

	override function run() {
		assertEq("", null);
		assertEq("true", true);
		assertEq("false", false);
		assertEq("null", null);

		Util.runKnownBug("Redefining a variable with the same name as a function", () ->{
			// Redefining a function with the same name as a variable
			var a = 1; function a() { return 4; }
			assertEq("var a = 1; function a() { return 4; }; a", a);
		});

		var a = 1; var a = 2;
		assertEq("var a = 1; var a = 2; a", a);



		assertEq("0",0);
		assertEq("0xFF", 255);
		assertEq("0xFF_FF", 0xFFFF);
		assertEq("0b101", 5); //assertEq("0b101", 0b101);
		#if !(php || python)
			#if haxe3
			assertEq("0xBFFFFFFF", 0xBFFFFFFF);
			assertEq("0x7FFFFFFF", 0x7FFFFFFF);
			#elseif !neko
			assertEq("n(0xBFFFFFFF)", 0xBFFFFFFF, { n : haxe.Int32.toNativeInt });
			assertEq("n(0x7FFFFFFF)", 0x7FFFFFFF, { n : haxe.Int32.toNativeInt } );
			#end
		#end
		assertEq("-123",-123);
		assertEq("- 123",-123);
		assertEq("1.546",1.546);
		assertEq(".545",.545);
		assertEq("'bla'","bla");
		assertEq("null",null);
		assertEq("true",true);
		assertEq("false",false);
		assertEq("1 == 2",false);
		assertEq("1.3 == 1.3",true);
		assertEq("5 > 3",true);
		assertEq("0 < 0",false);
		assertEq("-1 <= -1",true);
		assertEq("1 + 2",3);
		assertEq("~545",-546);
		assertEq("'abc' + 55","abc55");
		assertEq("'abc' + 'de'","abcde");
		assertEq("-1 + 2",1);
		assertEq("1 / 5",0.2);
		assertEq("3 * 2 + 5",11);
		assertEq("3 * (2 + 5)",21);
		assertEq("3 * 2 // + 5 \n + 6",12);
		assertEq("3 /* 2\n */ + 5",8);
		assertEq("[55,66,77][1]",66);
		assertEq("var a = [55]; a[0] *= 2; a[0]",110);
		assertEq("x",55,{ x : 55 });
		assertEq("var y = 33; y",33);
		assertEq("{ 1; 2; 3; }",3);
		assertEq("o.val",55,{ o : { val : 55 } });
		assertEq("o.val",null,{ o : {} });
		assertEq("var a = 1; a++",1);
		assertEq("var a = 1; a++; a",2);
		assertEq("var a = 1; ++a",2);
		assertEq("var a = 1; a *= 3",3);
		assertEq("a = b = 3; a + b",6);
		assertEq("add(1,2)",3,{ add : function(x,y) return x + y });
		assertEq("a.push(5); a.pop() + a.pop()",{var a = [3]; a.push(5); a.pop() + a.pop();},{ a : [3] });
		assertEq("if( true ) 1 else 2",1);
		assertEq("if( false ) 1 else 2",2);
		assertEq("var t = 0; for( x in [1,2,3] ) t += x; t",6);
		assertEq("var a = new Array(); for( x in 0...5 ) a[x] = x; a.join('-')","0-1-2-3-4");
		assertEq("(function(a,b) return a + b)(4,5)",9);
		assertEq("var a = [1,[2,[3,[4,null]]]]; var t = 0; while( a != null ) { t += a[0]; a = a[1]; }; t",10);
		assertEq("var a = false; do { a = true; } while (!a); a;",true);
		assertEq("var t = 0; for( x in 1...10 ) t += x; t", 45);
		#if haxe3
		assertEq("var t = 0; for( x in new IntIterator(1,10) ) t +=x; t", 45);
		#else
		assertEq("var t = 0; for( x in new IntIter(1,10) ) t +=x; t", 45);
		#end
		assertEq("var x = 1; try { var x = 66; throw 789; } catch( e : Dynamic ) e + x",{var x = 1; try { var x = 66; throw 789; } catch( e : Dynamic ) e + x;});
		assertEq("var i=2; if( true ) --i; i",1);
		assertEq("var i=0; if( i++ > 0 ) i=3; i",1);
		assertEq("var a = 5/2; a",2.5);
		assertEq("{ x = 3; x; }", 3);
		assertEq("{ x : 3, y : {} }.x", 3);
		assertEq("function bug(){ \n }\nbug().x", null);
		assertEq("1 + 2 == 3", true);
		assertEq("-2 == 3 - 5", true);
		assertEq("var x=-3; x", -3);
		assertEq("var a:Array<Dynamic>=[1,2,4]; a[2]", 4);
		assertEq("/**/0", 0);
		assertEq("x=1;x*=-2", -2);
		assertEq("var f = x -> x + 1; f(3)", 4);
		assertEq("var f = () -> 55; f()", 55);
		assertEq("var f = (x) -> x + 1; f(3)", 4);
		assertEq("var f = (x:Int) -> x + 1; f(3)", 4);
		assertEq("var f = (x,y) -> x + y; f(3,1)", 4);
		assertEq("var f = (x,y:Int) -> x + y; f(3,1)", 4);
		assertEq("var f = (x:Int,y:Int) -> x + y; f(3,1)", 4);
		assertEq("var f:Int->Int->Int = (x:Int,y:Int) -> x + y; f(3,1)", {var f:Int->Int->Int = (x:Int,y:Int) -> x + y; f(3,1);});
		assertEq("var f:(x:Int, y:Int)->Int = (x:Int,y:Int) -> x + y; f(3,1)", {var f:(x:Int, y:Int)->Int = (x:Int,y:Int) -> x + y; f(3,1);});
		//assertEq("var f:(x:Int)->(y:Int, z:Int)->Int = (x:Int) -> (y:Int, z:Int) -> x + y + z; f(3)(1, 2)", {var f:(x:Int)->(y:Int, z:Int)->Int = (x:Int) -> (y:Int, z:Int) -> x + y + z; f(3)(1, 2);});
		//assertEq("var f:(x:Int)->(Int, Int)->Int = (x:Int) -> (y:Int, z:Int) -> x + y + z; f(3)(1, 2)", {var f:(x:Int)->(Int, Int)->Int = (x:Int) -> (y:Int, z:Int) -> x + y + z; f(3)(1, 2);});
		assertEq("var a = 10; var b = 5; a - -b", 15);
		assertEq("var a = 10; var b = 5; a - b / 2", 7.5);

		Util.runKnownBug("Redefining a variable in a scope overrides the previous definition", () -> {
			assertEq("{ var x = 0; } x",55,{ x : 55 });
		});
		Util.runKnownBug("Global Y isnt updated from the inside of the function", () -> {
			assertEq("var y = 0; var add = function(a) y += a; add(5); add(3); y", {var y = 0; var add = function(a) y += a; add(5); add(3); y;});
		});
		Util.runKnownBug("Throwing an exception inside a function doesnt return the correct value", () -> {
			assertEq("var x = 1; var f = function(x) throw x; try f(55) catch( e : Dynamic ) e + x",{
				var x = 1;
				var f:Dynamic = function(x) throw x;
				try
					f(55)
				catch( e:Dynamic )
					e + x;
			});
		});


		assertEq("var a = if( true ) 1 else 2; a",1);
		assertEq("var a = if( false ) 1 else 2; a",2);
		assertEq("if(true) 1; null", null);
		assertEq("if(false) 1; null", null);

		assertEq("[55,66,77][1]",66);

		assertEq("{
			var a = 1;
			function b() { return a; }
			a = 2;
			b();
		}", 2);

	}

	override function teardown() {
		super.teardown();
	}
}