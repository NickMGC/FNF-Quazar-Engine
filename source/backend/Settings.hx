package backend;

@:structInit class DataVariables {
	//Gameplay
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;

	public var opponentNotes:Bool = true;
	public var ghostTapping:Bool = true;
	public var reset:Bool = true;

	public var safeFrames:Float = 0;

	//Controls
	public var keybinds:Map<String, Array<Int>> = Settings.getDefaultKeys();

	//Visual
	public var hideHud:Bool = false;
	public var flashingLights:Bool = true;
	public var cameraZooms:Bool = true;

	public var songOffset:Int = 0;

	public var comboOffsets:Array<Float> = [0, 0];

	//Graphics
	public var framerate:Int = 60;
	public var fullscrenType:String = 'Windowed';
	public var screenRes:String = '1280x720';

	public var antialiasing:Bool = true;
	public var gpuRendering:Bool = true;
	public var shaders:Bool = true;

	//Scores
	public var weekScores:Map<String, Int> = new Map();
	public var songScores:Map<String, Int> = new Map<String, Int>();
	public var songPercent:Map<String, Float> = new Map<String, Float>();

	public var completedWeeks:Map<String, Bool> = new Map();
}

class Settings {
	public static var Data:DataVariables = {};
	public static var DefaultData:DataVariables = {};

	public static function getDefaultKeys():Map<String, Array<Int>> {
		return [
			'left_note' => [LEFT, A],
			'down_note' => [DOWN, S],
			'up_note' => [UP, W],
			'right_note' => [RIGHT, D],

			'left' => [LEFT, A],
			'down' => [DOWN, S],
			'up' => [UP, W],
			'right' => [RIGHT, D],

			'accept' => [ENTER, SPACE],
			'back' => [BACKSPACE, ESCAPE],
			'pause' => [ENTER, ESCAPE],
			'reset' => [R, NONE],

			'volume_up' => [PLUS, NONE],
			'volume_down' => [MINUS, NONE],
			'mute' => [ZERO, NONE],

			'debug' => [SEVEN, NONE],
			'debug2' => [EIGHT, NONE]
		];
	}

	public static function save():Void {
		for (key in Reflect.fields(Data)) {
			Reflect.setField(FlxG.save.data, key, Reflect.field(Data, key));
		}
	}

	public static function load():Void {
		for (key in Reflect.fields(Data)) {
			if (Reflect.hasField(FlxG.save.data, key)) {
				Reflect.setField(Data, key, Reflect.field(FlxG.save.data, key));
			}
		}

		if (Data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = Data.framerate;
			FlxG.drawFramerate = Data.framerate;
		} else {
			FlxG.drawFramerate = Data.framerate;
			FlxG.updateFramerate = Data.framerate;
		}

		FlxSprite.defaultAntialiasing = Data.antialiasing;
	}
}