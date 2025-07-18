package objects.game;

class NoteSprite extends FlxSprite {
	public var data:Int = 0;

	public var dir(get, default):String;
    function get_dir():String {
        return Note.direction[data % Note.direction.length];
    }

	public var _noteData:NoteJSON;

	public function new(data:Int = 0):Void {
		super();

		this.data = data;

		loadSkin(Path.sparrow('noteSkins/default/notes'));

		scale.set(0.7, 0.7);
		updateHitbox();
	}

	public function loadSkin(newFrames:FlxAtlasFrames):Void {
		if (frames == newFrames) return;

		frames = newFrames ?? frames;
		animation.destroyAnimations();

		for (dir in Note.direction) {
			for (name in ['strum', 'note', 'tail', 'hold']) {
				animation.addByPrefix('$name$dir', '$name $dir', 24);
			}

			animation.addByPrefix('confirm$dir', 'confirm $dir', 24, false);
			animation.addByPrefix('press$dir', 'press $dir', 24, false);
		}

		animation.play('note$dir');
		updateHitbox();
	}
}