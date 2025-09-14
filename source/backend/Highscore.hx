package backend;

class Highscore {
	public static function saveScore(song:String, diff:String, score:Int = 0, percent:Float = 0):Void {
		final key:String = key(song, diff);

		if (score <= getScore(song, diff)) return;

		Data.songScores.set(key, score);
		Data.songPercent.set(key, percent);

		FlxG.save.data.songScores = Data.songScores;
		FlxG.save.data.songPercent = Data.songPercent;
		FlxG.save.flush();
	}

	public static function resetScore(song:String, diff:String):Void {
		final key:String = key(song, diff);

		Data.songScores.set(key, 0);
		Data.songPercent.set(key, 0);

		FlxG.save.data.songScores = Data.songScores;
		FlxG.save.data.songPercent = Data.songPercent;
		FlxG.save.flush();
	}

	public static function saveWeekScore(week:String, diff:String, score:Int = 0):Void {
		final key:String = key(week, diff);

		if (score <= getWeekScore(week, diff)) return;

		Data.weekScores.set(key, score);

		FlxG.save.data.weekScores = Data.weekScores;
		FlxG.save.flush();
	}

	public static function resetWeekScore(week:String, diff:String):Void {
		final key:String = key(week, diff);

		Data.weekScores.set(key, 0);

		FlxG.save.data.weekScores = Data.weekScores;
		FlxG.save.flush();
	}

	public static function getScore(song:String, diff:String):Int {
		return getDefault(Data.songScores, key(song, diff)) ?? 0;
	}

	public static function getPercent(song:String, diff:String):Float {
		return getDefault(Data.songPercent, key(song, diff)) ?? 0;
	}

	public static function getWeekScore(week:String, diff:String):Int {
		return getDefault(Data.weekScores, key(week, diff)) ?? 0;
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null) {
			Data.songScores = FlxG.save.data.songScores;
		}

		if (FlxG.save.data.songPercent != null) {
			Data.songPercent = FlxG.save.data.songPercent;
		}

		if (FlxG.save.data.weekScores != null) {
			Data.weekScores = FlxG.save.data.weekScores;
		}
	}

	static function getDefault<T>(map:Map<String, T>, key:String):T {
		if (!map.exists(key)) return null;
		return map.get(key);
	}

	static inline function key(song:String, diff:String):String {
		return '$song-$diff';
	}
}