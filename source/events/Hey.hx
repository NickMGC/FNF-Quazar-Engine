package events;

@event('Hey!')
class Hey implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Character', 'character').list(['bf', 'dad', 'gf'], 'bf'),
        new EventMeta('Hold Timer', 'holdTimer').float(0.05, 0.6)
    ];

    public function execute(params:EventParams):Void {
        var character:Character = Util.getCharacter(params.string('character'));
        if (character == null) return;

        character.playAnim('hey');
        character.specialAnim = true;
        character.holdTimer = params.float('holdTimer');
    }
}