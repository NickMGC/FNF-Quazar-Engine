package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class DataAccessMacro {
	macro static public function get(value:Expr) {
        #if macro
		return macro backend.Settings.Data.$value;
        #end
  	}
}