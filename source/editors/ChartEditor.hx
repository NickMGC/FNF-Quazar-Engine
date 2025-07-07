package editors;

import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.waveform.FlxWaveform;

class ChartEditor extends MusicScene {
	public static var chart:Chart;

	public static inline var GRID_SIZE:Int = 40;

	public static final quants:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 96, 192];
	public static var curQuant:Int = 3;

	var inst:FlxSound;
	var voices:FlxSound;
	var voicesOpponent:FlxSound;

	var gridBG:FlxSprite;
	var selectedBox:FlxSprite;

	var lines:FlxSpriteGroup;

	var sustains:FlxTypedGroup<ChartSustain>;
	var notes:FlxTypedGroup<ChartNote>;
	var events:FlxTypedGroup<ChartEvent>;

	var iconP1:HealthIcon;
	var iconP2:HealthIcon;

	var selectedNote:NoteJSON;
	var selectedEvent:EventJSON;

	var playerHitVolume:Float = 1;
	var opponentHitVolume:Float = 1;

	var playerWaveform:FlxWaveform;
	var opponentWaveform:FlxWaveform;

	var time(get, set):Float;
	var lastTime:Float;

	public function new(chart:Chart = null):Void {
		super();
		ChartEditor.chart = chart ?? Path.chart('Test', 'normal');
	}

	override public function create():Void {
		super.create();

		var bg = new FlxSprite().loadGraphic(Path.image('menuDesat'));
		bg.color = 0xFF252525;
		bg.scrollFactor.set();
		add(bg);

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

		add(gridBG = new FlxTiledSprite(FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 16, true, 0xFFAAAAAA, 0xFF616060), GRID_SIZE * 9, GRID_SIZE * 16));
		gridBG.x = 440;

		add(lines = new FlxSpriteGroup());

		add(selectedBox = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(GRID_SIZE, GRID_SIZE));

		add(sustains = new FlxTypedGroup());
		add(notes = new FlxTypedGroup());
		add(events = new FlxTypedGroup());

		var timeline = new FlxSprite(440, 200).makeGraphic(Std.int(gridBG.width), 4, 0x50FF0000);
		timeline.scrollFactor.set();
		add(timeline);

		// add(playerWaveform = new FlxWaveform(400, 200, 80, 720 * 4, 0x00FF0000, 0x00FF0000, COMBINED));
		// playerWaveform.scrollFactor.set();

		// add(opponentWaveform = new FlxWaveform(0, 200, 80, 720 * 4, 0x00FF0000, 0x00FF0000, COMBINED));
		// opponentWaveform.scrollFactor.set();

        // playerWaveform.waveformRMSColor = opponentWaveform.waveformRMSColor = 0xFFFFFFFF;
        // playerWaveform.waveformDrawRMS = opponentWaveform.waveformDrawRMS = true;
        // playerWaveform.waveformOrientation = opponentWaveform.waveformOrientation = VERTICAL;

		// playerWaveform.loadDataFromFlxSound(voices);
        // opponentWaveform.loadDataFromFlxSound(voicesOpponent);

		add(iconP2 = new HealthIcon(gridBG.x - 160, 125, chart.player2));
		iconP2.scrollFactor.set();
		iconP2.scale.set(0.5, 0.5);
		iconP2.updateHitbox();

		add(iconP1 = new HealthIcon(gridBG.x + gridBG.width + 10, 125, chart.player1, true));
		iconP1.scrollFactor.set();
		iconP1.scale.set(0.5, 0.5);
		iconP1.updateHitbox();

		//kill me
		Key.onPress([FlxKey.ENTER], onBack);
		Key.onPress([FlxKey.SPACE], toggleSong);
		Key.onPress([FlxKey.P], setTime.bind(inst.length));
		Key.onPress([FlxKey.O], setTime.bind(0));
		Key.onHold([FlxKey.A], moveSection.bind(-1));
		Key.onHold([FlxKey.D], moveSection.bind(1));
		Key.onHold(Key.up, moveStep.bind(-4));
		Key.onHold(Key.down, moveStep.bind(4));
		Key.onPress([FlxKey.LEFT], onQuantChange.bind(-1));
		Key.onPress([FlxKey.RIGHT], onQuantChange.bind(1));
		Key.onPress([FlxKey.Q], adjustSustain.bind(-stepLength));
		Key.onPress([FlxKey.E], adjustSustain.bind(stepLength));

		chart.notes.iter(createNote);
		chart.events.iter(createEvent);

		regenGrid();
	}

	function regenGrid():Void {
		var section:Float = inst.length / measureLength;

		gridBG.height = GRID_SIZE * 16 * section;

		lines.clear();

		for (i in 0...Math.floor(section)) {
			lines.add(new FlxSprite(gridBG.x, getYfromStrum(measureLength * i)).makeGraphic(Std.int(gridBG.width), 2, 0xFF000000));
		}

		lines.add(new FlxSprite(gridBG.x + 160).makeGraphic(2, Std.int(gridBG.height), 0xFF000000));
		lines.add(new FlxSprite(gridBG.x + 320).makeGraphic(2, Std.int(gridBG.height), 0xFF000000));
	}

	function onBack():Void {
		PlayField._chart = true;
		FlxG.switchState(new PlayState());
	}

	function toggleSong():Void {
		conductor.paused = !conductor.paused;
		for (val in [inst, voices, voicesOpponent]) {
			conductor.paused ? val.pause() : val.resume();
		}
	}

	function setTime(value:Float):Void {
		time = value;
		if (!conductor.paused) {
			toggleSong();
		}
	}

	function moveSection(dir:Int):Void {
		time = FlxMath.bound((curMeasure + dir * (FlxG.keys.pressed.SHIFT ? 4 : 1)) * measureLength, 0, inst.length);
	}

	function moveStep(dir:Int):Void {
		time = FlxMath.bound((curStep + dir) * stepLength, 0, inst.length); //cant just divide measureLength because time signatures exist
	}

	function onQuantChange(dir:Int):Void {
		curQuant = (curQuant + dir + quants.length) % quants.length;
	}

	function createNote(note:NoteJSON):Void {
		notes.add(new ChartNote(note.data * GRID_SIZE + gridBG.x, getYfromStrum(note.time), note));

		if (note.length > 0) {
			createSustain(note);
		}
	}

	function createSustain(note:NoteJSON):Void {
		var noteSpr = notes.members.find(n -> n.data == note);
		if (noteSpr == null) return;

		sustains.add(new ChartSustain(noteSpr.x + (noteSpr.width - 4) * 0.5, noteSpr.y + (noteSpr.height * 0.5), note, stepLength));
	}

	function createEvent(event:EventJSON):Void {
		events.add(new ChartEvent(8 * GRID_SIZE + gridBG.x, getYfromStrum(event.time), event));
	}

	function removeNote(note:NoteJSON):Void {
		chart.notes.remove(note);

		var visualNote = notes.members.find(n -> n.data == note);
		if (visualNote == null) return;

		notes.remove(visualNote, true);
		removeSustain(note);
	}

	function removeSustain(note:NoteJSON):Void {
		var sustain = sustains.members.find(s -> s.data == note);
		if (sustain == null) return;

		sustains.remove(sustain, true);
	}

	function removeEvent(event:EventJSON):Void {
		chart.events.remove(event);

		var visualEvent = events.members.find(e -> e.data == event);
		if (visualEvent == null) return;

		events.remove(visualEvent, true);
	}

	function addNote():Void {
		var direction = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) - 10;
		if (direction > 7) return;

		selectedNote = {time: getStrumTime(selectedBox.y), data: direction, type: '', length: 0};

		chart.notes.push(selectedNote);
		createNote(selectedNote);
	}

	function adjustSustain(delta:Float):Void {
		if (selectedNote == null) return;
		
		selectedNote.length += FlxG.keys.pressed.SHIFT ? delta * 2 : delta;
		if (selectedNote.length < 0) selectedNote.length = 0;

		var sustain = sustains.members.find(s -> s.data == selectedNote);

		selectedNote.length > 0 ? (sustain != null ? sustain.setHeight(selectedNote.length, stepLength) : createSustain(selectedNote)) : removeSustain(selectedNote);
	}


	function addEvent():Void {
		var direction = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) - 10;
		if (direction < 8) return;

		selectedEvent = {time: getStrumTime(selectedBox.y), events: []};

		chart.events.push(selectedEvent);
		createEvent(selectedEvent);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0) {
			moveStep(FlxG.mouse.wheel > 0 ? -1 : 1);

			if (!conductor.paused) {
				toggleSong();
			}
		}

		FlxG.camera.scroll.y = getYfromStrum(time) - 200;

		checkNoteHits();
		mouseInput();

		lastTime = time;

		//playerWaveform.waveformTime = opponentWaveform.waveformTime = time;
	}

	var hitOffset:Float = 15;
	function checkNoteHits():Void {
		if (!conductor.song.playing) return;

		for (note in notes.members.filter(byVisibleNote)) {
			if (note.data.time > time + hitOffset || note.data.time <= lastTime + hitOffset) continue;

			FlxG.sound.play(Path.sound('hitsound'), note.data.data > 3 ? playerHitVolume : opponentHitVolume);
		}
	}

	function mouseInput():Void {
		if (!FlxG.mouse.overlaps(gridBG)) {
			selectedBox.setPosition(-FlxG.width, -FlxG.height);

			if (!FlxG.mouse.justPressed) return;

			selectedNote = null;
			selectedEvent = null;

			return;
		}

		var gridmult:Float = GRID_SIZE / (quants[curQuant] / 16);
		selectedBox.setPosition(Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE, Math.floor(FlxG.mouse.y / gridmult) * gridmult);

		//HACK: Hacky way to get an overlapped group, but it's less code so it will do for now...
		if (FlxG.mouse.justPressed) {
			var overlappedNote = getOverlapped(notes, byVisibleNote);
			overlappedNote != null ? selectedNote = overlappedNote.data : addNote();

			var overlappedEvent = getOverlapped(events, byVisibleEvent);
			overlappedEvent != null ? selectedEvent = overlappedEvent.data : addEvent();
		}

		if (FlxG.mouse.pressedRight) {
			var noteToRemove = getOverlapped(notes, byVisibleNote);
			if (noteToRemove != null) {
				removeNote(noteToRemove.data);
			}

			var eventToRemove = getOverlapped(events, byVisibleEvent);
			if (eventToRemove != null) {
				removeEvent(eventToRemove.data);
			}
		}
	}

	function getOverlapped<T:FlxBasic>(group:FlxTypedGroup<T>, filter:T -> Bool):T {
		if (!FlxG.mouse.overlaps(group)) return null;
		return group.members.find(item -> filter(item) && FlxG.mouse.overlaps(item));
	}

	function byVisibleNote(note:ChartNote):Bool {
		return note.isOnScreen();
	}

	function byVisibleEvent(event:ChartEvent):Bool {
		return event.isOnScreen();
	}

	function getYfromStrum(time:Float):Float {
		return FlxMath.remapToRange(time, 0, 16 * stepLength, gridBG.y, gridBG.y + (GRID_SIZE * 16));
	}

	function getStrumTime(y:Float):Float {
		return FlxMath.remapToRange(y, gridBG.y, gridBG.y + (GRID_SIZE * 16), 0, 16 * stepLength);
	}

	function get_time():Float {
		return conductor.time;
	}

	function set_time(value:Float):Float {
		conductor.time = value;

		for (val in [inst, voices, voicesOpponent, conductor.song]) {
			val.time = value;
		}
		return value;
	}
}

/**
	ok i think imma organize mah plans so i dont get lost in the sauce

	BUGS:
	- The song stops playing after it reaches the finish line.
	- Dispatched Events disappear from the Chart Editor after Playtesting the chart. [FIXED]

	TODOS:
	- Player/Opponent Icons [DONE]
	- Hit sounds [DONE]
	- Audio waveforms [GOAL] (https://github.com/ACrazyTown/flixel-waveform)
	- User Interface
	- Grid zooming
	- Support different Time signatures (глп)
	- Ability to import chart files
	- Ability to export chart files
	- Get rid of every instance of me using anonymous functions

	oh and also reorganize all this shit when its done so its under 1000 lines
**/