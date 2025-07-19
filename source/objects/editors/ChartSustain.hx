package objects.editors;

import states.editors.ChartEditor;

class ChartSustain extends FlxSprite {
    public var data:NoteJSON;

    public function new(x:Float = 0, y:Float = 0, data:NoteJSON, stepLength:Float):Void {
        super(x, y);

        this.data = data;

        makeGraphic(8, 1);
        origin.y = 0;

        setHeight(data.length, stepLength);
    }

    public function setHeight(length:Float, stepLength:Float):Float {
        return scale.y = Math.floor((FlxMath.remapToRange(length, 0, stepLength * 16, 0, ChartEditor.GRID_SIZE * 16)) - 20);
    }
}