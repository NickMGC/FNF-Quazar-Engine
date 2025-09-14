package events;

//TODO: yeah
@event('dont the cat')
class ChangeCharacter implements BaseEvent {
    public var meta:Array<EventMeta> = [];

    public function execute(params:EventParams):Void {
        game.song.scrollSpeed = params.float('speed');
    }
}