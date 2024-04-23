package tests;

class EnumCase extends TestCase {
	override function setup() {
		super.setup();
	}

	override function getNewInterp() {
		var interp = super.getNewInterp();
		interp.variables.set("assertEq", Util.assertEq);
		interp.variables.set("SomeEnum", SomeEnum);
		interp.variables.set("Type", Type);
		return interp;
	}

	override function run() {
		assertEq("SomeEnum.NoArguments;", SomeEnum.NoArguments);
		assertEq("SomeEnum.OneArgument('foo');", SomeEnum.OneArgument("foo"));
		assertEq("SomeEnum.TwoArguments('foo', 'bar');", SomeEnum.TwoArguments("foo", "bar"));

		assertEq("Type.enumEq(SomeEnum.NoArguments, SomeEnum.NoArguments);", Type.enumEq(SomeEnum.NoArguments, SomeEnum.NoArguments));
		assertEq("Type.enumEq(SomeEnum.NoArguments, SomeEnum.OneArgument('foo'));", Type.enumEq(SomeEnum.NoArguments, SomeEnum.OneArgument("foo")));
		assertEq("Type.enumEq(SomeEnum.OneArgument('foo'), SomeEnum.OneArgument('foo'));", Type.enumEq(SomeEnum.OneArgument("foo"), SomeEnum.OneArgument("foo")));
		assertEq("Type.enumEq(SomeEnum.OneArgument('foo'), SomeEnum.TwoArguments('foo', 'bar'));", Type.enumEq(SomeEnum.OneArgument("foo"), SomeEnum.TwoArguments("foo", "bar")));
		assertEq("Type.enumEq(SomeEnum.TwoArguments('foo', 'bar'), SomeEnum.TwoArguments('foo', 'bar'));", Type.enumEq(SomeEnum.TwoArguments("foo", "bar"), SomeEnum.TwoArguments("foo", "bar")));
		assertEq("Type.enumEq(SomeEnum.TwoArguments('foo', 'bar'), SomeEnum.NoArguments);", Type.enumEq(SomeEnum.TwoArguments("foo", "bar"), SomeEnum.NoArguments));
	}

	override function teardown() {
		super.teardown();
	}
}

enum SomeEnum {
	NoArguments;
	OneArgument(arg:String);
	TwoArguments(arg1:String, arg2:String);
}