package editors;

import flixel.addons.display.FlxGridOverlay;

//fuck idk how to code this, will recode this entirely
class ChartEditor extends MusicScene {
    public var chart:Chart;
    public var inst:FlxSound;
    public var voices:FlxSound;
    public var voicesOpponent:FlxSound;

    public var bgGrid:FlxSprite;
    public var gridGroup:FlxSpriteGroup;

    public function new(chart:Chart):Void {
        super();
        this.chart = chart;
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
			val.play(true);
            val.pause();
		}

        var bg:FlxSprite = new FlxSprite().loadGraphic(Path.image('menuDesat'));
        bg.color = 0xFF252525;
        bg.scrollFactor.set();
        add(bg);

        add(gridGroup = new FlxSpriteGroup());

        gridGroup.add(bgGrid = FlxGridOverlay.create(1, 1, 9, Std.int(inst.length / stepLength)));
        bgGrid.antialiasing = false;
        bgGrid.scale.set(40, 40);
        bgGrid.updateHitbox();

        for (i in 1...Std.int((inst.length / stepLength) - 1)) {
			gridGroup.add(new FlxSprite(bgGrid.x, (640 * i)).makeGraphic(320, 2, 0xFF000000));
		}

		gridGroup.add(new FlxSprite(320).makeGraphic(2, Std.int(bgGrid.height), FlxColor.BLACK));
        gridGroup.add(new FlxSprite(160).makeGraphic(2, Std.int(bgGrid.height), FlxColor.BLACK));

        for (note in chart.notes) {
            var spr = new NoteSprite(note.data);
            spr.setGraphicSize(40, 40);
            spr.updateHitbox();
            spr.setPosition(note.data * 40, note.time * 0.45);
            spr.animation.play('note${spr.dir}');
            gridGroup.add(spr);
        }

        gridGroup.y = 390;

        var spr:FlxSprite = new FlxSprite(0, 390).makeGraphic(360, 4, FlxColor.RED);
        spr.alpha = 0.5;
        spr.scrollFactor.set();
        add(spr);

        Key.onPress(Key.accept, playSong);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        FlxG.camera.scroll.y = conductor.time * 0.45;

        if (FlxG.mouse.wheel != 0) {
            var newTime:Float = Math.max(0, Math.min(conductor.time + (FlxG.mouse.wheel > 0 ? -stepLength : stepLength), inst.length));
            conductor.time = newTime;

            conductor.paused = true;

            for (val in [inst, voices, voicesOpponent]) {
                val.pause();
                conductor.time = val.time = newTime;
            }
		}
    }

    function playSong():Void {
        conductor.paused = !conductor.paused;

        for (val in [inst, voices, voicesOpponent]) {
			conductor.paused ? val.pause() : val.resume();
		}
    }
}