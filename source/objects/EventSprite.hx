package objects;

// i was too lazy ok
class EventSprite extends FlxSprite {
    public var data:EventJSON;

    public function new(x:Float = 0, y:Float = 0, data:EventJSON = null):Void {
        super(x, y);
        this.data = data;
        loadGraphic(Path.image('event'));
    }
}