package hscript;

import hscript.Expr;
import hscript.Tools;
import hscript.Parser;

@:access(hscript.Parser)
class Optimizer {
	public static function optimize(s:Expr):Expr {
		if(s == null)
			return null;

		var e = Tools.expr(s);

		// TODO: Convert EBinOp(+, a, EUnop(-, b)) to EBinOp(-, a, b) aka (a - b)
		// TODO: Make it so if EFor & EForKeyValue iterator variable isnt used its replaced with a $, which the code handles as doesnt exist
		// TODO: Make it so <PURE_VAR|CONST> == ?; gets removed, IF it isnt stored
		// TODO: Optimize ?. and ??
		// TODO: Optimize Std.string(CONSTANT) to "CONSTANT"
		// TODO: Remove Std.string if its the right side of a binop of a string
		// TODO: Add EForComprehension, EWhileComprehension, EDoWhileComprehension for better optimization
		// TODO: Optimize EFor(v, it, EBlock([e1])) to EFor(v, it, e1)

		switch(e) {
			// Parse all expressions and recreate the AST
			case EBlock(exprs):
				var exprs = exprs.map((v) -> optimize(v)).filter((v) -> v != null).filter((v) -> {
					if(Tools.expr(v).match(EBlock([]))) return false; // Remove empty blocks
					return true;
				});

				var newExprs = [];
				for(e in exprs) {
					switch(Tools.expr(e)) {
						case EBlock(iex):
							var declares = Lambda.exists(iex, ie -> hasDecl(ie));
							if(!declares) {
								for(ex in iex)
									newExprs.push(ex);
							} else {
								newExprs.push(e);
							}
						case EReturn(_): // remove stuff that are after a return
							newExprs.push(e);
							break;
						default:
							newExprs.push(e);
					}
				}
				return mk(EBlock(newExprs), s);

			case EIf(econd, e1, e2):
				var econd = optimize(econd);
				var e1 = optimize(e1);
				var e2 = optimize(e2);
				if(isConstant(econd)) {
					var econd = getConstant(econd);
					if(econd == true) {
						if(e1 == null)
							return mk(EBlock([]), s);
						return mk(EBlock([e1]), s);
					} else {
						if(e2 == null)
							return mk(EBlock([]), s);
						return mk(EBlock([e2]), s);
					}
				}
				return mk(EIf(econd, e1, e2), s);

			case ETernary(econd, e1, e2):
				var econd = optimize(econd);
				var e1 = optimize(e1);
				var e2 = optimize(e2);
				if(isConstant(econd)) {
					var econd = getConstant(econd);
					if(econd == true) {
						if(e1 == null)
							return mk(EBlock([]), s);
						return mk(EParent(e1), s);
					} else {
						if(e2 == null)
							return mk(EBlock([]), s);
						return mk(EParent(e2), s);
					}
				}
				if(isBool(e1) && isBool(e2)) {
					var c1 = getBool(e1);
					var c2 = getBool(e2);

					if(c1 == false && c2 == true) { // (VAR ? false : true)
						return optimize(mk(EUnop("!", true, econd), s));
					}
					if(c1 == true && c2 == false) { // (VAR ? true : false)
						return optimize(mk(Tools.expr(econd), s));
					}
					if(isConstant(econd)) {
						if(c1 == true && c2 == true) { // (CONST ? true : true)
							return mk(convertConstant(true), s);
						}
						if(c1 == false && c2 == false) { // (CONST ? false : false)
							return mk(convertConstant(false), s);
						}
						// TODO: Check if local variables are used in the condition
						// Since they cant have side effects, they can be optimized
					}
				}
				return mk(ETernary(econd, e1, e2), s);
			case EWhile(econd, e):
				var econd = optimize(econd);
				var e = optimize(e);
				return mk(EWhile(econd, e), s);
			case EDoWhile(econd, e):
				var econd = optimize(econd);
				var e = optimize(e);
				return mk(EDoWhile(econd, e), s);
			case EFor(v, it, e):
				var it = optimize(it);
				var e = optimize(e);
				return mk(EFor(v, it, e), s);
			case EForKeyValue(v, it, e, ithv):
				var it = optimize(it);
				var e = optimize(e);
				return mk(EForKeyValue(v, it, e, ithv), s);
			case EBreak:
				return mk(EBreak, s);
			case EContinue:
				return mk(EContinue, s);
			case EReturn(e):
				var e = optimize(e);
				return mk(EReturn(e), s);

			case ETry(e, v, t, ecatch):
				var e = optimize(e);
				var ecatch = optimize(ecatch);
				return mk(ETry(e, v, t, ecatch), s);

			case EThrow(e):
				var e = optimize(e);
				return mk(EThrow(e), s);

			case EVar(n, t, e, isPublic, isStatic):
				e = optimize(e);
				return mk(EVar(n, t, e, isPublic, isStatic), s);

			case ECall(e, params):
				e = optimize(e);
				params = params.map((v) -> optimize(v));
				if(params.length == 0) {
					switch(Tools.expr(e)) {
						case EField(fc, "toUpperCase", _):
							var str = getStringConstant(fc);
							if(str != null)
								return mk(convertConstant(str.toUpperCase()), s);
						case EField(fc, "toLowerCase", _):
							var str = getStringConstant(fc);
							if(str != null)
								return mk(convertConstant(str.toLowerCase()), s);
						default:
					}
				}
				return mk(ECall(e, params), s);

			case EField(e, f, safe):
				e = optimize(e);
				return mk(EField(e, f, safe), s);

			case EIdent(_) | EConst(_):
				return s;

			case EParent(e, noOptimize):
				e = optimize(e);
				return mk(noOptimize ? EParent(e) : Tools.expr(e), s);

			case ECheckType(e, t):
				e = optimize(e);
				return mk(ECheckType(e, t), s);

			case EMeta(name, args, e):
				e = optimize(e);
				return mk(EMeta(name, args, e), s);

			case ENew(cl, args):
				args = args.map((v) -> optimize(v));
				return mk(ENew(cl, args), s);

			case EObject(fl):
				fl.map((v) -> {
					v.e = optimize(v.e);
				});
				return mk(EObject(fl), s);

			case EImport(c, n):
				return mk(EImport(c, n), s);

			case EClass(name, fields, extend, interfaces): // Possible code not working
				fields = fields.map((v) -> optimize(v));
				return mk(EClass(name, fields, extend, interfaces), s);

			case EFunction(args, e, name, ret, isPublic, isStatic, isOverride):
				args.map((v) -> {
					v.name = v.name;
					v.value = optimize(v.value);
				});
				e = optimize(e);
				return mk(EFunction(args, e, name, ret, isPublic, isStatic, isOverride), s);

			case ESwitch(e, cases, def):
				e = optimize(e);
				cases.map((v) -> {
					var values = v.values.map((v) -> optimize(v));
					v.expr = optimize(v.expr);
				});
				def = optimize(def);

				if(isConstant(e)) {
					var econd = getConstant(e);

					for(c in cases) {
						for(v in c.values) {
							if(isConstant(v)) {
								var value = getConstant(v);
								if(value == econd)
									return mk(Tools.expr(c.expr), s);
							}
						}
					}

					var isAllCasesConstant = true;
					for(c in cases) {
						for(v in c.values) {
							if(!isConstant(v)) {
								isAllCasesConstant = false;
								break;
							}
						}
					}
					if(isAllCasesConstant) {
						#if debug
						//trace("Didnt find any cases that match");
						#end
						if(def != null)
							return mk(Tools.expr(def), s);
						else
							return mk(EBlock([]), s);
					}
				}

				return mk(ESwitch(e, cases, def), s);

			case EArrayDecl(arr, wantedType):
				arr = arr.map((v) -> optimize(v));
				return mk(EArrayDecl(arr, wantedType), s);

			case EArray(e, index):
				e = optimize(e);
				index = optimize(index);
				if(isConstant(index) && Tools.expr(e).match(EArrayDecl(_, _))) {
					var arr = switch(Tools.expr(e)) {
						case EArrayDecl(arr, _): arr;
						default: null;
					};

					var constant = Lambda.exists(arr, isConstant);
					if(constant) {
						return mk(Tools.expr(arr[getConstant(index)]), s);
					}
				}
				return mk(EArray(e, index), s);

			case EBinop(op, e1, e2):
				e1 = optimize(e1);
				e2 = optimize(e2);

				if(isConstant(e1) && isConstant(e2)) {
					var optimized:Dynamic = optimizeOp(op, getConstant(e1), getConstant(e2));
					if(optimized != null)
						return mk(convertConstant(optimized), s);
				}

				// Possible bugs here
				if(isNumber(e1) && !isConstant(e2)) {
					var c1 = getNumber(e1);
					if(compareNumber(c1, 0) && op == "+")
						return mk(Tools.expr(e2), s);
					//if(compareNumber(c1, 0) && op == "*")
					//	return mk(convertConstant(0), s);
				}

				if(!isConstant(e1) && isNumber(e2)) {
					var c2 = getNumber(e2);
					if(op == "+" && compareNumber(c2, 0))
						return mk(Tools.expr(e1), s);
					if(op == "/" && compareNumber(c2, 1))
						return mk(Tools.expr(e1), s);
					//if(op == "*" && compareNumber(c2, 0))
					//	return mk(convertConstant(0), s);
				}

				return mk(EBinop(op, e1, e2), s);

			case EUnop(op, prefix, e):
				e = optimize(e);

				if(isConstant(e) && prefix) {
					var constant:Dynamic = getConstant(e);
					switch(op) {
						case "-": return mk(convertConstant(-constant), s);
						case "!": return mk(convertConstant(!constant), s);
						case "~":
							var complement = #if (neko && !haxe3) haxe.Int32.complement(constant) #else ~constant #end;
							return mk(convertConstant(complement), s);
					}
				}

				return mk(EUnop(op, prefix, e), s);
			default:
				Sys.println("Unknown expr: " + e);
		}
		return s;
	}

	static function compareNumber(a:Dynamic, b:Dynamic):Bool {
		return switch(Type.typeof(a)) {
			case TInt:
				var a:Int = cast a;
				switch(Type.typeof(b)) {
					case TInt: a == cast(b, Int);
					case TFloat: a == cast(b, Float);
					default: false;
				}
			case TFloat:
				var a:Float = cast a;
				switch(Type.typeof(b)) {
					case TInt: a == cast(b, Int);
					case TFloat: a == cast(b, Float);
					default: false;
				}
			default: false;
		}
	}

	static function hasDecl(e:Expr):Bool {
		return switch(Tools.expr(e)) {
			case EVar(_): true;// has a declaration
			case EFunction(_): true;// has a declaration
			default: false;
		}
	}

	static function isConstant(e:Expr):Bool {
		return switch(Tools.expr(e)) {
			case EIdent("true") | EIdent("false") | EIdent("null"): true;
			case EConst(_): true;
			case EParent(e): isConstant(e);
			default: false;
		}
	}

	static function isBool(e:Expr):Bool {
		return switch(Tools.expr(e)) {
			case EIdent("true") | EIdent("false"): true;
			case EParent(e): isBool(e);
			default: false;
		}
	}

	static function isNumber(e:Expr):Bool {
		return switch(Tools.expr(e)) {
			case EConst(CInt(_)): true;
			case EConst(CFloat(_)): true;
			case EParent(e): isNumber(e);
			default: false;
		}
	}

	static function getNumber(e:Expr):Dynamic {
		return switch(Tools.expr(e)) {
			case EConst(CInt(value)): value;
			case EConst(CFloat(value)): value;
			case EParent(e): getNumber(e);
			default: throw "Unknown type " + Tools.expr(e);
		}
	}

	static function getBool(e:Expr):Bool {
		return switch(Tools.expr(e)) {
			case EIdent("true"): true;
			case EIdent("false"): true;
			case EParent(e): getBool(e);
			default: throw "Unknown type " + Tools.expr(e);
		}
	}

	static function getStringConstant(e:Expr):String {
		return switch(Tools.expr(e)) {
			case EConst(CString(value)): value;
			default: null;
		}
	}

	static function getConstant(e:Expr):Dynamic {
		return switch(Tools.expr(e)) {
			case EParent(e): getConstant(e);
			case EIdent("true"): true;
			case EIdent("false"): false;
			case EIdent("null"): null;
			case EConst(CInt(value)): value;
			case EConst(CFloat(value)): value;
			case EConst(CString(value)): value;
			default: throw "Unknown constant " + Tools.expr(e);
		}
	}

	static function convertConstant(value:Dynamic):ExprDef {
		return switch(Type.typeof(value)) {
			case TInt: EConst(CInt(value));
			case TFloat: EConst(CFloat(value));
			case TBool: EIdent(value == true ? "true" : "false");
			//case TString: EConst(CString(value));
			case TNull: EIdent("null");
			case TClass(String): EConst(CString(value));
			default: throw "Unknown type " + Type.typeof(value);
		}
	}

	static function mk(e:ExprDef, s:Expr):Expr {
		#if hscriptPos
		return new Expr(e, s.pmin, s.pmax, s.origin, s.line);
		#else
		return e;
		#end
	}

	static function optimizeOp(op, f1:Dynamic, f2:Dynamic):Dynamic {
		//trace("Optimizing " + f1 + " " + op + " " + f2);
		return switch(op) {
			case "+": f1 + f2;
			case "-": f1 - f2;
			case "*": f1 * f2;
			case "/": f1 / f2;
			case "%": f1 % f2;
			case "&": f1 & f2;
			case "|": f1 | f2;
			case "^": f1 ^ f2;
			case "<<": f1 << f2;
			case ">>": f1 >> f2;
			case ">>>": f1 >>> f2;
			case "==": f1 == f2;
			case "!=": f1 != f2;
			case ">=": f1 >= f2;
			case "<=": f1 <= f2;
			case ">": f1 > f2;
			case "<": f1 < f2;
			case "||": f1 == true || f2 == true;
			case "&&": f1 == true && f2 == true;
			case "??": f1 == null ? f2 : f1;
			default: null;
		}
	}
}