package events;

@event('Set Camera Speed')
class SetCameraSpeed implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Speed', 'speed').float(0.05, 1.0),
        new EventMeta('Duration', 'duration').float(0.05, 1.0),
        new EventMeta('Ease', 'ease').list(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep'], 'linear'),
        new EventMeta('Ease Direction', 'easeDir').list(['In', 'Out', 'InOut', 'None'], 'None')
    ];

    public function execute(params:EventParams):Void {
        var speed:Float = params.float('speed');
        var duration:Float = params.float('duration');
        var ease:String = params.string('ease');

        var easeDir:String = params.string('easeDir');
        if (easeDir == 'None') easeDir = '';

        duration > 0 ? FlxTween.num(game.cameraSpeed, speed, duration, {ease: Util.getEase(ease + easeDir)}, setCamSpeed) : game.cameraSpeed = speed;
    }

    function setCamSpeed(value:Float):Void {
        game.cameraSpeed = value;
    }
}