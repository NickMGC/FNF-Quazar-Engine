package events;

@event('Set Song BPM')
class SetSongBPM implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('BPM', 'bpm').float(0.05, 100),
        new EventMeta('Duration', 'duration').float(0.05, 1.0),
        new EventMeta('Ease', 'ease').list(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep'], 'linear'),
        new EventMeta('Ease Direction', 'easeDir').list(['In', 'Out', 'InOut'], '').when('ease!=linear')
    ];

    public function execute(params:EventParams):Void {
        var bpm:Float = params.float('bpm');
        var duration:Float = params.float('duration');
        var ease:String = params.string('ease');
        var easeDir:String = params.string('easeDir');

        duration > 0 ? FlxTween.num(playField.conductor.bpm, bpm, duration, {ease: Util.getEase(ease + easeDir)}, setBPM) : playField.conductor.bpm = bpm;
    }

    function setBPM(value:Float):Void {
        playField.conductor.bpm = value;
    }
}