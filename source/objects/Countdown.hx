package objects;

class Countdown extends FlxSpriteGroup {
	public static var spriteNames:Array<String> = ['ready', 'set', 'go'];
    public static var soundNames:Array<String> = ['three', 'two', 'one', 'go'];

	public function new():Void {
		super();

		playField.conductor.time = -playField.beatLength * 5;
		playField.addBeatSignal(countdown);
	}

	public function countdown():Void {
		if (playField.curBeat == 0) {
			playField.removeBeatSignal(countdown);
			playField.startSong();
			destroy();
			return;
		}

		if (playField.curBeat > -4) {
			var countdownItem:FlxSprite = new FlxSprite();
			countdownItem.frames = Path.sparrow('game/countdown');
			countdownItem.animation.addByNames(spriteNames[playField.curBeat + 3], [spriteNames[playField.curBeat + 3]], 0, false);
			countdownItem.animation.play(spriteNames[playField.curBeat + 3]);
			countdownItem.updateHitbox();
			countdownItem.screenCenter();
			add(countdownItem);

			FlxTween.num(1, 0, playField.beatLength / 1000, {ease: FlxEase.cubeInOut, onComplete: destroySprite.bind(countdownItem)}, updateAlpha.bind(countdownItem));	
		}

		FlxG.sound.play(Path.sound(soundNames[playField.curBeat + 4]));
	}

	function updateAlpha(sprite:FlxSprite, value:Float):Void {
		sprite.alpha = value;
	}

	function destroySprite(sprite:FlxSprite, _:FlxTween):Void {
		sprite.destroy();
	}
}