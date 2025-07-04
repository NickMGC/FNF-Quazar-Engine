package events;

@event('Flash Camera')
class FlashCamera implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Camera', 'camera').list(['camGame', 'camHUD', 'camOther'], 'camGame'),
        new EventMeta('color', 'color').string('FFFFFFFF'),
        new EventMeta('Duration', 'duration').float(0.05, 1.0)
    ];

    public function execute(params:EventParams):Void {
        var camera:FlxCamera = Util.getCamera(params.string('camera'));
        if (camera == null) return;

        camera.flash(FlxColor.fromString(params.string('color')), params.float('duration'));
    }
}