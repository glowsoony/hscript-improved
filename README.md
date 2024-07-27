hscript-improved
=======

How to install
```
haxelib git hscript-improved https://github.com/glowsoony/hscript-improved.git
```

To enable custom classes support you have to do this in project.xml
```xml
<define name="CUSTOM_CLASSES" />
```
Warning: custom classes are sometimes broken, would like help to fix them. You can only override functions from the current class, not from the extended part, like you cant override update in FlxText because FlxText doesnt have a update function overriden

-----------

Parse and evalutate Haxe expressions.


In some projects it's sometimes useful to be able to interpret some code dynamically, without recompilation.

Haxe script is a complete subset of the Haxe language.

It is dynamically typed but allows all Haxe expressions apart from type (class,enum,typedef) declarations.

Usage
-----

```haxe
var expr = "var x = 4; 1 + 2 * x";
var parser = new _hscript.Parser();
var ast = parser.parseString(expr);
var interp = new _hscript.Interp();
trace(interp.execute(ast));
```

In case of a parsing error an `_hscript.Expr.Error` is thrown. You can use `parser.line` to check the line number.

You can set some globaly accessible identifiers by using `interp.variables.set("name",value)`

Example
-------

Here's a small example of Haxe Script usage :
```haxe
var script = "
	var sum = 0;
	for( a in angles )
		sum += Math.cos(a);
	sum; 
";
var parser = new _hscript.Parser();
var program = parser.parseString(script);
var interp = new _hscript.Interp();
interp.variables.set("Math",Math); // share the Math class
interp.variables.set("angles",[0,1,2,3]); // set the angles list
trace( interp.execute(program) ); 
```

This will calculate the sum of the cosines of the angles given as input.

Haxe Script has not been really optimized, and it's not meant to be very fast. But it's entirely crossplatform since it's pure Haxe code (it doesn't use any platform-specific API).

Advanced Usage
--------------

When compiled with `-D hscriptPos` you will get fine error reporting at parsing time.

You can subclass `_hscript.Interp` to override behaviors for `get`, `set`, `call`, `fcall` and `cnew`.

You can add more binary and unary operations to the parser by setting `opPriority`, `opRightAssoc` and `unops` content.

You can use `parser.allowJSON` to allow JSON data.

You can use `parser.allowTypes` to parse types for local vars, exceptions, function args and return types. Types are ignored by the interpreter.

You can use `parser.allowMetadata` to parse metadata before expressions on in anonymous types. Metadata are ignored by the interpreter.

You can use `new _hscript.Macro(pos).convert(ast)` to convert an _hscript AST to a Haxe macros one.

You can use `_hscript.Checker` in order to type check and even get completion, using `haxe -xml` output for type information.

Limitations
-----------

Compared to Haxe, limitations are :

- `switch` construct is supported but not pattern matching (no variable capture, we use strict equality to compare `case` values and `switch` value)
- only one variable declaration is allowed in `var`
- the parser supports optional types for `var` and `function` if `allowTypes` is set, but the interpreter ignores them
- you can enable per-expression position tracking by compiling with `-D hscriptPos`
- you can parse some type declarations (import, class, typedef, etc.) with parseModule

Install
-------

In order to install Haxe Script, use `haxelib install _hscript` and compile your program with `-lib _hscript`.

These are the main required files in _hscript :

  - `_hscript.Expr` : contains enums declarations
  - `_hscript.Parser` : a small parser that turns a string into an expression structure (AST)
  - `_hscript.Interp` : a small interpreter that execute the AST and returns the latest evaluated value

Some other optional files :
  
  - `_hscript.Async` : converts Expr into asynchronous version
  - `_hscript.Bytes` : Expr serializer/unserializer
  - `_hscript.Checker` : type checking and completion for _hscript Expr
  - `_hscript.Macro` : convert Haxe macro into _hscript Expr
  - `_hscript.Printer` : convert _hscript Expr to String
  - `_hscript.Tools` : utility functions (map/iter)
 
