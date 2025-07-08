package objects.game;

class NoteSplash extends FlxSprite {
	public function new():Void {
		super();

		animation.onFinish.add(killSpr);
		loadSkin(Path.sparrow('noteSkins/default/splashes'));

		scale.set(0.95, 0.95);
		updateHitbox();
	}

	public function loadSkin(skin:FlxAtlasFrames):Void {
		if (frames == skin) return;

		frames = skin ?? frames;
		animation.destroyAnimations();

		for (dir in Note.direction) {
			animation.addByPrefix('splash1$dir', 'splash1 $dir', 24, false);
			animation.addByPrefix('splash2$dir', 'splash2 $dir', 24, false);
		}
		updateHitbox();
	}

	function killSpr(_:String):Void {
		kill();
	}

	public static function spawn(strum:StrumNote):Void {
		var splash:NoteSplash = strum.strumline.splashes.recycle(NoteSplash, newSplash);
		splash.loadSkin(strum.strumline.splashFrames);
		splash.setPosition(strum.x + (strum.width - splash.width) * 0.5, strum.y + (strum.height - splash.height) * 0.5);
		splash.animation.play('splash${FlxG.random.int(1, 2)}' + Note.direction[strum.data % Note.direction.length]);
		splash.camera = strum.camera;
	}
	
	static function newSplash():NoteSplash {
		return new NoteSplash();
	}
}