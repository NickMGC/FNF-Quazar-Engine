package objects;

/*
 * For now I will just lay out what things can be modified in a note type.
 */
class BaseNote {
    public var healthGain:Float;
    public var healthLoss:Float;
    public var healthGainHold:Float;

    public var mustPress:Bool;
    public var hitByOpponent:Bool;

    public var skin:String;

    public function onHit():Void {}
    public function onMiss():Void {}

    public function onHold():Void {}
    public function onHoldFinish():Void {}
    public function onHoldRelease():Void {}
}