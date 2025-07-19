package;

import flixel.addons.ui.FlxUIState;

class Scene extends FlxUIState {
	var transitions:FlxSpriteGroup;

	override function create():Void {
		persistentUpdate = persistentDraw = true;

		super.create();

		add(transitions = new FlxSpriteGroup(2));
		transitions.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		if (!skipNextTransOut) {
			transitions.add(new Transition());
		}

		skipNextTransOut = false;

		Path.clearUnusedMemory();
	}

	override function startOutro(onOutroComplete:Void -> Void):Void {
		if (skipNextTransIn) {
			skipNextTransIn = false;
			return super.startOutro(onOutroComplete);
		}

		transitions.add(new Transition(true, onOutroComplete));
		transitions.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		Controls.block = true;
	}

	override function draw():Void {
		super.draw();
		transitions.draw();
	}
}