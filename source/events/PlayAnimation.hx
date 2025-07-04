package events;

@event('Play Animation')
class PlayAnimation implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Character', 'character').list(['bf', 'dad', 'gf'], 'bf'),
        new EventMeta('Animation', 'animation').string(''),
        new EventMeta('Special Animation', 'specialAnim').bool(true),
        new EventMeta('Hold Timer', 'holdTimer').float(0.05, 0)
    ];

    public function execute(params:EventParams):Void {
        var character:Character = Util.getCharacter(params.string('character'));
        var animation:String = params.string('animation');

        if (character == null || animation == null) return;

        character.playAnim(animation);
        character.specialAnim = params.bool('specialAnim');
        character.holdTimer = params.float('holdTimer');
    }
}