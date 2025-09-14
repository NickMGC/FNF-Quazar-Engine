package states;

class CreditsState extends Scene {
	static var curSelected:Int = 0;

	static final categories:Array<CreditCategory> = Path.parseJSON((Path.json('data/credits'))).credits;

	var credits:Array<DisplayCredit> = [];
	var desc:Alphabet;

	var curY:Float = 60;

	override function create():Void {
		add(UIUtil.background(0xFFea71fd));

		for (i => category in categories) {
			UIUtil.addHeader(category.name, curY, LEFT);

			curY += 50;

			for (data in category.credits) {
				credits.push(new DisplayCredit(data, curY += 50, i));
				add(credits[credits.length - 1]);
			}

			final lastCredit:DisplayCredit = credits[credits.length - 1];
			category.length = lastCredit.y + lastCredit.height + 170 - FlxG.height;

			curY += 110;
		}

		final descBG = UIUtil.background(0xFFea71fd);
		descBG.clipRect = new FlxRect(0, 630, 1280, 90);
		add(descBG);

		add(desc = new Alphabet(30, 630, '', 0.6, false));
		desc.scrollFactor.set();

		Key.onPress(Key.accept, onAccept);
		Key.onPress(Key.back, onBack);

		Key.onPress(Key.up, changeItem.bind(-1));
		Key.onPress(Key.down, changeItem.bind(1));

		changeItem();

		FlxG.camera.scroll.y = Util.bound(credits[curSelected].y - 170, 0, categories[credits[curSelected].index].length);

		super.create();
	}

	function onAccept():Void {
		FlxG.openURL(credits[curSelected].data.link);
	}

	function onBack():Void {
		FlxG.sound.play(Path.sound('cancel'), 0.6);
		FlxG.switchState(new MainMenuState());
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		FlxG.camera.scroll.y = FlxMath.roundDecimal(Util.lerp(FlxG.camera.scroll.y, Util.bound(credits[curSelected].y - 170, 0, categories[credits[curSelected].index].length), 10), 2);
	}

	function changeItem(dir:Int = 0):Void {
		if (dir != 0) {
			FlxG.sound.play(Path.sound('scroll'), 0.4);
		}

		curSelected = (curSelected + dir + credits.length) % credits.length;
		desc.text = credits[curSelected].data.desc;

		desc.fitToRect(0.6, 0.6, 1220, 80, LEFT).screenCenterIn(Y, FlxG.width, 90);
		desc.y += 630;

		for (i => credit in credits) {
			credit.text.alpha = i == curSelected ? 1 : 0.6;
		}
	}
}

typedef CreditData = {name:String, icon:String, desc:String, link:String}
typedef CreditCategory = {name:String, credits:Array<CreditData>, ?length:Float}

class DisplayCredit extends FlxSpriteGroup {
	public final data:CreditData;
	public final text:Alphabet;

	public var index:Int;

	public function new(data:CreditData, y:Float = 0, index:Int):Void {
		super(0, y);

		this.data = data;
		this.index = index;

		add(text = new Alphabet(135, 0, data.name, 0.7, false));

		var graphic = Path.image('credits/${data.icon}');
		if (graphic == null) graphic = Path.image('credits/face');

		add(new FlxSprite(145 + text.width, (text.height - graphic.height) * 0.5, graphic));
	}
}