package states;

import flixel.util.FlxDestroyUtil;
import openfl.Assets;

typedef TitleMetadata = {bpm:Float, song:String}

class TitleState extends MusicScene {
	public static var metadata:TitleMetadata = Path.parseJSON((Path.json('images/title/metadata')));
	static var initialized:Bool = false;

	var ngSpr:FlxSprite;
	var logo:FlxSprite;
	var gf:FlxSprite;
	var titleText:FlxSprite;

	final randomPhrase:Array<String> = FlxG.random.getObject([for (phrase in Assets.getText(Path.txt('data/introText')).split('\n')) phrase.split('--')]);

	var text:Alphabet;

	override function create():Void {
		Path.clearStoredMemory();

		conductor.bpm = metadata.bpm;

		if (!initialized && FlxG.sound.music == null) {
			FlxG.sound.playMusic(Path.music(metadata.song), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.5);
		}

		add(gf = new FlxSprite(510, 50));
		gf.frames = Path.sparrow('title/gfTitle');
		gf.animation.addByPrefix('left', 'left', 24, false);
		gf.animation.addByPrefix('right', 'right', 24, false);
		gf.animation.play('left');

		add(logo = new FlxSprite(-140, -100));
		logo.frames = Path.sparrow('title/logo');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play('bump');

		add(titleText = new FlxSprite(137, 575));
		titleText.frames = Path.sparrow('title/titleText');
		titleText.animation.addByPrefix('idle', 'ENTER IDLE0', 24, false);
		titleText.animation.addByPrefix('press', 'ENTER PRESSED0', 24);
		titleText.animation.play('idle');

		add(ngSpr = new FlxSprite(0, 375, Path.image('title/newgrounds_logo')));
		ngSpr.setGraphicSize(ngSpr.frameWidth * 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		add(text = new Alphabet().setAlign(CENTER, FlxG.width));

		titleText.visible = logo.visible = gf.visible = ngSpr.active = ngSpr.visible = false;
		skipNextTransOut = !initialized;

		if (initialized) {
			onAccept();
		}

		Key.onPress(Key.accept, onAccept);

		super.create();

		Path.clearUnusedMemory();
	}

	var titleTimer:Float = 0;
	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.block) return;

		titleTimer = (titleTimer + elapsed) % 2;

		final timer = FlxEase.quadInOut(titleTimer >= 1 ? 2 - titleTimer : titleTimer);
		titleText.color = Util.lerpColor(0xFF33FFFF, 0xFF3333CC, timer);
		titleText.alpha = FlxMath.lerp(1, 0.65, timer);
	}

	override function onBeat():Void {
		super.onBeat();

		gf.animation.play(curBeat % 2 == 0 ? 'left' : 'right', true);
		logo.animation.play('bump', true);

		if (titleText.visible) return;

		switch curBeat {
			case 1: createText('quazar engine by', -90);
			case 3: addText('nickngc');
			case 4: deleteText();
			case 5: createText('not associated\nwith', -140);

			case 7:
				addText('newgrounds');
				ngSpr.visible = true;
			case 8:
				deleteText();
				ngSpr.visible = false;

			case 9: createText(randomPhrase[0], -90);
			case 11: addText(randomPhrase[1]);
			case 12: deleteText();
			case 13: createText('friday', -90);
			case 14: addText('night');
			case 15: addText('funkin');
			case 16: onAccept();
		}
	}

	inline function createText(string:String, ?offset:Float = 0):Void {
		text.text = string;
		text.screenCenter(Y);
		text.y += offset;
	}

	inline function addText(string:String):Void {
		text.text += '\n$string';
	}

	inline function deleteText():Void {
		text.y = FlxG.height; //lolol
	}

	function onAccept():Void {
		if (!titleText.visible) {
			if (!initialized) {
				FlxG.camera.flash(FlxColor.WHITE, 1);
			}

			for (obj in [text, ngSpr]) {
				obj = FlxDestroyUtil.destroy(obj);
			}

			initialized = titleText.visible = logo.visible = gf.visible = true;
			return;
		}

		Controls.block = true;

		FlxG.camera.stopFlash();
		FlxG.camera.flash(Data.flashingLights ? 0xFFFFFFFF : 0x45FFFFFF);
		FlxG.sound.play(Path.sound('confirm'), 0.7);

		titleText.animation.play('press');
		titleText.active = Data.flashingLights;
		titleText.color = FlxColor.WHITE;
		titleText.alpha = 1;

		FlxTimer.wait(1.5, FlxG.switchState.bind(new MainMenuState()));
	}
}