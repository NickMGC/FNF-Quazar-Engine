package objects.options;

import objects.options.Option.BaseOption;

class StateOption extends Option {
	var _value:Class<Scene>;

	public function new(name:String, desc:String, _value:Class<Scene>):Void {
		super(name, desc, 'state');
		this._value = _value;
	}

	override public function updateValue(dir:Int = 0):Void {
		FlxG.switchState(Type.createInstance(_value, []));
	}
}