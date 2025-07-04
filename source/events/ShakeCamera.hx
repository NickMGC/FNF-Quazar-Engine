package events;

@event('Shake Camera')
class ShakeCamera implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Camera', 'camera').list(['camGame', 'camHUD', 'camOther'], 'camGame'),
        new EventMeta('Intensity', 'intensity').float(0.025, 0.0),
        new EventMeta('Duration', 'duration').float(0.025, 0.0),
    ];

    public function execute(params:EventParams):Void {
        var camera:FlxCamera = Util.getCamera(params.string('camera'));
        if (camera == null) return;

        var duration:Float = params.float('duration');
        var intensity:Float = params.float('intensity');

        if (duration > 0.0 && intensity != 0.0) {
			camera.shake(intensity, duration);
        }
    }
}