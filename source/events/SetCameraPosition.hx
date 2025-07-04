package events;

@event('Set Camera Position')
class SetCameraPosition implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('X Position', 'x').float(100, 0),
        new EventMeta('Y Position', 'y').float(100, 0),
        new EventMeta('Force Camera Position', 'forceCameraPos').bool(false)
    ];

    public function execute(params:EventParams):Void {
        game.camFollow.setPosition(params.float('x'), params.float('y'));
        game.forceCameraPos = params.bool('forceCameraPos');
    }
}