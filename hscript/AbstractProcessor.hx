package hscript;

import hscript.Expr;
import hscript.Error;
import hscript.Tools;
import hscript.Parser;

enum AVarType {
	VUnknown;
	VVar(name:String, type:Null<String>);
}

enum AType {
	TUnknown;
	TBasic(name:String);
	TAbstract(type:Class<Any>, impl:String);
}

@:structInit
class ADeclVar {
	public var name:String;
	public var type:AVarType;
	public var depth:Int;

	public function toString():String {
		return "var " + name + " : " + type + " @ " + depth;
	}
}

@:structInit
class ADeclType {
	public var name:String;
	public var type:AType;
	public var depth:Int;

	public function toString():String {
		return "type " + name + " : " + type + " @ " + depth;
	}
}

typedef AbstractData = {
	var funcs:Array<Array<Dynamic>>;
}

@:access(hscript.Parser)
class AbstractProcessor {
	static inline function expr(e:Expr) return Tools.expr(e);

	private static var importStackName:Array<String> = [];
	private static var importStackMode:Array<KImportMode> = [];
	private static function addImport(e:String, mode:KImportMode = INormal) {
		for(i in importStackName) if(i == e) return;
		importStackName.push(e);
		importStackMode.push(mode);
	}

	private static function popImport(e:Expr) {
		return mk(EImport(importStackName.pop(), importStackMode.pop()), e);
	}

	private static var depth:Int = 0;
	private static var declared:Array<ADeclVar>;
	private static var declaredTypes:Array<ADeclType>;
	private static var abstractData:Map<String, AbstractData> = [];

	private static function addDeclared(e:String, type:AVarType = VUnknown) {
		declared.push({
			name: e,
			type: type,
			depth: depth
		});
	}

	private static function addTypeDeclared(e:String, type:AType) {
		declaredTypes.push({
			name: e,
			type: type,
			depth: depth
		});
	}

	private static function getDeclared(e:String):ADeclVar {
		var len = declared.length;
		for(i in 0...len) {
			var idx = len - i - 1;
			var v = declared[idx];
			if(v.name == e) {
				return v;
			}
		}
		return null;
	}

	public static function getDeclaredType(e:String):ADeclType {
		var len = declaredTypes.length;
		for(i in 0...len) {
			var idx = len - i - 1;
			var v = declaredTypes[idx];
			if(v.name == e) {
				return v;
			}
		}
		var abstr = resolveAbstract(e);
		if(abstr != null) {
			return {
				name: e.substr(e.lastIndexOf(".") + 1),
				type: abstr,
				depth: depth
			}
		}
		return null;
	}

	static function removeUnusedDeclared() {
		while(declared.length > 0 && declared[declared.length - 1].depth > depth) {
			declared.pop();
		}
		while(declaredTypes.length > 0 && declaredTypes[declaredTypes.length - 1].depth > depth) {
			declaredTypes.pop();
		}
	}

	public static function process(e:Expr):Expr {
		importStackName = [];
		importStackMode = [];
		depth = 0;
		declared = new Array();
		declaredTypes = new Array();
		abstractData = new Map();

		var e = _process(e, true);

		// Remove data
		declared = null;
		declaredTypes = null;
		abstractData = null;

		// Automatically add imports for stuff
		switch(expr(e)) {
			case EBlock(exprs):
				while(importStackName.length > 0) {
					exprs.unshift(popImport(e));
				}
				return mk(EBlock(exprs), e);
			default:
				if(importStackName.length > 0) {
					var exprs = [];
					while(importStackName.length > 0) {
						exprs.unshift(popImport(e));
					}
					exprs.push(e);
					return mk(EBlock(exprs), e);
				}
		}
		return e;
	}

	static function getAbstractImport(name:String, m:KImportMode = INormal):String {
		var type = resolveAbstract(name);
		if(type == null) return null;

		var fname = name.substr(name.lastIndexOf(".") + 1);
		var varName = switch(m) {
			case IAs(a): a;
			default: fname;
		}
		addTypeDeclared(varName, type);
		trace("Adding abstract " + name + " as " + varName);

		var module = formatAbstractImport(name);
		return module;
	}

	static function formatAbstractImport(name:String):String {
		var fname = name.substr(name.lastIndexOf(".") + 1);

		// haxe.xml.Access -> haxe.xml._Access.Access_Impl_
		var module = name.substr(0, name.length - fname.length) + "_" + fname + "." + fname + "_Impl_";
		trace(module);
		return module;
	}

	public static function loadAbstractData(name:String, ?type:Class<Any>) {
		if(abstractData.exists(name)) return abstractData.get(name);

		if(type == null) {
			type = resolveClassAbstract(name);
			if(type == null) return null;
		}

		var data = {
			//var t:Dynamic = Type.createInstance(type, []);
			var t:Dynamic = type;
			{
				funcs: t.abstract_funcs()
			}
		};

		abstractData.set(name, data);
		trace("Loading abstract " + name + " as " + data);
		return data;
	}

	static function resolveAbstract(name:String, m:KImportMode = INormal):AType {
		var type = resolveClassAbstract(name);
		if(type == null) return null;

		//loadAbstractData(name, type);
		var impl = formatAbstractImport(name);
		addImport(impl, m);
		return TAbstract(type, impl);
	}

	static function resolveClassAbstract(name:String) {
		return Type.resolveClass(name + "_HSA");
	}

	static function getFieldName(e:String) {
		var name = e.substr(e.lastIndexOf(".") + 1);
		return name;
	}

	private static function _process(e:Expr, top:Bool = false):Expr {
		if(e == null)
			return null;

		// If stuff looks wrong, add this back
		//e = Tools.map(e, function(e) {
		//	return _process(e, false);
		//});

		//trace(expr(e));

		var ge = e;

		switch(expr(e)) {
			case EVar(vname, t, e, p, s):
				var type = null;
				switch(Tools.expr(e)) {
					case ENew(n, _):
						type = n;
					case EIdent(n):
						// var a = Abstract;
						// var b = a; // Gets detected
						type = getDeclaredType(n).name;
					default:
				}

				if(t != null) {
					type = Printer.convertTypeToString(t);
				}

				if(type != null) {
					var v = getDeclaredType(type);
					trace(v);
					if(v != null) {
						addDeclared(vname, VVar(vname, v.name));
						trace("Adding var " + vname + " with type " + v.name);
						//return mk(EField(mk(EIdent(v.name), e), "new", p), e);
					}
				} else {
					trace("No type for " + vname + " " + t);
					addDeclared(vname, VUnknown);
				}

				// TODO: make this not be only inside EVar
				var e = switch(Tools.expr(e)) {
					case ENew(n, args):
						var type = getDeclaredType(n);
						if(type == null) return endProcess(e);

						var stype = t != null ? Printer.convertTypeToString(t) : null;
						trace("New " + n + " " + stype);

						switch(type) {
							case _.type => TAbstract(at, impl):
								var helper:AbstractDataHelper = new AbstractDataHelper(type.name, at);
								var constructor = helper.getFuncForConstructor();
								trace("Converting new call to " + constructor);
								_process(mk(
									ECall(
										mk(
											EField(
												mk(
													EIdent(getFieldName(impl)),
													e
												),
											constructor),
										e), args
									), e
								));
							default: null;
						}
					default: null;
				};
				if(e != null)
					return mk(EVar(vname, t, e, p, s), ge);
			//case EField(e, f, p):
			//	var type = getDeclaredType(e);
			//	if(type == null) return endProcess(e);

				//switch(type) {
				//	case _.type => TAbstract(at, impl):
				//		var helper:AbstractDataHelper = new AbstractDataHelper(type.name, at);
				//		var constructor = helper.getFuncForConstructor();
				//		trace("Converting new call to " + constructor);
				//		return mk(
				//			ECall(
				//				mk(
				//					EField(
				//						mk(
				//							EIdent(getFieldName(impl)),
				//							e
				//						),
				//					constructor),
				//				e), args
				//			), e
				//		);
				//	default: null;
				//}
			case EImport(n, m):
				var abstractImport = getAbstractImport(n, m);
				if(abstractImport != null) {
					addImport(abstractImport, m);
					return null;//mk(abstractImport, e);
				}
			default:
		}

		return endProcess(e);
	}

	static function endProcess(e:Expr):Expr {
		return Tools.map(e, function(e) {
			switch(Tools.expr(e)) {
				case EBlock(exprs):
					depth++;
					for(i in 0...exprs.length) {
						exprs[i] = _process(exprs[i]);
					}
					while(exprs.contains(null)) exprs.remove(null);
					depth--;
					removeUnusedDeclared();
					return mk(EBlock(exprs), e);
				case EFunction(args, expr, name, a, isPublic, isStatic, isOverride):
					depth++;
					_process(expr);
					//for(i in 0...expr.length) {
					//	expr[i] = _process(expr[i]);
					//}
					depth--;
					removeUnusedDeclared();
					return mk(EFunction(args, expr, name, a, isPublic, isStatic, isOverride), e);
				default:
			}
			return _process(e);
		});
	}

	static function mk(e:ExprDef, s:Expr):Expr {
		#if hscriptPos
		return new Expr(e, s.pmin, s.pmax, s.origin, s.line);
		#else
		return e;
		#end
	}

	public static var isStringFromCharCodeFixed(get, null):Null<Bool> = null;
	static function get_isStringFromCharCodeFixed():Null<Bool> {
		if(isStringFromCharCodeFixed == null) {
			try {
				Reflect.callMethod(null, Reflect.field(String, "fromCharCode"), [65]);
				isStringFromCharCodeFixed = true;
			} catch(e:Dynamic) {
				isStringFromCharCodeFixed = false;
			}
		}
		return isStringFromCharCodeFixed;
	}
}

class AbstractDataHelper {
	public var data:AbstractData;

	public function new(name:String, ?cls: Class<Any>) {
		data = AbstractProcessor.loadAbstractData(name, cls);
	}

	// [name, args, ret, access, special, ?op]

	public function getResolveFunc(?wantedType:Null<String>):String {
		var t = getFuncForOp("a.b", wantedType);
		if(t != null) return t;
		return null;
	}

	public function getFuncForOp(op:String, ?wantedType:Null<String>):String {
		var funcs = data.funcs;
		for(func in funcs) {
			if(func[4] & 16 != 0) {
				if(func[5] == op) {
					if(wantedType != null) {
						var types:Array<String> = func[1].split("|");
						var wtypes:Array<String> = wantedType.split("|");
						var didBreak = false;
						for(i=>type in types) {
							if(type != wtypes[i]) {
								didBreak = true;
								break;
							}
						}
						if(didBreak) {
							continue;
						}
					}
					return func[0];
				}
			}
		}
		return null;
	}

	public function getFuncForArrayRead(?wantedType:Null<String>):String {
		var funcs = data.funcs;
		for(func in funcs) {
			if(func[4] & 1 != 0) {
				if(wantedType != null) {
					var types:Array<String> = func[1].split("|");
					var wtypes:Array<String> = wantedType.split("|");
					var didBreak = false;
					for(i=>type in types) {
						if(type != wtypes[i]) {
							didBreak = true;
							break;
						}
					}
					if(didBreak) {
						continue;
					}
				}
				return func[0];
			}
		}
		return null;
	}

	public function getFuncForArrayWrite(?wantedType:Null<String>):String {
		var funcs = data.funcs;
		for(func in funcs) {
			if(func[4] & 2 != 0) {
				if(wantedType != null) {
					var types:Array<String> = func[1].split("|");
					var wtypes:Array<String> = wantedType.split("|");
					var didBreak = false;
					for(i=>type in types) {
						if(type != wtypes[i]) {
							didBreak = true;
							break;
						}
					}
					if(didBreak) {
						continue;
					}
				}
				return func[0];
			}
		}
		return null;
	}

	public function getFuncForConstructor(?wantedType:Null<String>):String {
		var funcs = data.funcs;
		for(func in funcs) {
			if(func[4] & 4 != 0) {
				if(wantedType != null) {
					var types:Array<String> = func[1].split("|");
					var wtypes:Array<String> = wantedType.split("|");
					var didBreak = false;
					for(i=>type in types) {
						if(type != wtypes[i]) {
							didBreak = true;
							break;
						}
					}
					if(didBreak) {
						continue;
					}
				}
				return func[0];
			}
		}
		for(func in funcs) {
			if(func[0] == "_new")
				return func[0];
		}
		return null;
	}

	public function getFuncForToConversion(?wantedType:Null<String>):Array<Dynamic> {
		var funcs = data.funcs;
		for(func in funcs) {
			if(func[4] & 8 != 0) {
				if(wantedType != null) {
					var types = func[2];
					var wtypes = wantedType;
					if(types != wantedType)
						continue;
				}
				return func[0];
			}
		}
		return null;
	}
}