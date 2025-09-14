package states;

import flixel.effects.FlxFlicker;

class MainMenuState extends Scene {
	static var curSelected:Int = 0;

	static final options:Array<MenuItem> = [
		new MenuItem('storymode', goToState.bind(StoryMenuState)),
		new MenuItem('freeplay', goToState.bind(FreeplayState)),
		new MenuItem('credits', goToState.bind(CreditsState)),
		new MenuItem('options', goToState.bind(OptionsState))
	];

	var menuItems:Array<FlxSprite> = [];
	var magenta:FlxSprite;

	var versionText:FlxText;

	override function create():Void {
		final background:FlxSprite = new FlxSprite(Path.image('menuBG'));

		magenta = new FlxSprite(Path.image('menuBGMagenta'));
		magenta.visible = false;

		for (bg in [background, magenta]) {
			bg.scrollFactor.x = 0;
    		bg.scrollFactor.y = 0.17;
    		bg.setGraphicSize(Std.int(bg.width * 1.2));
			bg.updateHitbox();
    		bg.screenCenter();
		}

		add(background);
		add(magenta);

		final spacing:Float = 160;
		final top:Float = (FlxG.height - spacing * (options.length - 1)) * 0.5;

		for (i => item in options) {
			menuItems.push(new FlxSprite(0, top + spacing * i));
			menuItems[i].frames = Path.sparrow('mainmenu/${item.name}');
			menuItems[i].scrollFactor.set(0, 0.4);
			menuItems[i].animation.addByPrefix('idle', '${item.name} idle0');
			menuItems[i].animation.addByPrefix('selected', '${item.name} selected');
			menuItems[i].animation.play('idle');
			menuItems[i].updateHitbox();
			menuItems[i].screenCenter(X);
			add(menuItems[i]);
		}

		add(versionText = new FlxText(0, FlxG.height - 18, FlxG.width, 'Quazar Engine v${Constants.VERSION}'));
		versionText.setFormat(Path.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.scrollFactor.set();

		Key.onPress(Key.accept, onAccept);
		Key.onPress(Key.back, onBack);

		Key.onPress(Key.up, changeItem.bind(-1));
		Key.onPress(Key.down, changeItem.bind(1));

		changeItem();

		super.create();

		FlxG.camera.scroll.y = menuItems[curSelected].getGraphicMidpoint().y - 310;
	}

	function onAccept():Void {
		FlxG.sound.play(Path.sound('confirm'), 0.7);
		Controls.block = true;

		if (Data.flashingLights) {
			FlxFlicker.flicker(menuItems[curSelected], 1, 0.06, false, false, callMenuItemCallback);
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);
			return;
		}

		for (i => item in menuItems) {
			if (i == curSelected) continue;
			FlxTween.num(1, 0, 0.4, {ease: FlxEase.quadOut}, fadeItem.bind(item));
			FlxTimer.wait(1, options[curSelected].callback);
		}

	}

	function fadeItem(sprite:FlxSprite, value:Float):Void {
		sprite.alpha = value;
	}

	function onBack():Void {
		FlxG.sound.play(Path.sound('cancel'), 0.6);
		FlxG.switchState(new TitleState());
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		FlxG.camera.scroll.y = FlxMath.roundDecimal(Util.lerp(FlxG.camera.scroll.y, menuItems[curSelected].getGraphicMidpoint().y - 310, 5), 2);
	}

	static function goToState(state:Class<Scene>):Void {
		FlxG.switchState(Type.createInstance(state, []));
	}

	function callMenuItemCallback(_:FlxFlicker):Void {
		options[curSelected].callback();
	}

	function changeItem(dir:Int = 0):Void {
		if (dir != 0) {
			FlxG.sound.play(Path.sound('scroll'), 0.4);
		}

		curSelected = (curSelected + dir + menuItems.length) % menuItems.length;

		for (i => item in menuItems) {
			if (i == curSelected) {
				item.animation.play('selected');
				item.zIndex = 1;
			} else {
				item.animation.play('idle');
				item.zIndex = 0;
			}

			item.centerOffsets();
		}

		sort(Util.sortByZIndex);
	}
}

class MenuItem {
	public var name:String;
	public var callback:Void -> Void;

	public function new(name:String, callback:Void -> Void):Void {
		this.name = name;
		this.callback = callback;
	}
}