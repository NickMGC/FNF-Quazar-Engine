package noteTypes;

@note('default')
class DefaultNote implements BaseNote {
    public var healthGain:Float = 0.025;
    public var healthLoss:Float = 0.05;
    public var healthGainHold:Float = 0.085;

    public var scoreGainSick:Int = 350;
    public var scoreGainGood:Int = 200;
    public var scoreGainBad:Int = 100;
    public var scoreGainShit:Int = 50;

    public var scoreLoss:Int = 100;
    public var scoreGainHold:Int = 250;

    public var mustPress:Bool = true;
    public var hitCausesMiss:Bool = false;
    public var hitByOpponent:Bool = true;

    public var skin:NoteSkinData;

    public function onHit(note:Note):Void {}
    public function onMiss(note:Note):Void {}
    public function onHold(note:Note):Void {}
    public function onHoldFinish(note:Note):Void {}
    public function onHoldRelease(note:Note):Void {}
}