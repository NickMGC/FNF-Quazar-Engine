package objects;

interface BaseNote {
    public var healthGain:Float;
    public var healthLoss:Float;
    public var healthGainHold:Float;

    public var scoreGainSick:Int;
    public var scoreGainGood:Int;
    public var scoreGainBad:Int;
    public var scoreGainShit:Int;

    public var scoreLoss:Int;
    public var scoreGainHold:Int;

    public var mustPress:Bool;
    public var hitCausesMiss:Bool;
    public var hitByOpponent:Bool;

    public var skin:NoteSkinData;

    public function onHit(note:Note):Void;
    public function onMiss(note:Note):Void;

    public function onHold(note:Note):Void;
    public function onHoldFinish(note:Note):Void;
    public function onHoldRelease(note:Note):Void;
}