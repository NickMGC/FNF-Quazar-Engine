package objects.game;

class StrumNote extends NoteSprite {
	public var autoReset:Bool = true;

	public function new(data:Int = 0, line:Strumline):Void {
		super(data, line);

		playAnim('strum $dir');
		animation.onFinish.add(onFinish);
	}

	function onFinish(name:String):Void {
		if (name == 'confirm $dir' && autoReset) {
			resetAnim();
		}
	}

	public function confirm(autoReset:Bool = true):Void {
		playAnim('confirm $dir', true);
		this.autoReset = autoReset;
	}

	public function press():Void {
		playAnim('press $dir');
	}

	public function resetAnim():Void {
		playAnim('strum $dir');
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	override function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		
		if (strumline.skinData.metadata.autoOffsetStrums) {
			centerOrigin();
			centerOffsets();

			return;
		}

		if (offsets.exists(name)) offset.set(offsets[name][0] ?? 0, offsets[name][1] ?? 0);
	}
}