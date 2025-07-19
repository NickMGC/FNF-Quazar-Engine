package objects;

interface BaseNote {
    public var healthGain:Float;
    public var healthLoss:Float;
    public var healthGainHold:Float;

    public var mustPress:Bool;
    public var hitByOpponent:Bool;

    public var texture:String;
    public var splashTexture:String;
    public var coverTexture:String;

    public function onHit():Void;
    public function onMiss():Void;

    public function onHold():Void;
    public function onHoldFinish():Void;
    public function onHoldRelease():Void;
}