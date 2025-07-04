package objects;

interface BaseEvent {
    public function execute(params:EventParams):Void;
    public var meta:Array<EventMeta>;
}