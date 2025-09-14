package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class EventMacro {
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();

        if (!Context.unify(Context.getLocalType(), Context.getType('objects.BaseEvent'))) {
            Context.error('Class ${localClass.name} must implement objects.BaseEvent to use the @event macro.', Context.currentPos());
            return fields;
        }

        var eventMeta:MetadataEntry;
        var key:String;

        for (meta in localClass.meta.get()) {
            if (meta.name != 'event') continue;
            eventMeta = meta;
        }

        if (eventMeta == null) {
            Context.warning('${localClass.name} doesnt have an "@event" metadata, it will not be registered by the event map.', Context.currentPos());
            return fields;
        }

        if (eventMeta.params.length < 1) {
            Context.error('You must declare a value', eventMeta.pos);
            return fields; 
        }

        if (eventMeta.params.length > 1) {
            Context.error('Event key must have one value only', eventMeta.pos);
            return fields; 
        }

        switch eventMeta.params[0].expr {
            case EConst(CString(s)): key = s;
            case _:
                Context.error('Event key must be a string literal', eventMeta.params[0].pos);
                return fields;
        }

        fields.push({
            name: '_initEvent_',
            access: [AStatic, APrivate],
            kind: FVar(macro:Bool, macro {
                Event.events.set($v{key}, ${Context.parse(localClass.name, Context.currentPos())});
                Event.events.exists($v{key});
            }), pos: Context.currentPos()
        });

        return fields;
    }
}
#end