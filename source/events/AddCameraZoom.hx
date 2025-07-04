package events;

@event('Add Camera Zoom')
class AddCameraZoom implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Camera', 'camera').list(['camGame', 'camHUD', 'camOther'], 'camGame'),
        new EventMeta('Zoom', 'zoom').float(0.015, 0.015)
    ];

    public function execute(params:EventParams):Void {
        var camera:FlxCamera = Util.getCamera(params.string('camera'));
        if (camera == null) return;

        camera.zoom += params.float('zoom');
    }
}