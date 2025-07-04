package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class StageMacro {
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();
        var key:String;

        if (!Context.unify(Context.getLocalType(), Context.getType('objects.BaseStage'))) {
            Context.error('Class ${localClass.name} must extend objects.BaseStage to use the @stage macro.', Context.currentPos());
            return fields;
        }

        var stageMeta:MetadataEntry;
        for (meta in localClass.meta.get()) if (meta.name == 'stage') stageMeta = meta;

        if (stageMeta == null) {
            Context.warning('${ localClass.name} doesnt have an "@stage" metadata, it will not be registered by the stage map.', Context.currentPos());
            return fields;
        }

        if (stageMeta.params.length < 1) {
            Context.error("You must declare a value", stageMeta.pos);
            return fields; 
        }

        if (stageMeta.params.length > 1) {
            Context.error("Stage key must have one value only", stageMeta.pos);
            return fields; 
        }

        if (stageMeta.params.length != 1) {
            key = localClass.name;
        }

        switch stageMeta.params[0].expr {
            case EConst(CString(s)): key = s;
            case _:
                Context.error("Stage key must be a string literal", stageMeta.params[0].pos);
                return fields;
        }

        fields.push({
            name: "_initStage_",
            access: [AStatic, APrivate],
            kind: FVar(macro:Bool, macro {
                Stage.stages.set($v{key}, ${Context.parse(localClass.name, Context.currentPos())});
                Stage.stages.exists($v{key});
            }), pos: Context.currentPos()
        });

        return fields;
    }
}
#end