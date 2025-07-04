package backend;

@:structInit class DataVariables {
	//Gameplay
	public var downScroll:Bool = false;
	public var ghostTapping:Bool = true;
	public var reset:Bool = true;

	public var safeFrames:Float = 10;

	//Controls
	public var keybinds:Map<String, Array<Int>> = [
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
		'reset' => [R, NONE]
	];

	//Visual
	public var flashingLights:Bool = true;
	public var showFPS:Bool = true;

	public var offset:Int = 0;

	public var comboOffsets:Array<Float> = [0, 0];

	//Graphics
	public var framerate:Int = 60;

	public var antialiasing:Bool = true;
	public var gpuRendering:Bool = true;
	public var shaders:Bool = true;

	public var hitWindows:Array<Float> = [10, 40, 100, 135];
}

class Settings {
	public static var Data:DataVariables = {};
	public static var DefaultData:DataVariables = {};

	public static function save():Void {
		for (key in Reflect.fields(Data)) {
			Reflect.setField(FlxG.save.data, key, Reflect.field(Data, key));
		}

		FlxG.save.data.volume = FlxG.sound.volume;
		FlxG.save.data.muted = FlxG.sound.muted;
		FlxG.save.flush();
	}

	public static function load():Void {
		for (key in Reflect.fields(Data)) {
			if (Reflect.hasField(FlxG.save.data, key)) {
				Reflect.setField(Data, key, Reflect.field(FlxG.save.data, key));
			}
		}

		FlxG.sound.volume = FlxG.save.data.volume ?? 1;
		FlxG.sound.muted = FlxG.save.data.muted ?? false;

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