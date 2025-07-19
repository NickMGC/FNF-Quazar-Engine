package substates;

class PauseSubState extends SubScene {
	var textItems:Array<Alphabet> = [];

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	override function create():Void {
		super.create();

		pauseMusic = new FlxSound().loadEmbedded(Path.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		add(new FlxSprite().makeGraphic(1280, 720, 0x60000000));

		for (i => item in menuItems) {
			textItems.push(new Alphabet(30, 262 + (i * 85), item, 0.9));
			add(textItems[i]);
		}

		Key.onPress(Key.accept, onAccept);
		Key.onPress(Key.back, close);
		Key.onPress(Key.up, changeItem.bind(-1));
		Key.onPress(Key.down, changeItem.bind(1));

		changeItem();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (pauseMusic.volume < 0.5) {
			pauseMusic.volume += 0.01 * elapsed;
		}
	}

	override function destroy():Void {
		pauseMusic.destroy();
		super.destroy();
	}

	function onAccept():Void {
		switch menuItems[curSelected] {
			case 'Resume':
				close();
			case 'Restart Song':
				FlxG.resetState();
			case 'Exit to menu':
				FlxG.sound.playMusic(Path.music('freakyMenu'), 0.5);
				FlxG.switchState(new MainMenuState());
		}
	}

	function changeItem(dir:Int = 0):Void {
		if (dir != 0) {
			FlxG.sound.play(Path.sound('scroll'), 0.4);
		}

		curSelected = (curSelected + dir + menuItems.length) % menuItems.length;

		for (i => item in textItems) {
			item.alpha = i == curSelected ? 1 : 0.6;
		}
	}
}