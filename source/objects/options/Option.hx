package objects.options;

class Option {
    public final name:String;
    public final desc:String;
    public final type:String;

	public var offset:Float;

	public var value(get, default):String;

    public function new(name:String, desc:String = '', type:String):Void {
        this.name = name;
        this.desc = desc;
        this.type = type;
    }

    public function updateValue(dir:Int = 0):Void {}

	public function addSpacing(offset:Float = 50):Option {
		this.offset = offset;
		return this;
	}

	function get_value():String {
        return value;
    }

	public static function bool(name:String, desc:String, value:Bool, callback:Bool -> Void):BoolOption {
		return new BoolOption(name, desc, value, callback);
	}

	public static function int(name:String, desc:String, value:Int, callback:Int -> Void):IntOption {
		return new IntOption(name, desc, value, callback);
	}

	public static function float(name:String, desc:String, value:Float, callback:Float -> Void):FloatOption {
		return new FloatOption(name, desc, value, callback);
	}

	public static function percent(name:String, desc:String, value:Float, callback:Float -> Void):PercentOption {
		return new PercentOption(name, desc, value, callback);
	}

	public static function string(name:String, desc:String, value:String, options:Array<String>, callback:String -> Void):StringOption {
		return new StringOption(name, desc, value, options, callback);
	}

	public static function state(name:String, desc:String, value:Class<Scene>):StateOption {
		return new StateOption(name, desc, value);
	}

	public static function category(name:String, options:Array<Option>):OptionCategory {
		return {name: name, options: options};
	}
}

class BaseOption<T> extends Option {
    public var callback:T -> Void;
    var _value:T;

    public function new(name:String, desc:String, _value:T, callback:T -> Void, type:String):Void {
        super(name, desc, type);

        this.callback = callback;
        this._value = _value;
    }

    override function get_value():String {
        return '$_value';
    }
}

typedef OptionCategory = {name:String, options:Array<Option>, ?length:Float}

class DisplayOption extends FlxSpriteGroup {
	public var option:Option;

	public var label:Alphabet;
	public var value:Alphabet;

	public var checkbox:FlxSprite;

	public var index:Int;

	public function new(option:Option, y:Float = 0, id:Int, index:Int):Void {
		super(0, y);

		this.option = option;
		this.ID = id;
		this.index = index;

		add(label = new Alphabet(135, 0, option.name, 0.7, false));

		switch option.type {
			case 'bool':
				add(checkbox = new FlxSprite(1110, -2));
				checkbox.frames = Path.sparrow('options/checkbox');
				checkbox.animation.addByPrefix('true', 'true', 0, false);
				checkbox.animation.addByPrefix('false', 'false', 0, false);
				checkbox.animation.play(option.value);
			case 'float' | 'int' | 'percent' | 'string':
				add(value = new Alphabet(795, 0, option.value, 0.7, false).setAlign(RIGHT, 500));
		}
	}

	public function updateValue(dir:Int = 0):Void {
		option.updateValue(dir);
		FlxG.sound.play(Path.sound('scroll'), 0.4);

		switch option.type {
			case 'bool':
				checkbox.animation.play(option.value);
			case 'float' | 'int' | 'percent' | 'string':
				value.text = option.value;
		}
	}
}