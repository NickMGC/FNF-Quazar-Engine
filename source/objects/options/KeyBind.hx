package objects.options;

class KeyBind {
    public var name:String;
    public var type:BindKind;

    public var bindName:String;
    public var bind:Array<Int>;
    public var bindCallback:Void -> Void;

    public var offset:Float;

    public function new(name:String, type:BindKind, ?bind:Array<Int>, ?bindCallback:Void -> Void):Void {
        this.name = name;
        this.type = type;

        if (bind != null) {
            this.bind = bind;
            bindName = Data.keybinds.keyForValue(bind);
        }

        if (bindCallback != null) this.bindCallback = bindCallback;
    }

    public function addSpacing(offset:Float = 50):KeyBind {
        this.offset = offset;
        return this;
    }

    public static function add(name:String, bind:Array<Int>):KeyBind {
        return new KeyBind(name, KEYBIND, bind);
    }

    public static function callback(name:String, bindCallback:Void -> Void):KeyBind {
        return new KeyBind(name, CALLBACK, bindCallback);
    }

    public static function category(name:String, keyBinds:Array<KeyBind>):KeyBindCategory {
        return {name: name, keyBinds: keyBinds};
    }
}

typedef KeyBindCategory = {name:String, keyBinds:Array<KeyBind>}

class DisplayKeyBind extends FlxSpriteGroup {
    public var bind:KeyBind;

    public var label:Alphabet;
	public var firstKey:Alphabet;
    public var secondKey:Alphabet;

    public function new(bind:KeyBind, y:Float = 0):Void {
		super(0, y);

		this.bind = bind;

		add(label = new Alphabet(135, 0, bind.name, 0.7, false));

        if (bind.type != KEYBIND) return;

        add(firstKey = new Alphabet(595, 0, bind.bind == null ? 'fuck' : Util.displayKey(bind.bind[0]), 0.7, false).setAlign(RIGHT, 500));
        add(secondKey = new Alphabet(795, 0, bind.bind == null ? 'fuck' : Util.displayKey(bind.bind[1]), 0.7, false).setAlign(RIGHT, 500));
	}

    public function highlight(selected:Bool, keyIndex:Int = 0):Void {
        label.alpha = selected ? 1 : 0.6;

        if (bind.type != KEYBIND) return;

        firstKey.alpha = (selected && keyIndex == 0) ? 1 : 0.6;
        secondKey.alpha = (selected && keyIndex == 1) ? 1 : 0.6;
    }

    public function updateBind():Void {
        if (bind.type != KEYBIND) return;

        bind.bind = Data.keybinds[bind.bindName];

        firstKey.text = bind.bind == null ? 'fuck' : Util.displayKey(bind.bind[0]);
        secondKey.text = bind.bind == null ? 'fuck' : Util.displayKey(bind.bind[1]);
    }
}

enum BindKind {
    KEYBIND;
    CALLBACK;
}