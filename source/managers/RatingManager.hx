package managers;

class RatingManager {
	public var score:Int = 0;
	public var accuracy:Float = 0;
	public var misses:Int = 0;
	public var combo:Int = 0;

	public var ratings:Array<Rating> = RatingManager.initRatings();

	public var totalPlayed:Int = 0;
	public var totalHit:Float;
	public var curRating:String = '?';
	public var percent:Float;

	public function new():Void {}

    public static function initRatings():Array<Rating> { //TODO: make this soft moddable
		return [
			Rating.add('Awful', 0.2),
			Rating.add('Shit', 0.4),
			Rating.add('Bad', 0.5),
			Rating.add('Mid', 0.6),
			Rating.add('Nice', 0.7),
			Rating.add('Good', 0.8),
			Rating.add('Great', 0.9),
			Rating.add('Sick', 1),
			Rating.add('Perfect', 1)
		];
	}

    public function recalculate():Void {
		if (totalPlayed == 0) return;

		percent = FlxMath.bound(totalHit / totalPlayed, 0, 1);

		curRating = ratings[ratings.length - 1].name;

		for (rat in ratings) {
			if (percent < rat.percent) {
				curRating = rat.name;
				break;
			}
    	}
	}

    public static function saveWeekScore(score:Int):Void {
		if (GameSession.botplay || GameSession.practiceMode) return;
		
		Data.completedWeeks.set(WeekData.weeks[GameSession.curWeek], true);
		Highscore.saveWeekScore(WeekData.weeks[GameSession.curWeek], GameSession.difficulty, GameSession.weekScore == 0 ? score : GameSession.weekScore);
		FlxG.save.data.completedWeeks = Data.completedWeeks;
		FlxG.save.flush();

		GameSession.weekScore = 0;
	}

	public static function saveFreeplayScore(score:Int, percent:Float):Void {
		if (GameSession.botplay || GameSession.practiceMode) return;
		Highscore.saveScore(GameSession.curSong, GameSession.difficulty, score, percent);
	}
}