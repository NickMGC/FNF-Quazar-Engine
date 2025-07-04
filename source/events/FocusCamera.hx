package events;

@event('Focus Camera')
class FocusCamera implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Character', 'character').list(['bf', 'dad', 'gf'], 'bf'),
        new EventMeta('Classic', 'classic').bool(true),
        new EventMeta('Duration', 'duration').float(0.05, 1.0).when('classic!=true'),
        new EventMeta('Ease', 'ease').list(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep'], 'linear').when('classic!=true'),
        new EventMeta('Ease Direction', 'easeDir').list(['In', 'Out', 'InOut'], 'Out').when('classic!=true||ease!=linear')
    ];

    public function execute(params:EventParams):Void {
        var character:Character = Util.getCharacter(params.string('character'));
        if (character == null) return;

        if (params.bool('classic')) {
            game.moveCamera(character);
            return;
        }

        var duration:Float = params.float('duration');
        var easeDir:String = params.string('easeDir');
        var ease:Float -> Float = Util.getEase(params.string('ease') + easeDir);

        FlxTween.num(game.camFollow.x, character.getMidpoint().x + character.cameraPosition[0] + character.cameraOffset[0], duration, {ease: ease}, updateX);
        FlxTween.num(game.camFollow.y, character.getMidpoint().y + character.cameraPosition[1] + character.cameraOffset[1], duration, {ease: ease}, updateY);
    }

    public function updateX(value:Float):Void {
        game.camFollow.x = value;
    }

    public function updateY(value:Float):Void {
        game.camFollow.y = value;
    }
}