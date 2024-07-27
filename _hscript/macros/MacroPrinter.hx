package _hscript.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class MacroPrinter {
	public static function convertTypePathToString(t:TypePath):String {
		//trace(t);
		// TODO: handle pack from files in same module;
		//trace(t);
		var type = t.name;
		if(t.pack != null && t.pack.length > 0) {
			type = t.pack.join(".") + "." + type;
			//Sys.println(t);
		}

		if(t.params != null && t.params.length > 0)
			type += "<" + t.params.map(function(p) return typeParamToString(p)).join(", ") + ">";

		return type;
	}

	public static function typeToString(t:ComplexType):String {
		if(t == null) return "null";
		return switch(t) {
			case TPath(p):
				convertTypePathToString(p);
			//case TAnonymous(a): a.get().fields.map(function(f) return f.name).join(", ");
			//case TInst(c, _): c.toString();
			//case TEnum(e, _): e.toString();
			//case TAbstract(a, _): a.toString();
			//case TType(t, _): t.toString();
			//case TFun(args, ret): args.map(function(a) return a.name).join(", ") + " -> " + typeToString(ret);
			default: null;
		}
	}

	public static function typeParamToString(t:TypeParam):String {
		return switch(t) {
			case TPType(t): typeToString(t);
			case TPExpr(e): null;
			default: null;
		}
	}

	public static function getIndentation(tabs:Int):String {
		var s = new StringBuf();
		for(i in 0...tabs) s.add("    ");
		return s.toString();
	}

	public static function convertFieldToString(f:Field, tabs:Int = 0, module:String = null):String {
		var s = new StringBuf();
		s.add("Field(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: \"");
		s.add(f.name);
		s.add("\",\n");
		if(module != null) {
			s.add(getIndentation(tabs+1));
			s.add("module: \"");
			s.add(module);
			s.add("\",\n");
		}
		if(f.access != null && f.access.length > 0) {
			s.add(getIndentation(tabs+1));
			s.add("access: [");
			var first = true;
			for(a in f.access) {
				if(!first) {
					s.add(", ");
				}
				s.add(Std.string(a));
				first = false;
			}
			s.add("],\n");
		}
		s.add(getIndentation(tabs+1));
		s.add("kind: ");
		switch(f.kind) {
			case FVar(t, e):
				s.add("FVar(");
				s.add(typeToString(t));
				s.add(", ");
				s.add(convertExprToString(e, tabs));
				s.add(")");
			case FProp(get, set, t, e):
				s.add("FProp(");
				s.add(Std.string(get));
				s.add(", ");
				s.add(Std.string(set));
				s.add(", ");
				s.add(typeToString(t));
				s.add(", ");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			case FFun(fun):
				s.add("FFun(");
				s.add(convertFunctionToString(fun, tabs + 1));
				s.add(")");
			default: throw "Unknown field kind " + Std.string(f.kind);
		}
		if(f.meta.length > 0) {
			s.add(",\n");
			s.add(getIndentation(tabs+1));
			s.add("meta: ");
			s.add(convertMetaToString(f.meta, tabs+1));
		}
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}

	public static function convertFunctionToString(fun:Function, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("{");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("args: [");
		var first = true;
		if(fun.args.length > 0) {
			s.add("\n");
		}
		for(a in fun.args) {
			if(!first) {
				s.add(",\n");
			}
			s.add(getIndentation(tabs+2));
			s.add(convertArgToString(a, tabs+2));
			//if(first) {
			//	s.add("\n");
			//}
			first = false;
		}
		if(!first) {
			s.add("\n");
			s.add(getIndentation(tabs+1));
		}
		s.add("],\n");
		s.add(getIndentation(tabs+1));
		s.add("ret: ");
		s.add(typeToString(fun.ret));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add("}");

		return s.toString();
	}

	public static function convertArgToString(a:FunctionArg, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("{");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: \"");
		s.add(a.name);
		s.add("\",\n");
		s.add(getIndentation(tabs+1));
		s.add("opt: ");
		s.add(Std.string(a.opt));
		if(a.type != null) {
			s.add(",\n");
			s.add(getIndentation(tabs+1));
			s.add("type: ");
			s.add(typeToString(a.type));
		}
		if(a.value != null) {
			s.add(",\n");
			s.add(getIndentation(tabs+1));
			s.add("value: ");
			s.add(convertExprToString(a.value, tabs+1));
		}
		if(a.meta.length > 0) {
			s.add(",\n");
			s.add(getIndentation(tabs+1));
			s.add("meta: ");
			s.add(convertMetaToString(a.meta, tabs+1));
		}
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add("}");

		return s.toString();
	}

	public static function convertMetaEntryToString(m:MetadataEntry, tabs:Int = 0):String {
		var s = new StringBuf();

		s.add("MetadataEntry(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: ");
		s.add(m.name);
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("params: [");
		var first = true;
		for(param in m.params) {
			if(!first) {
				s.add(",\n");
				s.add(getIndentation(tabs+2));
			}
			first = false;
			s.add(convertExprToString(param, tabs+2));
		}
		s.add("]\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}

	public static function convertMetaToString(m:Metadata, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("Metadata([");
		if(m.length > 0) {
			s.add("\n");
			s.add(getIndentation(tabs+1));
			var first = true;
			for(entry in m) {
				if(!first) {
					s.add(",\n");
					s.add(getIndentation(tabs+1));
				}
				first = false;
				s.add(convertMetaEntryToString(entry, tabs + 1));
			}
			s.add("\n");
			s.add(getIndentation(tabs));
		}
		s.add("])");

		return s.toString();
	}

	public static function convertExprToString(e:Expr, tabs:Int = 0):String {
		if(e == null) return "null";
		var s = new StringBuf();
		switch(e.expr) {
			case EConst(c):
				s.add("EConst(");
				s.add(Std.string(c));
				s.add(")");
			case EField(e, f):
				s.add("EField(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", ");
				s.add(f);
				s.add(")");
			case EBlock(exprs):
				s.add("EBlock([");
				var first = true;
				for(e in exprs) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add("\n");
					s.add(getIndentation(tabs + 2));
					s.add(convertExprToString(e, tabs + 1));
				}
				s.add("\n");
				s.add(getIndentation(tabs + 1));
				s.add("])");
			case EIf(econd, eif, eelse):
				s.add("EIf(");
				s.add(convertExprToString(econd, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(eif, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(eelse, tabs + 1));
				s.add(")");
			case EWhile(econd, e, normalWhile):
				s.add("EWhile(");
				s.add(convertExprToString(econd, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", ");
				s.add(Std.string(normalWhile));
				s.add(")");
			case EFor(it, expr):
				s.add("EFor(");
				s.add(convertExprToString(it, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(expr, tabs + 1));
				s.add(")");
			case EBreak:
				s.add("EBreak");
			case EContinue:
				s.add("EContinue");
			case EArrayDecl(values):
				s.add("EArrayDecl([");
				var first = true;
				for(v in values) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertExprToString(v, tabs + 1));
				}
				s.add("])");
			case EUnop(op, postFix, e):
				s.add("EUnop(");
				s.add(Std.string(op));
				s.add(", ");
				s.add(Std.string(postFix));
				s.add(", ");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			case EBinop(op, e1, e2):
				s.add("EBinop(");
				s.add(Std.string(op));
				s.add(", ");
				s.add(convertExprToString(e1, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(e2, tabs + 1));
				s.add(")");
			case ENew(t, params):
				s.add("ENew(");
				s.add(convertTypePathToString(t));
				s.add(", [");
				var first = true;
				for(p in params) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertExprToString(p, tabs + 1));
				}
				s.add("])");
			case ECast(e, t):
				s.add("ECast(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", ");
				s.add(typeToString(t));
				s.add(")");
			case EFunction(name, f):
				s.add("EFunction(");
				s.add(name);
				s.add(", ");
				s.add(convertFunctionToString(f, tabs + 1));
				s.add(")");
			case EVars(vars):
				s.add("EVars([");
				var first = true;
				for(v in vars) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertVarToString(v, tabs + 1));
				}
				s.add("])");
			case ECall(e, params):
				s.add("ECall(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", [");
				var first = true;
				for(p in params) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertExprToString(p, tabs + 1));
				}
				s.add("])");
			case EMeta(m, e):
				s.add("EMeta(");
				s.add(convertMetaEntryToString(m, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			case EParenthesis(e):
				s.add("EParenthesis(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			case EObjectDecl(fields):
				s.add("EObjectDecl([");
				var first = true;
				for(f in fields) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertObjectFieldToString(f, tabs + 1));
				}
				s.add("])");
			case ETernary(econd, eif, eelse):
				s.add("ETernary(");
				s.add(convertExprToString(econd, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(eif, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(eelse, tabs + 1));
				s.add(")");
			case EArray(e1, e2):
				s.add("EArray(");
				s.add(convertExprToString(e1, tabs + 1));
				s.add(", ");
				s.add(convertExprToString(e2, tabs + 1));
				s.add(")");
			case ECheckType(e, t):
				s.add("ECheckType(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", ");
				s.add(typeToString(t));
				s.add(")");
			case EDisplay(e, d):
				s.add("EDisplay(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", ");
				s.add(Std.string(d));
				s.add(")");
			case EThrow(e):
				s.add("EThrow(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			case ETry(e, catches):
				s.add("ETry(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", [");
				var first = true;
				for(c in catches) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertCatchToString(c, tabs + 1));
				}
				s.add("])");
			case EDisplayNew(t):
				s.add("EDisplayNew(");
				s.add(convertTypePathToString(t));
				s.add(")");
			case EIs(e1, t):
				s.add("EIs(");
				s.add(convertExprToString(e1, tabs + 1));
				s.add(", ");
				s.add(typeToString(t));
				s.add(")");
			case ESwitch(e, cases, edef):
				s.add("ESwitch(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(", [");
				var first = true;
				for(c in cases) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertSwitchCaseToString(c, tabs + 1));
				}
				s.add("], ");
				s.add(convertExprToString(edef, tabs + 1));
				s.add(")");
			case EUntyped(e):
				s.add("EUntyped(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			case EReturn(e):
				s.add("EReturn(");
				s.add(convertExprToString(e, tabs + 1));
				s.add(")");
			default:
				s.add("Unknown expr " + Std.string(e.expr));
		}

		return s.toString();
	}

	public static function convertSwitchCaseToString(c:Case, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("Case(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("expr: ");
		s.add(convertExprToString(c.expr, tabs+1));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("guard: ");
		s.add(convertExprToString(c.guard, tabs+1));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}

	public static function convertCatchToString(c:Catch, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("Catch(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("type: ");
		s.add(typeToString(c.type));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("expr: ");
		s.add(convertExprToString(c.expr, tabs+1));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}

	public static function convertObjectFieldToString(f:ObjectField, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("ObjectField(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		if(f.quotes == Quoted) {
			s.add("field: \"");
			s.add(f.field);
			s.add("\",\n");
		} else {
			s.add("field: ");
			s.add(f.field);
			s.add(",\n");
		}
		s.add(getIndentation(tabs+1));
		s.add("expr: ");
		s.add(convertExprToString(f.expr, tabs+1));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}

	public static function convertVarToString(v:Var, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("Var(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: \"");
		s.add(v.name);
		s.add("\",\n");
		s.add(getIndentation(tabs+1));
		s.add("type: ");
		s.add(typeToString(v.type));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("expr: ");
		s.add(convertExprToString(v.expr, tabs+1));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}


	// AbstractType

	public static function convertAbstractTypeToString(a:AbstractType, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("AbstractType(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: ");
		s.add(a.name);
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("pack: [");
		s.add(a.pack.join(", "));
		s.add("],\n");
		s.add(getIndentation(tabs+1));
		s.add("isExtern: ");
		s.add(Std.string(a.isExtern));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("isPrivate: ");
		s.add(Std.string(a.isPrivate));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("from: ");
		s.add(convertToFromToString(a.from, tabs+1));
		//s.add(a.from.map(function(f) return convertTypePathToString(f)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("to: ");
		s.add(convertToFromToString(a.to, tabs+1));
		//s.add(",\n");
		/*s.add(getIndentation(tabs+1));
		s.add("params: ");
		s.add(a.params.map(function(p) return convertTypeParamToString(p)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("meta: ");
		s.add(a.meta.map(function(m) return convertMetaToString(m)).join(", "));
		s.add(",\n");*/
		//s.add(getIndentation(tabs+1));
		//s.add("fields: [");
		//var first = true;
		//for(f in a.fields()) {
		//	if(!first) {
		//		s.add(", ");
		//	}
		//	first = false;
		//	s.add(convertClassFieldToString(f, tabs+1));
		//}
		//s.add("],\n");
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");

		return s.toString();
	}

	public static function convertToFromToString(t:Array<{t:Type, field:Null<ClassField>}>, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("[");
		var first = true;
		for(t in t) {
			if(!first) {
				s.add(",\n");
				s.add(getIndentation(tabs+1));
			}
			first = false;

			//s.add("\n");
			//s.add(getIndentation(tabs+0));
			s.add("{\n");
				s.add(getIndentation(tabs+1));
				s.add("field: ");
				s.add(t.field == null ? "null" : t.field.name);
				s.add(",\n");
				s.add(getIndentation(tabs+1));
				s.add("t: ");
				s.add(convertTypeToString(t.t, tabs+1));
			s.add("\n");
			s.add(getIndentation(tabs+0));
			s.add("}");
		}
		s.add("]");

		return s.toString();
	}

	public static function convertEnumTypeToString(t:haxe.macro.Type.EnumType, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("EnumType(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: ");
		s.add(t.name);
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("pack: [");
		s.add(t.pack.join(", "));
		s.add("]\n");
		//s.add(getIndentation(tabs+1));
		//s.add("params: ");
		//s.add(t.params.map(function(p) return convertTypeParamToString(p)).join(", "));
		//s.add(",\n");
		//s.add(getIndentation(tabs));

		//s.add("meta: ");
		//s.add(t.meta.map(function(m) return convertMetaToString(m)).join(", "));
		//s.add(",\n");
		//s.add(getIndentation(tabs));
		//s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");
		return s.toString();
	}

	public static function convertClassTypeToString(t:haxe.macro.Type.ClassType, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("ClassType(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: ");
		s.add(t.name);
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("pack: [");
		s.add(t.pack.join(", "));
		s.add("]\n");
		/*s.add(getIndentation(tabs));
		s.add("params: ");
		s.add(t.params.map(function(p) return convertTypeParamToString(p)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs));
		s.add("meta: ");
		s.add(t.meta.map(function(m) return convertMetaToString(m)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs));
		s.add("\n");*/
		s.add(getIndentation(tabs));
		s.add(")");
		return s.toString();
	}

	public static function convertDefTypeToString(t:haxe.macro.Type.DefType, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("DefType(");
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add("name: ");
		s.add(t.name);
		s.add(",\n");
		s.add(getIndentation(tabs));
		s.add("pack: [");
		s.add(t.pack.join(", "));
		s.add("],\n");
		/*s.add(getIndentation(tabs));
		s.add("params: ");
		s.add(t.params.map(function(p) return convertTypeParamToString(p)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs));
		s.add("meta: ");
		s.add(t.meta.map(function(m) return convertMetaToString(m)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs));
		s.add("\n");*/
		s.add(getIndentation(tabs));
		s.add(")");
		return s.toString();
	}

	public static function convertFunctionTypeToString(t:Array<{name:String, opt:Bool, t:Type}>, ret:Type, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("TFun(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("args: [");
		var first = true;
		for(a in t) {
			if(!first) {
				s.add(", ");
			}
			first = false;
			s.add("{");
			s.add("\n");
			s.add(getIndentation(tabs+2));
			s.add("name: ");
			s.add(a.name);
			s.add(",\n");
			s.add(getIndentation(tabs+2));
			s.add("opt: ");
			s.add(Std.string(a.opt));
			s.add(",\n");
			s.add(getIndentation(tabs+2));
			s.add("t: ");
			s.add(convertTypeToString(a.t, tabs+2));
			s.add("\n");
			s.add(getIndentation(tabs+1));
			s.add("}");
		}
		s.add("],\n");
		s.add(getIndentation(tabs+1));
		s.add("ret: ");
		s.add(convertTypeToString(ret, tabs+1));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");
		return s.toString();
	}

	public static function convertAnonTypeToString(t:haxe.macro.Type.AnonType, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("AnonType(");
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add("fields: [");
		var first = true;
		for(f in t.fields) {
			if(!first) {
				s.add(", ");
			}
			first = false;
			s.add(convertClassFieldToString(f, tabs));
		}
		s.add("],\n");
		s.add(getIndentation(tabs));
		s.add(")");
		return s.toString();
	}

	public static function convertClassFieldToString(f:haxe.macro.Type.ClassField, tabs:Int = 0):String {
		var s = new StringBuf();
		s.add("ClassField(");
		s.add("\n");
		s.add(getIndentation(tabs+1));
		s.add("name: ");
		s.add(f.name);
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("type: ");
		s.add(convertTypeToString(f.type, tabs+1));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("isPublic: ");
		s.add(Std.string(f.isPublic));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("isExtern: ");
		s.add(Std.string(f.isExtern));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("isFinal: ");
		s.add(Std.string(f.isFinal));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("isAbstract: ");
		s.add(Std.string(f.isAbstract));
		s.add(",\n");
		/*s.add(getIndentation(tabs+1));
		s.add("params: ");
		s.add(f.params.map(function(p) return convertTypeParamToString(p)).join(", "));
		s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("meta: ");
		s.add(f.meta.map(function(m) return convertMetaToString(m)).join(", "));
		s.add(",\n");*/
		s.add(getIndentation(tabs+1));
		s.add("kind: ");
		s.add(Std.string(f.kind));
		s.add(",\n");
		//s.add(getIndentation(tabs+1));
		//s.add("expr: ");
		//s.add(convertExprToString(f.expr, tabs+1));
		//s.add(",\n");
		s.add(getIndentation(tabs+1));
		s.add("overloads: ");
		s.add(f.overloads.get().map(function(o) return convertClassFieldToString(o, tabs+1)).join(", "));
		s.add("\n");
		s.add(getIndentation(tabs));
		s.add(")");
		return s.toString();
	}

	public static function printableBaseType(t:haxe.macro.Type.BaseType):String {
		var name = t.name;
		if(t.pack != null && t.pack.length > 0) {
			name = t.pack.join(".") + "." + name;
		}

		if(t.params != null && t.params.length > 0) {
			name += "<" + t.params.map(function(p) return typeParameterToString(p)).join(", ") + ">";
		}

		trace(t);

		return name;
	}

	public static function printableClassType(t:ClassType):String {
		/*var name = t.name;
		if(t.pack.length > 0) {
			name = t.pack.join(".") + "." + name;
		}

		if(t.params != null && t.params.length > 0) {
			name += "<" + t.params.map(function(p) return typeToString(p)).join(", ") + ">";
		}*/

		return printableBaseType(t);
	}

	public static function typeParameterToString(t:TypeParameter):String {
		var name = t.name;
		//if(t.t != null) {
		//	name += "<" + printTypeOld(t.t) + ">";
		//}
		return name;
	}

	public static function printTypeOld(t:haxe.macro.Type.Type):String {
		if(t == null) return "null";
		var str = "";
		switch(t) {
			case TMono(t):
				str = printTypeOld(t.get());
			case TEnum(t, params):
				str = printableBaseType(t.get());
				if(params != null && params.length > 0) {
					str += "<" + params.map(printTypeOld).join(", ") + ">";
				}
			case TInst(t, params):
				str = printableClassType(t.get());
				if(params != null && params.length > 0) {
					str += "<" + params.map(printTypeOld).join(", ") + ">";
				}
			//case TExtend(t, params):
			//	str = printableBaseType(t.get());
			//	if(params != null && params.length > 0) {
			//		str += "<" + params.map(printTypeOld).join(", ") + ">";
			//	}
			case TType(t, params):
				str = printableBaseType(t.get());
				if(params != null && params.length > 0) {
					str += "<" + params.map(printTypeOld).join(", ") + ">";
				}
			case TFun(args, ret):
				str = args.map(function(a) return a.name).join(", ") + " -> " + printTypeOld(ret);
			case TAnonymous(a):
				str = a.get().fields.map(function(f) return f.name).join(", ");
			case TDynamic(t):
				str = "Dynamic";
			case TLazy(f):
				str = "Lazy";
			case TAbstract(t, params):
				str = printableBaseType(t.get()) + "<" + params.map(function(p) return printTypeOld(p)).join(", ") + ">";
		}
		return str;
	}

	public static function convertTypeToString(t:haxe.macro.Type.Type, tabs:Int = 0):String {
		var s = new StringBuf();
		switch(t) {
			case TMono(t):
				s.add("TMono(");
				s.add(convertTypeToString(t.get(), tabs));
				s.add(")");
			case TEnum(t, params):
				s.add("TEnum(");
				s.add(convertEnumTypeToString(t.get(), tabs));
				s.add(", [");
				var first = true;
				for(p in params) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertTypeToString(p, tabs));
				}
				s.add("])");
			case TInst(t, params):
				s.add(printableClassType(t.get()));
				//s.add("TInst(");
				//s.add(convertClassTypeToString(t.get(), tabs));
				//s.add(", [");
				//var first = true;
				//for(p in params) {
				//	if(!first) {
				//		s.add(",");
				//	}
				//	first = false;
				//	s.add(convertTypeToString(p, tabs));
				//}
				//s.add("])");
			case TType(t, params):
				s.add("TType(");
				s.add(convertDefTypeToString(t.get(), tabs));
				s.add(", [");
				var first = true;
				for(p in params) {
					if(!first) {
						s.add(",");
					}
					first = false;
					s.add(convertTypeToString(p, tabs));
				}
				s.add("])");
			case TFun(args, ret):
				s.add(convertFunctionTypeToString(args, ret, tabs));
			case TAnonymous(a):
				s.add("TAnonymous(");
				s.add(convertAnonTypeToString(a.get(), tabs));
				s.add(")");
			case TDynamic(t):
				s.add("TDynamic(");
				s.add(convertTypeToString(t, tabs));
				s.add(")");
			case TLazy(f):
				s.add("TLazy(");
				s.add(f);
				s.add(")");
			case TAbstract(t, params):
				s.add("TAbstract(\n");
				s.add(getIndentation(tabs+1));
				s.add(convertAbstractTypeToString(t.get(), tabs+1));
				s.add(",\n");
				s.add(getIndentation(tabs+1));
				s.add("[");
				var first = true;
				for(p in params) {
					if(!first) {
						s.add(",\n");
					}
					s.add(convertTypeToString(p, tabs+1));
					first = false;
				}
				s.add("]");
				s.add("\n");
				s.add(getIndentation(tabs));
				s.add(")");
		}
		return s.toString();
	}
}
#end