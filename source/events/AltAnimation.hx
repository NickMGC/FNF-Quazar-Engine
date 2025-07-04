package events;

@event('Alt Animation')
class AltAnimation implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Character', 'character').list(['bf', 'dad', 'gf'], 'bf'),
        new EventMeta('Alt Animation Suffix', 'suffix').string('')
    ];

    public function execute(params:EventParams):Void {
        var character:Character = Util.getCharacter(params.string('character'));
        if (character == null) return;

        character.altSuffix = params.string('suffix');
    }
}