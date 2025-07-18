package objects.game;

class Strumline extends FlxSpriteGroup {
	public var nextNote:Int = 0;

	public var strums:Array<StrumNote> = [];
	public var sustainCovers:Array<SustainCover> = [];
	public var noteData:Array<NoteJSON> = [];

	public var notes:FlxTypedSpriteGroup<Note>;
	public var sustains:FlxTypedSpriteGroup<Sustain>;
	public var splashes:FlxTypedSpriteGroup<NoteSplash>;
	public var endSplashes:FlxTypedSpriteGroup<SustainCover>;

	public var voices:FlxSound;

	public var autoHit:Bool = false;

	public var skin:String = 'default';
	public var noteFrames:FlxAtlasFrames = Path.sparrow('noteSkins/default/notes');
	public var splashFrames:FlxAtlasFrames = Path.sparrow('noteSkins/default/splashes');
	public var coverFrames:FlxAtlasFrames = Path.sparrow('noteSkins/default/covers');

	public var character:Character;

	public static var NOTE_SPACING:Float = 112;

	public function new(x:Float, y:Float, camera:FlxCamera, autoHit:Bool = false):Void {
		super(x, y);

		for (i in 0...4) {
			strums.push(new StrumNote(i, this));
			strums[i].x = 115 * i;
			add(strums[i]);
		}

		add(sustains = new FlxTypedSpriteGroup());

		for (i in 0...4) {
			sustainCovers.push(new SustainCover(i));
			sustainCovers[i].x = strums[i].x + (strums[i].width - sustainCovers[i].width) * 0.5;
			add(sustainCovers[i]);
		}

		add(notes = new FlxTypedSpriteGroup());
		add(splashes = new FlxTypedSpriteGroup());
		add(endSplashes = new FlxTypedSpriteGroup());

		this.autoHit = autoHit;

		if (camera != null) this.camera = camera;
	}

	public function loadSkin(path:String = 'default'):Void {
		skin = path;
		noteFrames = Path.sparrow('noteSkins/$skin/notes');
		splashFrames = Path.sparrow('noteSkins/$skin/splashes');
		coverFrames = Path.sparrow('noteSkins/$skin/covers');

		for (strum in strums) {
			strum.onSkinChange();
		}

		for (cover in sustainCovers) {
			cover.loadSkin(coverFrames);
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