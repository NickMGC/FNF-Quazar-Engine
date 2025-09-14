package backend;

class GameSession {
    public static var songs:Array<String> = [];
	public static var curSong:String = songs[0];

	public static var difficulty:String = 'normal';
	public static var isStoryMode:Bool = false;
	public static var curWeek:Int = 0;

	public static var chartingMode:Bool = false;
	public static var skipCountdown:Bool = false;

	public static var botplay:Bool = false;
	public static var practiceMode:Bool = false;

	public static var weekScore:Int = 0;
	public static var blueballs:Int = 0;

	public static var uiSkin:String = 'default';

	public static function resetProperties():Void {
		curSong = '';
		isStoryMode = chartingMode = skipCountdown = botplay = practiceMode = false;
		blueballs = 0;
	}
}