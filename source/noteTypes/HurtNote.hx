package noteTypes;

@note('hurt')
class HurtNote implements BaseNote {
    public var healthGain:Float = 0;
    public var healthLoss:Float = 0.05;
    public var healthGainHold:Float = 0;

    public var scoreGainSick:Int;
    public var scoreGainGood:Int;
    public var scoreGainBad:Int;
    public var scoreGainShit:Int;

    public var scoreLoss:Int = 100;
    public var scoreGainHold:Int = -250;

    public var mustPress:Bool = false;
    public var hitCausesMiss:Bool = true;
    public var hitByOpponent:Bool = false;

    public var skin:NoteSkinData = new NoteSkinData('hurt');

    public function onHit(note:Note):Void {
        note.miss();
    }

    public function onMiss(note:Note):Void {}
    public function onHold(note:Note):Void {}
    public function onHoldFinish(note:Note):Void {}
    public function onHoldRelease(note:Note):Void {}
}