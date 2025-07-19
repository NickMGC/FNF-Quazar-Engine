package states;

import flixel.effects.FlxFlicker;

class MainMenuState extends Scene {
	static var curSelected:Int = 0;

	static final options:Array<MenuItem> = [
		{name: 'storymode', state: PlayState},
		{name: 'freeplay', state: PlayState},
		{name: 'credits', state: PlayState},
		{name: 'options', state: PlayState}
	];

	var menuItems:Array<FlxSprite> = [];

	override function create():Void {
		add(new FlxSprite(Path.image('menuBG')));

		for (i => item in options) {
			menuItems.push(new FlxSprite(0, 90 + (140 * i)));
			menuItems[i].frames = Path.sparrow('main/buttons');

			for (anim in ['idle', 'selected']) {
				menuItems[i].animation.addByPrefix(anim, '${item.name} ${anim}0');
			}
	
			add(menuItems[i]);
		}

		Key.onPress(Key.accept, onAccept);

		Key.onPress(Key.up, changeItem.bind(-1));
		Key.onPress(Key.down, changeItem.bind(1));

		changeItem();

		super.create();
	}

	inline function goToState(_:FlxFlicker):Void {
		FlxG.switchState(Type.createInstance(options[curSelected].state, []));
	}

	function onAccept():Void {
		FlxG.sound.play(Path.sound('confirm'), 0.4);
		Controls.block = true;
		FlxFlicker.flicker(menuItems[curSelected], 1, 0.06, false, false, goToState);
	}

	function changeItem(dir:Int = 0):Void {
		if (dir != 0) {
			FlxG.sound.play(Path.sound('scroll'), 0.4);
		}

		curSelected = (curSelected + dir + menuItems.length) % menuItems.length;

		for (i => item in menuItems) {
			if (i == curSelected) {
				item.animation.play('selected');
				item.centerOffsets();
			} else {
				item.animation.play('idle');
				item.updateHitbox();
			}

			item.screenCenter(X);
		}
	}
}

typedef MenuItem = {name:String, state:Class<Scene>}