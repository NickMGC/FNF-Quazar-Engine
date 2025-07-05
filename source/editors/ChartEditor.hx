package editors;

import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.FlxGridOverlay;

//FIXME: song stops playing forever after it reaches the finish line
//TODO: add selection logic to events, audio waveforms, user interface and the ability to export the chart file
//TODO: recode this entirely when i finish it coz its ass
class ChartEditor extends MusicScene {
    public static inline var GRID_SIZE:Int = 40;

    public var chart:Chart;

    public var inst:FlxSound;
    public var voices:FlxSound;
    public var voicesOpponent:FlxSound;

	public var gridBG:FlxSprite;
	var selectedBox:FlxSprite;

    public var notes:FlxTypedSpriteGroup<NoteSprite>;
	public var sustains:Array<LeSustain> = [];
    public var displaySustains:FlxSpriteGroup;
    public var events:FlxTypedSpriteGroup<EventSprite>;

    public var lines:FlxSpriteGroup;

    public var time(get, set):Float;

    public var selectedNote:NoteJSON = null;
    public var selectedEvent:EventJSON = null;


    public function new(chart:Chart = null):Void {
        super();
        this.chart = chart ?? Path.chart('Test', 'normal');
    }

    override public function create():Void {
        super.create();

        inst = Path.song('Inst', chart.song);
	    voices = Path.song('Voices-Player', chart.song);
		voicesOpponent = Path.song('Voices-Opponent', chart.song);

        conductor.paused = true;
        conductor.bpm = chart.bpm;
        conductor.song = inst;

        for (val in [inst, voices, voicesOpponent]) {
            val.play();
            val.pause();
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Path.image('menuDesat'));
        bg.color = 0xFF252525;
        bg.scrollFactor.set();
        add(bg);

		add(gridBG = new FlxTiledSprite(FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 16, true, 0xFFAAAAAA, 0xFF616060), GRID_SIZE * 9, GRID_SIZE * 16));
        gridBG.x = 440;

        add(lines = new FlxSpriteGroup());

        regenGrid();

        add(selectedBox = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(GRID_SIZE, GRID_SIZE));

        add(displaySustains = new FlxSpriteGroup());
        add(notes = new FlxTypedSpriteGroup());
        add(events = new FlxTypedSpriteGroup());

        var spr:FlxSprite = new FlxSprite(440, 200).makeGraphic(Math.floor(gridBG.width), 4, FlxColor.RED);
        spr.alpha = 0.5;
        spr.scrollFactor.set();
        add(spr);

        Key.onPress(Key.accept, toggleSong);
        Key.onPress([FlxKey.P], setTime.bind(inst.length));
        Key.onPress([FlxKey.O], setTime.bind(0));
        Key.onPress([FlxKey.Q], moveSection.bind(-1));
        Key.onPress([FlxKey.E], moveSection.bind(1));
        Key.onPress([FlxKey.W], adjustSustain.bind(-stepLength));
        Key.onPress([FlxKey.S], adjustSustain.bind(stepLength));

        for (note in chart.notes) {
            createNote(note);
		}

        for (event in chart.events) {
            createEvent(event);
        }
    }

    function regenGrid():Void {//reminder for myself to call this function when a bpm/time signature change occurs
        var section:Float = inst.length / measureLength;

		gridBG.height = GRID_SIZE * 16 * section;

        for (line in lines) {
            lines.remove(line, true);
        }

        for (i in 0...Math.floor(section)) {
			lines.add(new FlxSprite(gridBG.x, getYfromStrum(measureLength * i)).makeGraphic(Std.int(gridBG.width), 2, 0xFF000000));
		}

        lines.add(new FlxSprite(gridBG.x + 160).makeGraphic(2, Math.floor(gridBG.height), 0xFF000000));
        lines.add(new FlxSprite(gridBG.x + 320).makeGraphic(2, Math.floor(gridBG.height), 0xFF000000));
    }

    function createNote(note:NoteJSON):Void {
        var noteSpr:NoteSprite = new NoteSprite(note.data);
        noteSpr.setGraphicSize(GRID_SIZE, GRID_SIZE);
        noteSpr.updateHitbox();
        noteSpr.setPosition(note.data * GRID_SIZE + gridBG.x, getYfromStrum(note.time));
        noteSpr.animation.play('note${noteSpr.dir}');
        noteSpr._noteData = note;
        notes.add(noteSpr);

		if (note.length > 0) {
            var sustainHeight:Int = Math.floor((FlxMath.remapToRange(note.length, 0, stepLength * 16, 0, GRID_SIZE * 16)) - (noteSpr.height * 0.5));

            var sustain:FlxSprite = new FlxSprite(noteSpr.x + (noteSpr.width - 4) * 0.5, noteSpr.y + (noteSpr.height * 0.5)).makeGraphic(1, 1);
            sustain.origin.y = 0;
            sustain.scale.set(8, sustainHeight);
            sustain.updateHitbox();
			sustains.push({sprite: sustain, note: noteSpr._noteData});
            displaySustains.add(sustain);
		}
    }

    function createEvent(event:EventJSON):Void {
        events.add(new EventSprite(8 * GRID_SIZE + gridBG.x, getYfromStrum(event.time), event));
    }

    function toggleSong():Void {
        conductor.paused = !conductor.paused;

        for (val in [inst, voices, voicesOpponent]) {
			conductor.paused ? val.pause() : val.resume();
		}
    }

    function setTime(value:Float):Void {
        time = value;
        if (!conductor.paused) toggleSong();
    }

    function moveSection(dir:Int):Void {
        time = Math.max(0, Math.min((curMeasure + (FlxG.keys.pressed.SHIFT ? dir * 4 : dir)) * measureLength, inst.length));
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.mouse.wheel != 0) {
            time = Math.max(0, Math.min((curStep + (FlxG.mouse.wheel > 0 ? -1 : 1)) * stepLength, inst.length));
            if (!conductor.paused) toggleSong();
		}

        FlxG.camera.scroll.y = getYfromStrum(time) - 200;

        if (FlxG.mouse.overlaps(gridBG)) {
            selectedBox.setPosition(Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE, FlxG.keys.pressed.SHIFT ? FlxG.mouse.y : Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE);

            if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.overlaps(notes)) {
					for (note in notes.members.filter(byVisibleNote)) {
						if (FlxG.mouse.overlaps(note)) {
							FlxG.keys.pressed.CONTROL ? selectedNote = note._noteData : removeNote(note._noteData);
						}
					}
				} else {
					addNote();
				}

                if (FlxG.mouse.overlaps(events)) {
					for (event in events.members.filter(byVisibleEvent)) {
						if (FlxG.mouse.overlaps(event)) {
							FlxG.keys.pressed.CONTROL ? selectedEvent = event.data : removeEvent(event.data);
						}
					}
				} else {
					addEvent();
				}
			}
		} else {
            selectedBox.setPosition(-FlxG.width, -FlxG.height);
        }
    }

    function byVisibleNote(note:NoteSprite):Bool {
        return note.isOnScreen();
    }

    function byVisibleEvent(event:EventSprite):Bool {
        return event.isOnScreen();
    }

    function get_time():Float {
        return conductor.time;
    }

    function set_time(value:Float):Float {
        conductor.time = value;
        for (val in [inst, voices, voicesOpponent, conductor.song]) {
            val.time = value;
        }

        return conductor.time;
    }

    function getYfromStrum(time:Float):Float {
		return FlxMath.remapToRange(time, 0, 16 * stepLength, gridBG.y, gridBG.y + (GRID_SIZE * 16));
	}

    function getStrumTime(y:Float):Float {
		return FlxMath.remapToRange(y, gridBG.y, gridBG.y + (GRID_SIZE * 16), 0, 16 * stepLength);
	}

    function removeNote(note:NoteJSON):Void {
        chart.notes.remove(note);
        
        for (n in notes.members.filter(byVisibleNote)) {
            if (n._noteData == note) {
                notes.remove(n, true);

                for (sustain in sustains) {
                    if (sustain.note == note) {
                        sustains.remove(sustain);
                        displaySustains.remove(sustain.sprite, true);
                    }
                }
            }
        }
    }

    public function adjustSustain(dir:Float = 0) {
        if (selectedNote == null) return;

        selectedNote.length += FlxG.keys.pressed.SHIFT ? dir * 2 : dir;
        if (selectedNote.length < 0) selectedNote.length = 0;

        var existingSustain:LeSustain = null;
        for (sustain in sustains) if (sustain.note == selectedNote) existingSustain = sustain;

        if (selectedNote.length > 0) {
            existingSustain == null ? createSustainForNote(selectedNote) : updateSustainHeight(existingSustain);
        } else {
            if (existingSustain != null) {
                removeSustainForNote(selectedNote);
            }
        }
    }

    function createSustainForNote(note:NoteJSON):Void {
        var noteSpr:NoteSprite = null;

        for (n in notes) if (n._noteData == note) noteSpr = n;

        if (noteSpr == null) return;

        var sustainHeight:Int = Math.floor((FlxMath.remapToRange(note.length, 0, stepLength * 16, 0, GRID_SIZE * 16)) - (noteSpr.height * 0.5));
        var sustain:FlxSprite = new FlxSprite(noteSpr.x + (noteSpr.width - 4) * 0.5, noteSpr.y + (noteSpr.height * 0.5)).makeGraphic(1, 1);
        sustain.origin.y = 0;
        sustain.scale.set(8, sustainHeight);
        sustain.updateHitbox();

        var leSustain:LeSustain = {sprite: sustain, note: note};
        sustains.push(leSustain);
        displaySustains.add(sustain);
    }

    function removeSustainForNote(note:NoteJSON):Void {
        for (sustain in sustains) {
            if (sustain.note == note) {
                displaySustains.remove(sustain.sprite, true);
                sustains.remove(sustain);
            }
        }
    }

    function updateSustainHeight(sustain:LeSustain):Void {
        var noteSpr:NoteSprite = null;

        for (n in notes) if (n._noteData == sustain.note) noteSpr = n;

        if (noteSpr == null) return;

        var newHeight:Int = Math.floor((FlxMath.remapToRange(sustain.note.length, 0, stepLength * 16, 0, GRID_SIZE * 16)) - (noteSpr.height * 0.5));
        sustain.sprite.scale.y = newHeight;
        sustain.sprite.updateHitbox();
    }

    function addNote():Void {
		var direction:Int = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) - 10;

        if (direction > 7) return;

		var noteData:NoteJSON = {time: getStrumTime(selectedBox.y), data: direction, type: ''};

		chart.notes.push(noteData);
        createNote(noteData);
		selectedNote = noteData;
	}

    function addEvent():Void {
        var direction:Int = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) - 10;

        if (direction < 8) return;

        var eventData:EventJSON = {time: getStrumTime(selectedBox.y), events: []};

        chart.events.push(eventData);
        createEvent(eventData);
        selectEvent(eventData);
    }

    function removeEvent(event:EventJSON):Void {
        chart.events.remove(event);
        
        for (e in events) {
            if (e.data == event) {
                events.remove(e, true);
            }
        }
    }

    function selectEvent(event:EventJSON):Void {}
}

typedef LeSustain = {sprite:FlxSprite, note:NoteJSON}