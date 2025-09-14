package managers;

//TODO: refactor the entire engine, this is so painful to work with :sob:
class SongManager {
    public var chart:Chart;
    public var events:Array<EventJSON> = [];

    public var inst:FlxSound;
    public var voices:FlxSound;
    public var opponentVoices:FlxSound;

    public var scrollSpeed:Float = 1;

    public var paused:Bool = false;
	public var started:Bool = false;
	public var ended:Bool = false;

    public var canResync:Bool = true;

    public function new():Void {}

    public function load(curSong:String, difficulty:String):Void {
        chart = GameSession.chartingMode ? ChartEditor.chart : Path.chart(curSong, difficulty);
        events = chart.events != null ? chart.events.copy() : [];

        scrollSpeed = chart.speed ?? 1;

        inst = Path.song('Inst', curSong);
        voices = Path.song('Voices-Player', curSong);
        opponentVoices = Path.song('Voices-Opponent', curSong);

        for (val in [inst, voices, opponentVoices]) {
            val?.play();
            val?.stop();
        }
    }

    public function start(conductor:Conductor):Void {
        for (val in [inst, voices, opponentVoices]) {
            val?.play();
        }

        conductor.time = 0;
        conductor.song = inst;
        conductor.song.onComplete = end;
        started = true;
    }

    public function togglePause(pause:Bool = true):Void {
        if (game == null) return;

		canResync = !pause;

		if (pause) {
			for (sound in [inst, voices, opponentVoices]) {
				sound?.pause();
			}

			FlxG.camera.followLerp = 0;
		} else {
			resyncVocals();
		}

		@:privateAccess for (tween in FlxTween.globalManager._tweens) if (!tween.finished) tween.active = !pause;
		@:privateAccess for (timer in FlxTimer.globalManager._timers) if (!timer.finished) timer.active = !pause;
		paused = game.conductor.paused = pause;
		game.persistentUpdate = !pause;
	}

    public function resyncVocals():Void {
        if (!started) return;

        inst.play();
        
        for (voices in [voices, opponentVoices]) {
            if (inst.time >= voices.length) {
                voices?.pause();
                break;
            }
            
            voices.time = inst.time;
            voices?.play();
        }
    }

    public function end():Void {
		if (GameSession.chartingMode) {
			FlxG.switchState(new ChartEditor());
			return;
		}

		if (GameSession.songs.length <= 0) return;

		GameSession.songs.shift();

		ended = true;
		canResync = false;

		if (GameSession.songs.length == 0) {
			FlxG.sound.music?.stop();
			FlxG.sound.playMusic(Path.music('freakyMenu'), 0.5);

            GameSession.resetProperties();

			if (GameSession.isStoryMode) {
				if (game != null) RatingManager.saveWeekScore(game.rating.score);
				FlxG.switchState(new StoryMenuState());
			} else {
				if (game != null) RatingManager.saveFreeplayScore(game.rating.score, game.rating.percent);
				FlxG.switchState(new FreeplayState());
			}

			return;
		}

        if (game != null) {
            GameSession.weekScore += GameSession.isStoryMode && (!GameSession.botplay || !GameSession.practiceMode) ? game.rating.score : 0;
		    PlayState.lastCamFollow = game.camFollow;
        }

		skipNextTransIn = skipNextTransOut = true;

		FlxG.switchState(new PlayState());
	}
}