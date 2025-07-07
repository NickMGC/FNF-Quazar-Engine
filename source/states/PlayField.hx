package states;

import editors.ChartEditor;
import substates.GameOverSubState;
import flixel.util.FlxStringUtil;
import haxe.ds.ArraySort;
import objects.game.HeathBar;

class PlayField extends MusicState {
	public static var instance:PlayField;

	public static var songs:Array<String> = ['Puns', 'Test'];
	public static var difficulty:String = 'normal';
	public static var isStoryMode:Bool = false;

	public static var _chart:Bool = false;

	public var curSong:String = songs[0];

	public var paused:Bool = false;
	public var songEnded:Bool = false;
	public var songStarted:Bool = false;
	public var skipCountdown:Bool = false;

	public var inst:FlxSound;

	public var scrollSpeed:Float = 1;
    public var bpm:Float;
	public var score(default, set):Int = 0;
	public var accuracy:Float = 0;
	public var misses:Int = 0;
	public var combo:Int = 0;
	public var health(default, set):Float = 0.5;

	public var ratings:Array<{name:String, value:Float}> = [//TODO: make this a typedef
	    {name: 'Awful', value: 0.2},
	    {name: 'Shit', value: 0.4},
	    {name: 'Bad', value: 0.5},
	    {name: 'Mid', value: 0.6},
	    {name: 'Nice', value: 0.7},
	    {name: 'Good', value: 0.8},
	    {name: 'Great', value: 0.9},
	    {name: 'Sick', value: 1},
		{name: 'Perfect', value: 1}
	];

	public var totalPlayed:Int = 0;
	public var totalHit:Float;

	public var rating:String = '?';
	public var ratingPercent:Float;

	public var chart:Chart;

    public var playerStrum:Strumline;
	public var opponentStrum:Strumline;

	public var canResync:Bool = true;

	public var healthBar:HealthBar;
	public var scoreText:BitmapText;
    public var comboGroup:FlxSpriteGroup;

	public var events:Array<EventJSON> = [];

    public function new(camera:FlxCamera):Void {
        super();

		Path.preloadAudios(['three:sounds', 'two:sounds', 'one:sounds', 'go:sounds', 'firstDeath:sounds', 'deathLoop:music', 'deathConfirm:sounds', 'breakfast:music', 'songs/$curSong/Inst', 'songs/$curSong/Voices-Player', 'songs/$curSong/Voices-Opponent']);
		Path.preloadImages(['healthBar', 'rating', 'countdown']);

		for (i in 1...3) {
			Path.preloadAudio('miss$i:sounds');
		}

		instance = this;

		add(opponentStrum = new Strumline(50, FlxG.height * (Data.downScroll ? 0.75 : 0.075), camera, true));
		add(playerStrum = new Strumline(0, opponentStrum.y, camera));
        playerStrum.x = FlxG.width - playerStrum.width - 50;

		loadSong(curSong, difficulty);
		PlayerInput.init();

		add(healthBar = new HealthBar(Data.downScroll ? FlxG.height * 0.15 : FlxG.height * 0.85));

        add(scoreText = new BitmapText(0, healthBar.y + 40, 'vcr', 'Score: 0 • Misses: 0 • Rating: ?'));
        scoreText.setFormat('vcr', 0.9, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreText.setAlign(CENTER, camera.width);
		scoreText.screenCenter(X);
        scoreText.borderSize = 2;

        add(comboGroup = new FlxSpriteGroup());

		this.camera = camera;

		skipCountdown ? startSong() : add(new Countdown());
    }

	function set_score(value:Int):Int {
		scoreText.text = 'Score: ${FlxStringUtil.formatMoney(value, false, true)} • Misses: $misses • Rating: $rating - ${FlxMath.roundDecimal(FlxMath.bound(ratingPercent * 100, 0, 100), 2)}%';
		return score = value;
	}

	public function recalculateRating():Void {//couldn't bother making my own ratings, just yoinked from psych (eww)
		if(totalPlayed == 0) return;

		ratingPercent = Math.min(1, Math.max(0, totalHit / totalPlayed));

		rating = ratings[ratings.length - 1].name;

		for (rat in ratings) {
			if (ratingPercent < rat.value) {
        		rating = rat.name;
        		break;
			}
    	}
	}

	function set_health(value:Float):Float {
		value = FlxMath.bound(value, 0, 1);

		if (game != null && value == 0) {
			game.openSubState(new GameOverSubState());
		}

		for (i => icon in [healthBar.iconP1, healthBar.iconP2]) {
			icon.animation.curAnim.curFrame = (i == 0 ? (health < 0.2) : (health > 0.8)) ? 1 : 0;
		}

		return health = value;
	}

	public function startSong():Void {
		for (val in [inst, playerStrum.voices, opponentStrum.voices]) {
			val.play(true);
		}

		songStarted = true;

		conductor.time = 0;

		conductor.song = inst;
		conductor.song.onComplete = endSong;
	}
	
	public function endSong():Void {
		if (songs.length > 0) {
			songs.shift();

			songEnded = true;
			canResync = false;

			if (game == null) return;

			if (songs.length == 0) {
				// FlxG.switchState(isStoryMode ? StoryModeState.new : FreeplayState.new);
			} else {
				PlayState.prevCamFollow = game.camFollow;
				skipNextTransIn = skipNextTransOut = true;
				FlxG.switchState(PlayState.new);
			}
		}
	}

	public function loadSong(curSong:String, difficulty:String):Void {
        if (!_chart) {
			chart = Path.chart(curSong, difficulty);
		} else {
			chart = ChartEditor.chart;
		}

		events = chart.events.copy();

		inst = Path.song('Inst', curSong);
		playerStrum.voices = Path.song('Voices-Player', curSong);
		opponentStrum.voices = Path.song('Voices-Opponent', curSong);

		scrollSpeed = chart.speed ?? 1;
		conductor.bpm = chart.bpm;

		var notes:Map<String, NoteJSON> = [];

		for (note in chart.notes) {
			var hash:String = '${note.data}_${note.time}';
			if (!notes.exists(hash)) {
				notes.set(hash, note);
				(note.data > 3 ? playerStrum : opponentStrum).noteData.push(note);
			}
		}

		notes.clear();

		for (strumline in [opponentStrum, playerStrum]) {
			ArraySort.sort(strumline.noteData, sortByTime);
		}
	}

    function sortByTime(a:NoteJSON, b:NoteJSON):Int {
		return (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0));
	}

	public function togglePause(pause:Bool = true):Void {
		canResync = !pause;

		if (pause) {
			for (sound in [inst, playerStrum.voices, opponentStrum.voices]) {
				sound?.pause();
			}

			for (note in playerStrum.strums) {
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static') {
					note.resetAnim();
				}
			}

			FlxG.camera.followLerp = 0;
		} else {
			resyncVocals();
		}

		@:privateAccess for (tween in FlxTween.globalManager._tweens) if (!tween.finished) tween.active = !pause;
		@:privateAccess for (timer in FlxTimer.globalManager._timers) if (!timer.finished) timer.active = !pause;
		paused = conductor.paused = pause;
		if (game != null) game.persistentUpdate = !pause;
	}

	public function resyncVocals():Void { //Resync logic taken from psych
		if (!songStarted || !canResync) return;

		inst.play();

		for (voices in [playerStrum.voices, opponentStrum.voices]) {
			if (inst.time < voices.length) {
				voices.time = inst.time;
				voices?.play();
			} else {
				voices?.pause();
			}
		}
	}

	override function destroy():Void {
		super.destroy();
		instance = null;
	}
}