package objects.game;

class Sustain extends FlxTailedSprite {
	public function setup(note:Note):Sustain {
		if (frames != note.frames) {
			animation.destroyAnimations();
			frames = note.frames;
			animation.copyFrom(note.animation);
		}
	
		animation.play('hold${note.dir}');
		setTailAnim('tail${note.dir}');

		camera = note.camera;
		scale = note.scale;
		updateHitbox();

		offset.y = -note.height * (Data.downScroll ? 0.65 : 0.5);
		origin.y = 0;

		flipY = Data.downScroll;

		setPosition(x + (note.width - width) * 0.5, Data.downScroll ? note.y - height : note.y);

		return this;
	}
}