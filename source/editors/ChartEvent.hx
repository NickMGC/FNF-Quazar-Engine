package editors;

// i was too lazy ok
class ChartEvent extends FlxSprite {
    public var data:EventJSON;

    public function new(x:Float = 0, y:Float = 0, data:EventJSON = null):Void {
        super(x, y, Path.image('event'));
        this.data = data;
    }
}