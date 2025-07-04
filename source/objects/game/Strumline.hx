package objects.game;

class Strumline extends FlxSpriteGroup {
	public var nextNote:Int = 0;

	public var strums:Array<StrumNote> = [];
	public var noteData:Array<NoteJSON> = [];

	public var notes:FlxTypedSpriteGroup<Note>;
	public var sustains:FlxTypedSpriteGroup<Sustain>;
	public var splashes:FlxTypedSpriteGroup<NoteSplash>;

	public var voices:FlxSound;

	public var autoHit:Bool = false;

	public var skin:String = 'default';
	public var splashFrames:FlxAtlasFrames = Path.sparrow('noteSkins/default/splashes');

	public var character:Character;

	public function new(x:Float, y:Float, camera:FlxCamera, autoHit:Bool = false):Void {
		super(x, y);

		for (i in 0...4) {
			strums.push(new StrumNote(i, this));
			strums[i].x = 115 * i;
			add(strums[i]);
		}

		add(sustains = new FlxTypedSpriteGroup());
		add(notes = new FlxTypedSpriteGroup());
		add(splashes = new FlxTypedSpriteGroup());

		this.autoHit = autoHit;

		if (camera != null) this.camera = camera;
	}

	public function loadSkin(path:String = 'default'):Void {
		skin = path;
		splashFrames = Path.sparrow('noteSkins/$skin/splashes');

		for (strum in strums) {
			strum.onSkinChange();
		}

		for (note in notes) {
			note.onSkinChange();
		}
	}

	override public function update(elapsed:Float):Void {
        super.update(elapsed);

		while (nextNote < noteData.length && noteData[nextNote].time < (playField.conductor.time + ((FlxG.height / camera.zoom) * 1.1) / (playField.scrollSpeed * 0.45))) {
        	if (noteData == null || nextNote >= noteData.length) return;

        	notes.recycle(newNote).setup(noteData[nextNote], this);
			notes.sort(byTime);
        	nextNote++;
        }
    }

	function newNote():Note {
		var note = new Note();
		note.camera = camera;
		return note;
	}

	function byTime(Order:Int, Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(Order, Obj1.time, Obj2.time);
	}
}