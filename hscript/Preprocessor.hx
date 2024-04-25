package hscript;

import hscript.Expr;
import hscript.Error;
import hscript.Tools;
import hscript.Parser;

@:access(hscript.Parser)
class Preprocessor {
	static inline function expr(e:Expr) return Tools.expr(e);

	/**
	 * Preprocesses the expression, like 'a'.code => 97
	 * Also for transforming any abstracts into their implementations (TODO)
	 * Also for transforming any static extensions into their real form (TODO)
	**/
	public static function process(e:Expr, doBlock:Bool = true):Expr {
		if(e == null)
			return null;

		trace(expr(e));

		e = Tools.map(e, function(e) {
			return process(e);
		});

		switch(expr(e)) {
			case EField(expr(_) => EConst(CString(s)), "code", _): // Transform string.code into charCode
				if(s.length != 1) {
					throw Parser.getBaseError(EPreset(INVALID_CHAR_CODE_MULTI));
				}
				return mk(EConst(CInt(s.charCodeAt(0))), e);
			case ECall(expr(_) => EField(expr(_) => EIdent("String"), "fromCharCode", _), [e]):
				switch(expr(e)) {
					case EConst(CInt(i)):
						return mk(EConst(CString(String.fromCharCode(i))), e);
					default:
						// __StringWorkaround__fromCharCode(i);
						#if !NO_FROM_CHAR_CODE_FIX
						return mk(ECall(mk(EIdent("__StringWorkaround__fromCharCode"), e), [e]), e);
						#else
						throw Parser.getBaseError(EPreset(FROM_CHAR_CODE_NON_INT));
						#end
				}
			default:
		}

		return e;
	}

	static function mk(e:ExprDef, s:Expr):Expr {
		#if hscriptPos
		return new Expr(e, s.pmin, s.pmax, s.origin, s.line);
		#else
		return e;
		#end
	}
}