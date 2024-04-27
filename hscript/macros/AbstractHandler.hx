package hscript.macros;

#if macro
import Type.ValueType;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Printer;
import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;

using StringTools;
using haxe.macro.PositionTools;

class AbstractHandler {
	public static inline final CLASS_SUFFIX = "_HSA";

	public static function init() {
		#if !display
		if(Context.defined("display")) return;
		//for(apply in Config.ALLOWED_ABSTRACT_AND_ENUM) {
			//}
		Compiler.addGlobalMetadata("", '@:build(hscript.macros.AbstractHandler.build())');

		//var module = cl.module + cl.name;
		#end
	}

	static var abstracts = new Map<String, {

	}>();

	/*static function finalizeAbstract(a:AbstractType) {
		var name = a.name;
		if(name.endsWith(CLASS_SUFFIX)) return; // !name.endsWith("_Impl_") ||
		if(name != "NodeListAccess") return;

		Sys.println("");
		Sys.println("");
		Sys.println("");
		Sys.println("");
		Sys.println("");

		//Sys.println("name: " + a.name);
		//Sys.println("module: " + a.module);

		Sys.println(MacroPrinter.convertAbstractTypeToString(a));

		//trace("buildAbstract", a);
	}*/

	static var currentSelf = "";

	/*static function oldTypeToString(t:Type, selfCheck:String = null):String {
		var str = switch(t) {
			case TInst(_.get() => t, params):
				var str = "";
				if(t.pack.length > 0) {
					str += t.pack.join(".") + ".";
				}
				str += t.name;
				if(t.params != null && t.params.length > 0) {
					str += "<" + t.params.map((v)->oldTypeToString(v.t, t.name + "." + v.name)).join(", ") + ">";
				}
				//if(t.params.length > 0) {
				//	throw "Params not supported yet " + t.name + " " + t.params;
				//}
				str;
			case TAbstract(_.get() => t, params):
				var str = "";
				if(t.pack.length > 0) {
					str += t.pack.join(".") + ".";
				}
				str += t.name;
				if(t.params != null && t.params.length > 0) {
					str += "<" + t.params.map((v)->oldTypeToString(v.t, t.name + "." + v.name)).join(", ") + ">";
				}
				//if(t.params.length > 0) {
				//	throw "Params not supported yet " + t.name + " " + t.params;
				//}
				str;
			case TEnum(_.get() => t, params):
				var str = "";
				if(t.pack.length > 0) {
					str += t.pack.join(".") + ".";
				}
				str += t.name;
				if(t.params != null && t.params.length > 0) {
					str += "<" + t.params.map((v)->oldTypeToString(v.t, t.name + "." + v.name)).join(", ") + ">";
				}
				//if(t.params.length > 0) {
				//	throw "Params not supported yet " + t.name + " " + t.params;
				//}
				str;
			case TType(_.get() => t, params):
				var str = "";
				if(t.pack.length > 0) {
					str += t.pack.join(".") + ".";
				}
				str += t.name;
				if(t.params != null && t.params.length > 0) {
					str += "<" + t.params.map((v)->oldTypeToString(v.t, t.name + "." + v.name)).join(", ") + ">";
					//trace("TType", str);
				}
				str;
			case TAnonymous(_.get() => t):
				//var str = "Dynamic {"+t.fields.map((f)->f.name).join(", ")+"}";
				//str += t.name;
				var str = "{ ";
				var first = true;
				for(f in t.fields) {
					if(!first) str += ", ";
					first = false;
					str += f.name + ":" + oldTypeToString(f.type);
				}
				str += " }";
				//trace("TAnonymous", str);
				str;
			case TDynamic(t):
				var str = "Dynamic";
				if(t != null) {
					str += "<" + oldTypeToString(t) + ">";
				}
				str;
			default:
				Sys.println("Unknown type " + Std.string(t));
				null;
		}

		if(selfCheck != null) {
			if(str == selfCheck) {
				return selfCheck;
				//return currentSelf;
			}
		}
		return str;
	}

	static function getResolvedType(t:ComplexType):String {
		if(t == null) return null;

		try {
			//var type = Context.getType(checkType);
			var paramFree = switch(t) {
				case TPath(t):
					//trace(t);
					TPath({
						name: t.name,
						pack: t.pack,
						params: t.params,
						sub: t.sub
					});
				case TAnonymous(a):
					t;
				case TFunction(args, ret):
					t;
				default:
					trace("");
					trace(ComplexTypeTools.toString(t));
					throw "Unknown type " + Std.string(t);
			}
			var type = ComplexTypeTools.toType(paramFree);
			var strType = oldTypeToString(type);
			if(strType != null) return strType;
		} catch(e:Dynamic) {
			Sys.println(e);
			Sys.println(ComplexTypeTools.toString(t));
			Sys.println(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		}

		return MacroPrinter.typeToString(t);
	}*/

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null) return fields;
		var cl = clRef.get();

		if(cl.isExtern) return fields;

		//if(cl.name != "Access_Impl_") return fields;
		//if(cl.name != "DrawQuadsView_Impl_") return fields;

		if(cl.name.endsWith("_Impl_") && !cl.name.endsWith(CLASS_SUFFIX)) // && ["Access_Impl_", "AttribAccess_Impl_"].contains(cl.name))
		{
			//if(!initialized) {
			//	initialized = true;
			//	Context.onAfterTyping(function(mods) {
			//		for(mod in mods) {
			//			switch(mod) {
			//				case TAbstract(_.get() => a):
			//					//trace("onAfterTyping", a);
			//					finalizeAbstract(a);
			//					//ab = a;
			//				default:
			//				//	return;
			//			}
			//		}
			//	});
			//}

			currentSelf = cl.name.substr(0, cl.name.length - "_Impl_".length);

			var funcInfos = [];
			//for(f in fields) {
			//	trace(f.name, f.kind);
			//}
			for(f in fields) {
				if(f.name.startsWith("__abstract_helper"))
					continue;
				//if(f.name != "escapes")
				//	continue;
				//trace(f);
				//trace(
				//MacroPrinter.convertFieldToString(f, cl.module + "." + cl.name)
				//);
				//trace();
				//continue;
				switch(f.kind) {
					case FFun(fun):
						if(fun.expr != null) {
							var obj:Dynamic = {
								name: f.name,
								args: [for(a in fun.args) {
									//name: a.name,
									//opt: a.opt,
									//type: MacroPrinter.typeToString(a.type),
									//value: a.value,
									//meta: a.meta,
									var arg = a.type == null ? "_" : MacroPrinter.typeToString(a.type);
									if(a.opt) {
										arg = "?" + arg;
									}
									arg;
								}].join("|"),
								ret: fun.ret,
								//access: f.access.map(function(a) return Std.string(a)).join(","),
								access: {
									var special = 0;
									var map:Array<Access> = [AStatic, APrivate, APublic, AOverride, AInline, ADynamic, AExtern, AStatic];
									for(a in f.access) {
										var index = map.indexOf(a);
										if(index == -1) {
											trace("Unknown access " + a);
											continue;
										}
										special |= 1 << index;
									}
									special;
								},
								special: {
									var special = 0;//{arrayAccess: false, arrayWrite: false};
									for(m in f.meta) {
										if(m.name == ":arrayAccess") {
											if(fun.args.length == 1) {
												special |= 1;
												//special.arrayAccess = true;
											} else if(fun.args.length == 2) {
												special |= 2;
												//special.arrayWrite = true;
											} else {
												trace(f.pos);
												throw "Unknown :arrayAccess meta " + fun.args;
											}
										} else if(m.name == ":from") {
											//throw "Unknown :from meta " + m;
											special |= 4;
										} else if(m.name == ":to") {
											//throw "Unknown :to meta " + m;
											special |= 8;
										} else if(m.name == ":op") {
											special |= 16;
										}
									}
									special;
								},
								op: {
									var op = null;
									//trace("");
									//trace("");
									//trace("");
									//trace(f.name, f.meta);
									//trace(f.name, fun);
									for(m in f.meta) {
										if(m.name == ":resolve") {
											if(f.access.contains(AStatic) && fun.args.length == 2) {
												op = "a.b";
											} else if(!f.access.contains(AStatic) && fun.args.length == 1) {
												op = "a.b";
											} else {
												throw "Unknown :resolve meta " + fun.args;
											}
										}
										if(m.name == ":op") {
											switch (m.params[0].expr) {
												case EField(_.expr => EConst(CIdent(_)), _):
													op = "a.b";
												case EArrayDecl([]):
													op = "[]";
												case EUnop(o, suffix, _.expr => EConst(CIdent(_))):
													var opStr = switch(o) {
														case OpNeg: "-";
														case OpIncrement: "++";
														case OpDecrement: "--";
														case OpNot: "!";
														case OpNegBits: "~";
														case OpSpread: "...";
													}
													if(suffix) {
														op = "a" + opStr;
													} else {
														op = opStr + "a";
													}
												case EBinop(o, _.expr => EConst(CIdent(_)), _.expr => EConst(CIdent(_))):
													var opStr = getBinopStr(o);
													op = "a " + opStr + " b";
												#if (haxe >= "4.3.0")
												case ECall(_.expr => EConst(CIdent(_)), []):
													op = "a()";
												#end
												default:
													trace(f.name, cl.module);
													throw "Unknown op " + MacroPrinter.convertExprToString(m.params[0]) + "\n in " + f.name + " in " + cl.module;
											}
											//trace(op, convertExprToString(m.params[0]));
											//trace(Type.typeof(m.params[0]));
											//switch (m.params[0].expr) {
											//	case EConst(CIdent(_i)):
											//		id = _i;
											//	default:
											//}
										}
									}
									op;
								}
							}

							if(obj.op == null) {
								Reflect.deleteField(obj, "op");
							}

							if(obj.ret == null && f.name.startsWith("get_")) {
								var v = getVarFromFields(fields, f.name.substr(4));
								var type = getTypeFromField(v);
								//Sys.println("getter " + f.name + " " + getResolvedType(type) + " " + type);
								obj.ret = type;
							} else if(obj.ret == null && f.name.startsWith("set_")) {
								var v = getVarFromFields(fields, f.name.substr(4));
								var type = getTypeFromField(v);
								//Sys.println("setter " + f.name + " " + getResolvedType(type) + " " + type);
								obj.ret = type;
							} else {
								if(obj.ret != null) {
									//Sys.println("normal field " + f.name + " " + getResolvedType(obj.ret) + " " + obj.ret);
								}
							}

							//if(obj.name == "_new")
							//	obj.name = "new";

							obj.ret = MacroPrinter.typeToString(obj.ret);

							//trace("FFun", obj);
							var save:Dynamic = null;
							if(true) {
								save = [obj.name, obj.args, obj.ret, obj.access, obj.special];
								if(obj.op != null) {
									save.push(obj.op);
								}
							} else {
								save = obj;
							}
							funcInfos.push(save);
							//trace(cl.name, obj);
						}
					default:
				}
				//funcInfos.push([f.name, ]);
			}

			//trace(funcInfos);

			//trace(cl.pos);

			var shadowClass = macro class {
				public static function abstract_funcs():Array<Array<Dynamic>> {
					return @:fixed $v{funcInfos};
				}
			}

			shadowClass.kind = TDClass(null, [
				//{name: "IHScriptAbstractHelper", pack: ["hscript"]},
				//{name: "IHScriptCustomClassBehaviour", pack: ["hscript"]}
			], false, true, false);
			shadowClass.name = '${cl.name.substr(0, cl.name.length - "_Impl_".length)}$CLASS_SUFFIX';
			//trace(shadowClass.name);
			var imports = Context.getLocalImports().copy();
			Utils.setupMetas(shadowClass, [], false);

			var moduleName = cl.module;
			Context.defineModule(moduleName, [shadowClass], imports);

			//var printer = new haxe.macro.Printer();
			//var code = printer.printTypeDefinition(shadowClass);
			//trace(code);


			return fields;
		}

		return fields;
	}

	static var initialized = false;

	static function getBinopStr(op:Binop):String {
		return switch(op) {
			case OpAdd: "+";
			case OpSub: "-";
			case OpMult: "*";
			case OpDiv: "/";
			case OpMod: "%";
			case OpEq: "==";
			case OpNotEq: "!=";
			case OpGt: ">";
			case OpGte: ">=";
			case OpLt: "<";
			case OpLte: "<=";
			case OpAnd: "&";
			case OpOr: "|";
			case OpXor: "^";
			case OpShl: "<<";
			case OpShr: ">>";
			case OpUShr: ">>>";
			case OpBoolAnd: "&&";
			case OpBoolOr: "||";
			case OpAssign: "=";
			case OpArrow: "=>";
			case OpAssignOp(op):
				getBinopStr(op) + "=";
			case OpIn: "in";
			case OpInterval: "...";
		}
	}

	static function getVarFromFields(fields:Array<Field>, name:String):Field {
		for(f in fields) {
			if(f.name == name) {
				switch(f.kind) {
					case FProp(_, _, _, _):
						return f;
					default:
				}
			}
		}
		return null;
	}

	static function getTypeFromField(field:Field):ComplexType {
		//if(field == null) return null;
		return switch(field.kind) {
			case FProp(_, _, t, _): t;
			case FVar(t, _): t;
			case FFun(f): f.ret;
			default: null;
		}
	}
}
#end