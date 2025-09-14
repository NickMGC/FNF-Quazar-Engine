package states;

class DelayState extends MusicScene {
	var holdTime:Float = 0;

	var delayText:FlxText;

	var stage:BaseStage;

	override function create():Void {
		conductor.bpm = 80;
		FlxG.sound.playMusic(Path.music('songOffset'), 0.5);
		
		add(stage = Stage.get('stage'));

		add(delayText = new FlxText(0, 30, 1280, '${Data.songOffset}').setFormat(Path.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER));

		Key.onPress(Key.back, onBack);

		Key.onPress(Key.left, updateOffset.bind(-1));
		Key.onPress(Key.right, updateOffset.bind(1));

		Key.onHold(Key.left, updateOffset.bind(-1, true));
		Key.onHold(Key.right, updateOffset.bind(1, true));

		Key.onRelease(Key.left.concat(Key.right), onKeyRelease);

		super.create();
	}

	function onBack():Void {
		conductor.paused = true;
		FlxG.switchState(new OptionsState());
		FlxG.sound.play(Path.sound('cancel'), 0.6);
		FlxG.sound.music.stop();
	}

	override function onBeat():Void {
		for (char in [stage.bf, stage.dad, stage.gf]) {
			if (curBeat % Math.round(char.speed * char.danceEveryNumBeats) != 0) continue;
			char.dance();
		}

		super.onBeat();
	}
 
	var mult:Float = 1;
	function updateOffset(dir:Int = 0, hold:Bool = false):Void {
		if (hold && holdTime < 0.5) {
			holdTime += 0.1;
			return;
		}

		Data.songOffset = Util.boundInt(Data.songOffset + (dir == -1 ? -1 : 1) * mult, -500, 500);
		mult = holdTime > 0.5 ? 3 : 1;

		delayText.text = '${Data.songOffset}';

		FlxG.sound.play(Path.sound('scroll'), 0.4);
	}

	inline function onKeyRelease():Void {
		holdTime = 0;
	}
}