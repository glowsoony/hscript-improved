package _hscript;

import _hscript.Expr;
import _hscript.Error;
import _hscript.Tools;
import _hscript.Parser;

enum AVarType {
	VUnknown;
	VVar(name:String, type:ADeclType);
}

typedef ATypeInfo = {
	impl: String,
	cl: Class<Any>,
	type: AType,
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
	public var inf:ATypeInfo;
	public var depth:Int;

	public function toString():String {
		return "type " + name + " : " + inf.type + " @ " + depth;
	}
}

typedef AbstractData = {
	var impl:String;
	var funcs:Array<Array<Dynamic>>;
	var props:Array<Array<String>>;
}

@:access(_hscript.Parser)
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
	private static var abstractData:Map<String, AbstractData>;
	private static var unusedImports:Map<String, String>;

	private static function addDeclared(e:String, type:AVarType = VUnknown) {
		declared.push({
			name: e,
			type: type,
			depth: depth
		});
	}

	private static function addTypeDeclared(e:String, inf:ATypeInfo) {
		declaredTypes.push({
			name: e,
			inf: inf,
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
				name: getFieldName(e),
				inf: abstr,
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
		unusedImports = new Map();
		storedTypes = [];

		var e = _process(e, true);

		// Remove data
		declared = null;
		declaredTypes = null;
		abstractData = null;
		unusedImports = null;
		storedTypes = null;

		e = removeMetaType(e);

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

	static function removeMetaType(e:Expr) {
		if(e == null)
			return null;
		switch(Tools.expr(e)) {
			case EMeta(":$type", [expr(_) => EConst(CInt(t))], e):
				return e;
			default:
		}
		return Tools.map(e, removeMetaType);
	}

	static function getAbstractImport(name:String, m:KImportMode = INormal):String {
		var typeInfo = resolveAbstract(name);
		if(typeInfo == null) return null;

		var fname = getFieldName(name);
		var varName = switch(m) {
			case IAs(a): a;
			default: fname;
		}
		addTypeDeclared(varName, typeInfo);
		trace("Adding abstract " + name + " as " + varName);

		return typeInfo.impl;
	}

	public static function loadAbstractData(name:String, ?type:Class<Any>) {
		if(abstractData.exists(name)) return abstractData.get(name);

		if(type == null) {
			var t = resolveClassAbstract(name);
			if(t == null) return null;
			type = t.cl;
			if(type == null) return null;
		}

		var data:AbstractData = {
			//var t:Dynamic = Type.createInstance(type, []);
			var t:Dynamic = type;
			{
				impl: t.__hx_impl__,
				funcs: t.abstract_funcs(),
				props: t.abstract_props()
			}
		};

		abstractData.set(name, data);
		abstractData.set(data.impl, data);
		trace("Loading abstract " + name + " as " + data);
		return data;
	}

	static function resolveAbstract(name:String, m:KImportMode = INormal) {
		var typeInfo = resolveClassAbstract(name);
		if(typeInfo == null) return null;

		//loadAbstractData(name, type);
		addImport(typeInfo.impl, m);
		typeInfo.type = TAbstract(typeInfo.cl, typeInfo.impl);
		return typeInfo;
	}

	static function resolveClassAbstract(name:String):ATypeInfo {
		var cl = Type.resolveClass(name + "_HSA");
		trace("Resolving " + name + "_HSA");
		if(cl == null) {
			var spr = name.split(".");
			if(spr.length < 2)
				return null;
			spr.splice(-2, 1); // remove the last last name;
			trace("Resolving " + spr.join(".") + "_HSA");
			cl = Type.resolveClass(spr.join(".") + "_HSA");
		}
		if(cl != null) {
			var cld:Dynamic = cl;
			return {
				impl: cld.__hx_impl__,
				cl: cl,
				type: null,
			}
		}
		return null;
	}

	static function findAbstractFromFieldName(name:String):AType {
		if(name.indexOf(".") == -1) {
			trace("Finding abstract from field name " + name + " " + unusedImports);
			if(unusedImports.exists(name)) {
				var fullName = unusedImports.get(name);
				addImport(getAbstractImport(fullName, INormal), INormal);
				unusedImports.remove(name);
				var v = resolveAbstract(fullName, INormal);
				if(v != null)
					return v.type;
			}
		}

		trace("Finding abstract from field name " + name);
		var v = resolveAbstract(name, INormal);
		if(v != null)
			return v.type;
		return null;
	}

	static function getFieldName(e:String) {
		var name = e.substr(e.lastIndexOf(".") + 1);
		return name;
	}

	private static var storedTypes:Array<AType>;

	static function setStoredType(type:AType):Int {
		var idx = storedTypes.indexOf(type);
		if(idx != -1) return idx;
		storedTypes.push(type);
		return storedTypes.length - 1;
	}

	static inline function getStoredType(idx:Int):AType {
		return storedTypes[idx];
	}

	static function wrapType(e:Expr, type:AType):Expr {
		return mk(EMeta(":$type", [mk(EConst(CInt(setStoredType(type))), e)], e), e);
	}

	private static function _process(e:Expr, top:Bool = false):Expr {
		if(e == null)
			return null;

		// If stuff looks wrong, add this back
		//e = Tools.map(e, function(e) {
		//	return _process(e, false);
		//});

		e = endProcess(e);

		if(e == null) return null;

		var ge = e;

		switch(expr(e)) {
			case EVar(vname, t, e, p, s):
				var type = null;
				switch(Tools.expr(e)) {
					case ENew(n, _):
						type = n;
					case EIdent(n): // i dont think this worksc
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
					if(v != null) {
						addDeclared(vname, VVar(vname, v));
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
						if(type == null) return endProcess(ge);

						var stype = t != null ? Printer.convertTypeToString(t) : null;
						trace("New " + n + " " + stype);

						switch(type.inf.type) {
							case TAbstract(at, impl):
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
			case EField(e, f, p):
				var typeInfo = switch(Tools.expr(e)) {
					case EIdent(n):
						var a = getDeclared(n);
						if(a != null) {
							switch(a.type) {
								case VVar(name, type): type.inf.type;
								default: null;
							}
						} else {
							null;
						}
					case EMeta(":$type", [expr(_) => EConst(CInt(t))], _):
						getStoredType(t);
					default:
						null;
				}
				if(typeInfo == null) return endProcess(ge);
				trace("EField " + e + " " + f);
				trace("Type: " + typeInfo);

				var e = switch(typeInfo) {
					case TAbstract(at, impl):
						var helper:AbstractDataHelper = new AbstractDataHelper(impl, at);

						var resolve = helper.getResolveFunc();
						trace("Resolve func: " + resolve);
						if(resolve != null) { // a.b -> a.resolve(b);
							var returnType = helper.getTypeOfFunc(resolve);
							var retType = findAbstractFromFieldName(returnType);
							trace("Expr: " + Printer.toString(e));

							var field = mk(EField(mk(EIdent(getFieldName(impl)), e), resolve, p), e);
							var call = mk(ECall(field, [e, mk(EConst(CString(f)), e)]), e);

							if(retType != null) {
								call = wrapType(call, retType);
							}
							return endProcess(call);
						}

						// access.has -> Access_Impl_.get_has()
						var v = helper.getProps(f);
						if(v != null) // get
						{
							var getterType = helper.getTypeOfFunc(v[0]);
							if(getterType != null) {
								trace("Getter: " + getterType);
								trace("v:" + v);

								var retType = findAbstractFromFieldName(getterType);

								var field = mk(EField(mk(EIdent(getFieldName(impl)), e), v[0], p), e);
								var call = mk(ECall(field, [e]), e);
								var meta = wrapType(call, retType);

								trace("Expr: " + Printer.toString(meta));
								endProcess(meta);
							} else {
								null;
							}
						}
						else
							null;
					default: null;
				}

				if(e != null)
					return e;
			case EImport(n, m):
				var abstractImport = getAbstractImport(n, m);
				if(abstractImport != null) {
					addImport(abstractImport, m);
					if(n == "haxe.xml.Access") {
						var toImport = [
							"haxe.xml.Access.NodeAccess",
							"haxe.xml.Access.AttribAccess",
							"haxe.xml.Access.HasAttribAccess",
							"haxe.xml.Access.HasNodeAccess",
							"haxe.xml.Access.NodeListAccess",
						];
						for(n in toImport) {
							//var m = INormal;//IAs("$" + n);
							//addImport(getAbstractImport(n, m), m);
							unusedImports.set(getFieldName(n), n);
						}
					}
					return null;//mk(abstractImport, e);
				}
			default:
		}

		return (e);
	}

	static function endProcess(e:Expr):Expr {
		if(e == null) return null;
		var ge = e;
		return Tools.map(e, function(e) {
			if(e == null) return mk(EBlock([]), ge); // Hacky
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

	public function getProps(fieldName:String):Array<String> {
		var prop = data.props;
		for(v in prop) {
			if(v[0] == fieldName) {
				return [v[1], v[2]];
			}
		}
		return null;
	}

	public function getResolveFunc(?wantedType:Null<String>):String {
		var t = getFuncForOp("a.b", wantedType);
		if(t != null) return t;
		return null;
	}

	public function getTypeOfFunc(f:String):String {
		var funcs = data.funcs;
		for(func in funcs) {
			if(func[0] == f) {
				return func[2];
			}
		}
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
						if(types.length != wtypes.length) continue;
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
					if(types.length != wtypes.length) continue;
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
					if(types.length != wtypes.length) continue;
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
					if(types.length != wtypes.length) continue;
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