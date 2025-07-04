package backend;

class Conductor {
	public var song(default, set):FlxSound;
	public var bpm(default, set):Float = 100;

	public var step:Timing = new Timing();
	public var beat:Timing = new Timing();
	public var measure:Timing = new Timing();

	public var time:Float = 0;

	public var numerator(default, set):Float = 4;
	public var denominator(default, set):Float = 4;

	public var paused:Bool = false;

	inline public function new():Void {}

	inline public function set_bpm(value:Float):Float {
		step.length = 15000 / value;
		beat.length = step.length * numerator;
		measure.length = beat.length * denominator;
		return bpm = value;
	}

	inline public function setTimeSignature(newNumerator:Float = 4, newDenominator:Float = 4):Void {
		numerator = newNumerator;
		denominator = newDenominator;
	}

	public function set_numerator(value:Float):Float {
		beat.length = step.length * value;
		return numerator = value;
	}

	public function set_denominator(value:Float):Float {
		measure.length = beat.length * value;
		return denominator = value;
	}

	public function update(elapsed:Float):Void {
		if (paused) return;

		time += 1000 * elapsed;

		if (song?.playing && Math.abs(time - song.time) >= 25) {
			time = song.time;
		}

		for (timing in [step, beat, measure]) {
			timing.last = timing.cur;
			timing.curDec = (time - Data.offset) / timing.length;

			if (timing.last != timing.cur) {
				timing.signal.dispatch();
			}
		}
	}

	@:noCompletion function set_song(val:FlxSound):FlxSound {
		return song = val ?? FlxG.sound.music ?? null;
	}

	inline public function reset():Void {
		time = 0;
		bpm = 100;
		setTimeSignature(4, 4);

		for (timing in [step, beat, measure]) {
			timing.curDec = timing.last = 0;
		}
	}
}

class Timing {
	public var signal:FlxSignal = new FlxSignal();
	public var length:Float;

	public var last:Int;
	public var cur(get, default):Int;
	function get_cur():Int return Math.floor(curDec);

	public var curDec:Float;

	inline public function new():Void {}
}