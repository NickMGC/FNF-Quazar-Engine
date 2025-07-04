package backend;

import openfl.events.KeyboardEvent;

class Controls {
    public static var callbacks:Map<String, Map<Int, Array<Void -> Void>>> = ['press' => [], 'hold' => [], 'release' => []];
	public static var pressedKeys:Map<Int, Bool> = [];

    public static var block:Bool = true;

	public static var key:KeyAbstract;

    public static function init():Void {
		FlxG.signals.preStateSwitch.add(reset); 

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }

	@:noCompletion public static function reset():Void {
		for (type in ['press', 'hold', 'release']) {
			for (key in callbacks[type].keys()) {
				callbacks[type][key] = [];
			}
		}

		pressedKeys.clear();
	}

	@:noCompletion static function onKeyDown(event:KeyboardEvent):Void {
		if (block) return;

		if (callbacks['hold'].exists(event.keyCode)) {
			for (callback in callbacks['hold'][event.keyCode]) callback();
		}

		if (!pressedKeys[event.keyCode]) {
			if (callbacks['press'].exists(event.keyCode)) {
				for (callback in callbacks['press'][event.keyCode]) callback();
			}
			pressedKeys[event.keyCode] = true;
		}
	}

	@:noCompletion static function onKeyUp(event:KeyboardEvent):Void {
		pressedKeys[event.keyCode] = false;

		if (!block && callbacks['release'].exists(event.keyCode)) {
			for (callback in callbacks['release'][event.keyCode]) callback();
		}
	}

    public static function bind(type:String, keys:Array<Int>, callback:Void -> Void):Void {
		for (key in keys) {
			callbacks[type][key] = [callback];
    	}
	}
}

abstract KeyAbstract(Bool) {
	@:op(a.b) inline function resolve(name:String):Array<Int> {
		return Data.keybinds[name];
	}

	public inline function bind(type:String, key:Array<Int>, callback:Void -> Void):Void {
		Controls.bind(type, key, callback);
	}

	public inline function onPress(key:Array<Int>, callback:Void -> Void):Void {
		bind('press', key, callback);
	}

	public inline function onHold(key:Array<Int>, callback:Void -> Void):Void {
		bind('hold', key, callback);
	}

	public inline function onRelease(key:Array<Int>, callback:Void -> Void):Void {
		bind('release', key, callback);
	}
}