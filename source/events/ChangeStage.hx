package events;

@event('Change Stage')
class ChangeStage implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Stage Name', 'name').string('stage')
    ];

    public function execute(params:EventParams):Void {
        game.stage.load(params.string('name'));
        game.moveCamera(Util.getCharacter(game.target));
    }
}