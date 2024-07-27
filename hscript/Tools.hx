/*
 * Copyright (C)2008-2017 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package _hscript;
import _hscript.Expr;
import _hscript.utils.UnsafeReflect;

class Tools {

	public static function iter( e : Expr, f : Expr -> Void ) {
		switch( expr(e) ) {
		case EConst(_), EIdent(_):
		case EImport(c, _): f(e);
		case EClass(_, e, _, _): for( a in e ) f(a);
		case EVar(_, _, e): if( e != null ) f(e);
		case EParent(e): f(e);
		case EBlock(el): for( e in el ) f(e);
		case EField(e, _): f(e);
		case EBinop(_, e1, e2): f(e1); f(e2);
		case EUnop(_, _, e): f(e);
		case ECall(e, args): f(e); for( a in args ) f(a);
		case EIf(c, e1, e2): f(c); f(e1); if( e2 != null ) f(e2);
		case EWhile(c, e): f(c); f(e);
		case EDoWhile(c, e): f(c); f(e);
		case EFor(_, it, e): f(it); f(e);
		case EForKeyValue(_, it, e, _): f(it); f(e);
		case EBreak,EContinue:
		case EFunction(_, e, _, _): f(e);
		case EReturn(e): if( e != null ) f(e);
		case EArray(e, i): f(e); f(i);
		case EMapDecl(type, keys, values): for( e in keys ) f(e); for( e in values ) f(e);
		case EArrayDecl(el): for( e in el ) f(e);
		case ENew(_,el): for( e in el ) f(e);
		case EThrow(e): f(e);
		case ETry(e, _, _, c): f(e); f(c);
		case EObject(fl): for( fi in fl ) f(fi.e);
		case ETernary(c, e1, e2): f(c); f(e1); f(e2);
		case ESwitch(e, cases, def):
			f(e);
			for( c in cases ) {
				for( v in c.values ) f(v);
				f(c.expr);
			}
			if( def != null ) f(def);
		case EMeta(name, args, e): if( args != null ) for( a in args ) f(a); f(e);
		case ECheckType(e,_): f(e);

		}
	}

	public static function map( e : Expr, f : Expr -> Expr ) {
		var edef = switch( expr(e) ) {
		case EConst(_), EIdent(_), EBreak, EContinue: expr(e);
		case EVar(n, t, e, p, s): EVar(n, t, if( e != null ) f(e) else null, p, s);
		case EParent(e, no): EParent(f(e), no);
		case EBlock(el): EBlock([for( e in el ) f(e)]);
		case EField(e, fi, s): EField(f(e),fi,s);
		case EBinop(op, e1, e2): EBinop(op, f(e1), f(e2));
		case EUnop(op, pre, e): EUnop(op, pre, f(e));
		case ECall(e, args): ECall(f(e),[for( a in args ) f(a)]);
		case EIf(c, e1, e2): EIf(f(c),f(e1),if( e2 != null ) f(e2) else null);
		case EWhile(c, e): EWhile(f(c),f(e));
		case EDoWhile(c, e): EDoWhile(f(c),f(e));
		case EFor(v, it, e): EFor(v, f(it), f(e));
		case EForKeyValue(v, it, e, ithv): EForKeyValue(v, f(it), f(e), ithv);
		case EFunction(args, e, name, t, p, s, o): EFunction(args, f(e), name, t, p, s, o);
		case EReturn(e): EReturn(if( e != null ) f(e) else null);
		case EArray(e, i): EArray(f(e),f(i));
		case EMapDecl(type, keys, values): EMapDecl(type, [for( e in keys ) f(e)], [for( e in values ) f(e)]);
		case EArrayDecl(el): EArrayDecl([for( e in el ) f(e)]);
		case ENew(cl,el): ENew(cl,[for( e in el ) f(e)]);
		case EThrow(e): EThrow(f(e));
		case ETry(e, v, t, c): ETry(f(e), v, t, f(c));
		case EObject(fl): EObject([for( fi in fl ) new ObjectField(fi.name, f(fi.e))]);
		case ETernary(c, e1, e2): ETernary(f(c), f(e1), f(e2));
		case ESwitch(e, cases, def): ESwitch(f(e), [for( c in cases ) new SwitchCase([for( v in c.values ) f(v)], f(c.expr))], def == null ? null : f(def));
		case EMeta(name, args, e): EMeta(name, args == null ? null : [for( a in args ) f(a)], f(e));
		case ECheckType(e,t): ECheckType(f(e), t);
		case EImport(c, m): EImport(c, m);
		case EClass(name, el, extend, interfaces): EClass(name, [for( e in el ) f(e)], extend, interfaces);
		}
		return mk(edef, e);
	}

	public static inline function expr( e : Expr ) : ExprDef {
		#if hscriptPos
		return e.e;
		#else
		return e;
		#end
	}

	public static inline function cleanError( e : Error ) {
		#if hscriptPos
		return e.e;
		#else
		return e;
		#end
	}

	public static inline function mk( e : ExprDef, p : Expr ):Expr {
		#if hscriptPos
		return new Expr(e, p.pmin, p.pmax, p.origin, p.line);
		#else
		return e;
		#end
	}

	public static function isValidBinOp(op:String):Bool {
		if(op == ("??"+"=")) return true;
		return switch(op) {
			case "+" | "-" | "*" | "/" | "%" | "&" | "|" | "^" | "<<" | ">>" | ">>>" | "==" | "!=" | ">=" | "<=" | ">" | "<" | "||" | "&&" | "is" | "=" | "??" | "..." | "+=" | "-=" | "*=" | "/=" | "%=" | "&=" | "|=" | "^=" | "<<=" | ">>=" | ">>>=": true;
			case "=>": true;
			default: false;
		}
	}

	static var priorities = [
		["%"],
		["*", "/"],
		["+", "-"],
		["<<", ">>", ">>>"],
		["|", "&", "^"],
		["==", "!=", ">", "<", ">=", "<="],
		["..."],
		["&&"],
		["||"],
		["=","+=","-=","*=","/=","%=","<<=",">>=",">>>=","|=","&=","^=","=>","??"+"="],
		["->", "??"],
		["is"]
	];
	public static function checkOpPrecedence(mainOp:String, leftOp:String, rightOp:String):Int {
		var mainOpGroup = getOpGroup(mainOp);
		var leftOpGroup = getOpGroup(leftOp);
		var rightOpGroup = getOpGroup(rightOp);

		var leftParam = false;
		var rightParam = false;

		if(leftOpGroup > mainOpGroup && leftOpGroup != -1) leftParam = true;
		if(rightOpGroup > mainOpGroup && rightOpGroup != -1) rightParam = true;

		if(!leftParam && !rightParam) {
			var mainOpIndex = getOpIndex(mainOp);
			var leftOpIndex = getOpIndex(leftOp);
			var rightOpIndex = getOpIndex(rightOp);

			if(mainOpGroup == rightOpGroup) {
				if(rightOpIndex < mainOpIndex) rightParam = true;
			}
			if(leftOpGroup == mainOpGroup) {
				if(leftOpIndex < mainOpIndex) leftParam = true;
			}
		}

		// Convert to index
		if(!leftParam && !rightParam) return -1;
		if(leftParam && rightParam) return 2;
		if(leftParam) return 0;
		if(rightParam) return 1;
		return -1;
	}

	public static function getOpIndex(op:String):Int {
		if(op == "_") return -1;
		var i = 0;
		for(p in priorities) {
			for(pp in p) {
				if(op == pp)
					return i;
				i++;
			}
		}
		return -1;
	}

	public static function getOpGroup(op:String):Int {
		if(op == "_") return -1;
		var i = 0;
		for(p in priorities) {
			for(pp in p) {
				if(op == pp)
					return i;
			}
			i++;
		}
		return -1;
	}


	public static function getEnum(cl:Enum<Dynamic>):Dynamic {
		var enumThingy:Dynamic = {};
		for (c in cl.getConstructors()) {
			try {
				UnsafeReflect.setField(enumThingy, c, cl.createByName(c));
			} catch(e) {
				try {
					UnsafeReflect.setField(enumThingy, c, Reflect.makeVarArgs((args:Array<Dynamic>) -> cl.createByName(c, args)));
				} catch(ex) {
					throw e;
				}
			}
		}
		return enumThingy;
	}
}