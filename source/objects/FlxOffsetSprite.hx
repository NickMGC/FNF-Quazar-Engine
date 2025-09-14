package objects;

@:build(macros.AgnosticOffsetMacro.build())
class FlxOffsetSprite extends FlxSprite {
    public function new(x:Float = 0, y:Float = 0, simpleGraphic:String):Void {
        super(x, y, simpleGraphic);
    }
}