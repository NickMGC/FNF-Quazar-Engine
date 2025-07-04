package events;

@event('Set Camera Zoom')
class SetCameraZoom implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Camera Zoom', 'zoom').float(0.05, 1.0),
        new EventMeta('Duration', 'duration').float(0.05, 1.0),
        new EventMeta('Ease', 'ease').list(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep'], 'linear'),
        new EventMeta('Ease Direction', 'easeDir').list(['In', 'Out', 'InOut', 'None'], 'None')
    ];

    public function execute(params:EventParams):Void {
        var zoom:Float = params.float('zoom');
        var duration:Float = params.float('duration');
        var ease:String = params.string('ease');

        var easeDir:String = params.string('easeDir');
        if (easeDir == 'None') easeDir = '';

        duration > 0 ? FlxTween.num(game.defaultCamZoom, zoom, duration, {ease: Util.getEase(ease + easeDir)}, setCamZoom) : game.defaultCamZoom = zoom;
    }

    function setCamZoom(value:Float):Void {
        game.defaultCamZoom = value;
    }
}