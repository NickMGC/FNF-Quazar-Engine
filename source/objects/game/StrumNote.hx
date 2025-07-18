package objects.game;

class StrumNote extends NoteSprite {
	public var autoReset:Bool = true;
	public var strumline:Strumline;

	public function new(data:Int = 0, line:Strumline):Void {
		super(data);

		strumline = line;

		playAnim('strum$dir');
		animation.onFinish.add(onFinish);
	}

	public function onSkinChange():Void {
		loadSkin(strumline.noteFrames);
		playAnim('strum$dir');
	}

	function onFinish(name:String):Void {
		if (name == 'confirm$dir' && autoReset) {
			resetAnim();
		}
	}

	public function confirm(autoReset:Bool = true):Void {
		playAnim('confirm$dir', true);
		this.autoReset = autoReset;
	}

	public function press():Void {
		playAnim('press$dir');
	}

	public function resetAnim():Void {
		playAnim('strum$dir');
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(animName, force, reversed, frame);
		centerOrigin();
		centerOffsets();
	}
}