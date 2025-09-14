package objects.game;

class Sustain extends FlxTailedSprite {
	public function setup(note:Note):Sustain {
		onSkinChange(note);
		setPosition(x + (note.width - width) * 0.5, Data.downScroll ? note.y - height : note.y);
		return this;
	}

	public function onSkinChange(note:Note):Void {
		if (frames != note.frames) {
			frames = note.frames ?? frames;
			animation.copyFrom(note.animation);
		}
	
		animation.play('hold ${note.dir}');
		setTailAnim('tail ${note.dir}');

		camera = note.camera;
		scale = note.scale;
		updateHitbox();

		offset.y = -note.height * 0.5;
		origin.y = 0;

		flipY = Data.downScroll;
	}
}