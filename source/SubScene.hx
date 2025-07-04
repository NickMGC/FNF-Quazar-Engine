package;

import flixel.FlxSubState;

class SubScene extends FlxSubState {
	var storedControls:Map<String, Map<Int, Array<Void -> Void>>> = [];
	var storedPressedKeys:Map<Int, Bool> = [];

	override function create():Void {
		for (i in ['press', 'hold', 'release']) {
			storedControls[i] = Controls.callbacks[i].copy();
			Controls.callbacks[i].clear();
		}

		storedPressedKeys = Controls.pressedKeys.copy();
		Controls.pressedKeys.clear();

		closeCallback = restoreControls;

		super.create();
	}

	function restoreControls():Void {
		for (i in ['press', 'hold', 'release']) {
			Controls.callbacks[i].clear();
			Controls.callbacks[i] = storedControls[i].copy();
		}

		Controls.pressedKeys.clear();
		Controls.pressedKeys = storedPressedKeys.copy();
	}
}