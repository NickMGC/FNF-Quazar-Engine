package events;

@event('Set Character Speed')
class SetCharacterSpeed implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Character', 'character').list(['bf', 'dad', 'gf'], 'bf'),
        new EventMeta('Speed', 'speed').float(0.05, 1.0)
    ];

    public function execute(params:EventParams):Void {
        var character:Character = Util.getCharacter(params.string('character'));
        if (character == null) return;

        character.speed = params.float('speed');
    }
}