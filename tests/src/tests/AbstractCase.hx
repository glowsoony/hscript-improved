package tests;

import haxe.xml.Access;
import Xml;

class AbstractCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function run() {
		var access = new Access(Xml.parse("<test test=\"cool\"><hello>world</hello></test>").firstElement());

		trace(access.att.test);

		getNewInterp().execute(Util.parse("
// Converts to
import haxe.xml._Access.Access_Impl_;
import haxe.xml._Access.AttribAccess_Impl_;

var access = Xml.parse('<test test=\"cool\"><hello>world</hello></test>').firstElement();

trace(AttribAccess_Impl_.resolve(Access_Impl_.get_att(access), 'test'));


// trace(Access_Impl_.get_att(access));
//abstract import haxe.xml.Access;
//import haxe.xml.Access with Abstract;


import haxe.xml.Access;

var access = new Access(Xml.parse('<test test=\"cool\"><hello>world</hello></test>').firstElement());

trace(access.att.test);
"));
	}

	override function teardown() {
		super.teardown();
	}
}

abstract TestAbstract(Int)
{
	//public static inline var TRANSPARENT:TestAbstract = 0x00000000;
	//public static inline var WHITE:TestAbstract = 0xFFFFFFFF;
	//public static inline var GRAY:TestAbstract = 0xFF808080;
	//public static inline var BLACK:TestAbstract = 0xFF000000;
}

enum abstract TestEnumAbstract(Int) {
	
}