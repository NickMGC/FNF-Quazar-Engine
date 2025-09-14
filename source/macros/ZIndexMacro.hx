package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class ZIndexMacro {
  	public static macro function build():Array<Field> { //Referenced from Funkin' crew
		return Context.getBuildFields().concat([{name: 'zIndex', access: [APublic], kind: FVar(macro:Int, macro $v{0}), pos: Context.currentPos()}]);
  	}
}
#end