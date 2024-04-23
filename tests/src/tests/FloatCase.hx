package tests;

class FloatCase extends TestCase {
	override function setup() {
		super.setup();

		headerCode = "
		var nan = Math.NaN;
		var pinf = Math.POSITIVE_INFINITY;
		var ninf = Math.NEGATIVE_INFINITY;
		var fl:Float = 0.0;
		";
	}

	override function run() {
		var nan = Math.NaN;
		var pinf = Math.POSITIVE_INFINITY;
		var ninf = Math.NEGATIVE_INFINITY;
		var fl:Float = 0.0;

		assertEq("fl > nan", fl > nan);
		assertEq("fl < nan", fl < nan);
		assertEq("fl >= nan", fl >= nan);
		assertEq("fl <= nan", fl <= nan);
		assertEq("fl == nan", fl == nan);
		assertEq("fl != nan", fl != nan);

		assertEq("nan > nan", nan > nan);
		assertEq("nan < nan", nan < nan);
		assertEq("nan >= nan", nan >= nan);
		assertEq("nan <= nan", nan <= nan);
		assertEq("nan == nan", nan == nan);
		assertEq("nan != nan", nan != nan);

		assertEq("pinf > nan", pinf > nan);
		assertEq("pinf < nan", pinf < nan);
		assertEq("pinf >= nan", pinf >= nan);
		assertEq("pinf <= nan", pinf <= nan);
		assertEq("pinf == nan", pinf == nan);
		assertEq("pinf != nan", pinf != nan);

		assertEq("ninf > nan", ninf > nan);
		assertEq("ninf < nan", ninf < nan);
		assertEq("ninf >= nan", ninf >= nan);
		assertEq("ninf <= nan", ninf <= nan);
		assertEq("ninf == nan", ninf == nan);
		assertEq("ninf != nan", ninf != nan);

		assertEq("nan > fl", nan > fl);
		assertEq("nan < fl", nan < fl);
		assertEq("nan >= fl", nan >= fl);
		assertEq("nan <= fl", nan <= fl);
		assertEq("nan == fl", nan == fl);
		assertEq("nan != fl", nan != fl);

		assertEq("nan > pinf", nan > pinf);
		assertEq("nan < pinf", nan < pinf);
		assertEq("nan >= pinf", nan >= pinf);
		assertEq("nan <= pinf", nan <= pinf);
		assertEq("nan == pinf", nan == pinf);
		assertEq("nan != pinf", nan != pinf);

		assertEq("nan > ninf", nan > ninf);
		assertEq("nan < ninf", nan < ninf);
		assertEq("nan >= ninf", nan >= ninf);
		assertEq("nan <= ninf", nan <= ninf);
		assertEq("nan == ninf", nan == ninf);
		assertEq("nan != ninf", nan != ninf);
	}

	override function teardown() {
		super.teardown();
	}
}