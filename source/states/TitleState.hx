package states;

import flixel.util.FlxDestroyUtil;
import openfl.Assets;

class TitleState extends MusicScene {
	var ngSpr:FlxSprite;
	var logo:FlxSprite;
	var gf:FlxSprite;
	var titleText:FlxSprite;

	final randomPhrase:Array<String> = FlxG.random.getObject([for (t in Assets.getText(Path.txt('introText')).split('\n')) t.split('--')]);

	var text:Alphabet;

	override function create():Void {
		Path.clearStoredMemory();

		conductor.bpm = 102;

		FlxG.sound.playMusic(Path.music('freakyMenu'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.5);

		add(gf = new FlxSprite(510, 20));
		gf.frames = Path.sparrow('title/title');
		gf.animation.addByPrefix('left', 'left', 24, false);
		gf.animation.addByPrefix('right', 'right', 24, false);
		gf.animation.play('left');
		gf.animation.finish();

		add(logo = new FlxSprite(-140, -100));
		logo.frames = Path.sparrow('title/title');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play('bump');
		logo.animation.finish();

		add(titleText = new FlxSprite(137, 575));
		titleText.frames = Path.sparrow('title/title');
		titleText.animation.addByPrefix('idle', 'ENTER IDLE0', 24, false);
		titleText.animation.addByPrefix('press', 'ENTER PRESSED0', 24);
		titleText.animation.play('idle');

		add(ngSpr = new FlxSprite(0, 375));
		ngSpr.frames = Path.sparrow('title/title');
		ngSpr.animation.addByPrefix('idle', 'newgrounds_logo', 0, false);
		ngSpr.animation.play('idle');
		ngSpr.setGraphicSize(ngSpr.frameWidth * 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		add(text = new Alphabet().setAlign(CENTER, 1280));

		titleText.visible = logo.visible = gf.visible = ngSpr.active = ngSpr.visible = false;
		skipNextTransOut = true;

		Key.onPress(Key.accept, onAccept);

		super.create();
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
			case 2: createText('quazar engine by', -90);
			case 4: addText('nickngc\niccer');
			case 5: deleteText();
			case 6: createText('not associated\nwith', -140);

			case 8:
				addText('newgrounds');
				ngSpr.visible = true;
			case 9:
				deleteText();
				ngSpr.visible = false;

			case 10: createText(randomPhrase[0], -90);
			case 12: addText(randomPhrase[1]);
			case 13: deleteText();
			case 14: createText('friday', -90);
			case 15: addText('night');
			case 16: addText('funkin');
			case 17: onAccept();
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
			camera.flash(FlxColor.WHITE, 1);

			for (obj in [text, ngSpr]) {
				obj = FlxDestroyUtil.destroy(obj);
			}

			titleText.visible = logo.visible = gf.visible = true;
			return;
		}

		Controls.block = true;

		camera.flash(Data.flashingLights ? FlxColor.WHITE : 0x4CFFFFFF, 1);
		FlxG.sound.play(Path.sound('confirm'), 0.7);

		titleText.animation.play('press');
		titleText.active = Data.flashingLights;
		titleText.color = FlxColor.WHITE;
		titleText.alpha = 1;

		FlxTimer.wait(1.5, FlxG.switchState.bind(new MainMenuState()));
	}
}