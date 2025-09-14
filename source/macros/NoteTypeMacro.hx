package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

//TODO: Instead of making this shit just use fucking rulescript to get stages, events and note types at runtime man
class NoteTypeMacro {
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();

        if (!Context.unify(Context.getLocalType(), Context.getType('objects.BaseNote'))) {
            Context.error('Class ${localClass.name} must implement objects.BaseNote to use the @note macro.', Context.currentPos());
            return fields;
        }

        var eventMeta:MetadataEntry;
        var key:String;

        for (meta in localClass.meta.get()) {
            if (meta.name != 'note') continue;
            eventMeta = meta;
        }

        if (eventMeta == null) {
            Context.warning('${localClass.name} doesnt have an "@note" metadata, it will not be registered by the note type map.', Context.currentPos());
            return fields;
        }

        if (eventMeta.params.length < 1) {
            Context.error('You must declare a value', eventMeta.pos);
            return fields; 
        }

        if (eventMeta.params.length > 1) {
            Context.error('Note key must have one value only', eventMeta.pos);
            return fields; 
        }

        switch eventMeta.params[0].expr {
            case EConst(CString(s)): key = s;
            case _:
                Context.error('Note key must be a string literal', eventMeta.params[0].pos);
                return fields;
        }

        fields.push({
            name: '_initNoteType_',
            access: [AStatic, APrivate],
            kind: FVar(macro:Bool, macro {
                NoteType.noteTypes.set($v{key}, ${Context.parse(localClass.name, Context.currentPos())});
                NoteType.noteTypes.exists($v{key});
            }), pos: Context.currentPos()
        });

        return fields;
    }
}
#end