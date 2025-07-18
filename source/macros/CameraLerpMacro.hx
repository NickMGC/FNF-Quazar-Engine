package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class CameraLerpMacro {
	macro static public function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();

    	for (field in fields) {
			if (field.name != 'updateLerp') continue;

			switch (field.kind) {
          		case FFun(f):
            		f.expr = macro {
            			final mult:Float = 1 - Math.exp(-elapsed * followLerp);
						scroll.add((_scrollTarget.x - scroll.x) * mult, (_scrollTarget.y - scroll.y) * mult);
            		}
          		default:
        	}	
    	}

		return fields;
  	}
}
#end