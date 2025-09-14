package substates;

//recode this menu, its so jank
class PauseSubState extends SubScene {
	var textItems:Array<Alphabet> = [];

	static final menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Toggle Practice Mode', 'Exit to menu'];
	var menuItems:Array<String> = menuItemsOG;

	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var background:FlxSprite;
	
	var metadataItems:Array<FlxText> = [];
	var metadataArtist:FlxText;
	var metadataDeaths:FlxText;
	var metadataPractice:FlxText;

	var changingDifficulty:Bool = false;

	override function create():Void {
		super.create();

		pauseMusic = new FlxSound().loadEmbedded(Path.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length * 0.5)));

		FlxG.sound.list.add(pauseMusic);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    	background.alpha = 0;
    	add(background);

		FlxTween.num(0, 0.6, 0.8, {ease: FlxEase.quartOut}, setAlpha);

		var metadataSong:FlxText = new FlxText(20, 15, FlxG.width - 40, Song.nameToDisplayName(GameSession.curSong));
        metadataArtist = new FlxText(20, metadataSong.y + 32, FlxG.width - 40, 'Artist: ${Song.nameToArtist(GameSession.curSong)}');
    	var metadataDifficulty:FlxText = new FlxText(20, metadataArtist.y + 32, FlxG.width - 40, 'Difficulty: ${Difficulty.nameToDisplayName(GameSession.difficulty, GameSession.curSong)}');
    	metadataDeaths = new FlxText(20, metadataDifficulty.y + 32, FlxG.width - 40, '${GameSession.blueballs} Blue Balls');
		metadataPractice = new FlxText(20, metadataDeaths.y + 32, FlxG.width - 40, 'PRACTICE MODE');
		metadataPractice.visible = GameSession.practiceMode;

		for (text in [metadataSong, metadataArtist, metadataDifficulty, metadataDeaths, metadataPractice]) {
			text.setFormat(Path.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
			text.alpha = 0;
			metadataItems.push(text);
    		add(text);
		}

		var delay:Float = 0.1;
    	for (i => text in metadataItems) {
			FlxTween.num(0, 1, 1.8, {ease: FlxEase.quartOut, startDelay: delay}, updateAlpha.bind(text));
			FlxTween.num(text.y, text.y + 5, 1.8, {ease: FlxEase.quartOut, startDelay: delay, onComplete: i == 1 ? startCharterTimer : null}, updateY.bind(text));
      		delay += 0.1;
    	}

		generateElements();

		Key.onPress(Key.accept, onAccept);
		Key.onPress(Key.back, close);
		Key.onPress(Key.up, changeItem.bind(-1));
		Key.onPress(Key.down, changeItem.bind(1));

		changeItem();
	}

	function generateElements():Void {
		curSelected = 0;
		for (item in textItems) {
			if (item == null) continue;
			remove(item);
			item.destroy();
		}

		textItems = [];

		for (i => item in menuItems) {
			textItems.push(new Alphabet(90, 360, item));
			textItems[i].isMenuItem = true;
			textItems[i].targetY = i - 1;
			textItems[i].snapToTarget();
			add(textItems[i]);
		}
	}

	var charterFadeTween:FlxTween;

	function changeToCharter(_:FlxTween):Void {
		metadataArtist.text = 'Charter: ${Song.nameToCharter(GameSession.curSong)}';
		FlxTween.num(metadataArtist.alpha, 1, 0.75, {ease: FlxEase.quartOut, onComplete: startArtistTimer}, updateAlpha.bind(metadataArtist));
	}

	function changeToArtist(_:FlxTween):Void {
		metadataArtist.text = 'Artist: ${Song.nameToArtist(GameSession.curSong)}';
		FlxTween.num(metadataArtist.alpha, 1, 0.75, {ease: FlxEase.quartOut, onComplete: startCharterTimer}, updateAlpha.bind(metadataArtist));
	}

	function startCharterTimer(_:FlxTween = null):Void {
		charterFadeTween = FlxTween.num(metadataArtist.alpha, 0, 0.75, {startDelay: 15, ease: FlxEase.quartOut, onComplete: changeToCharter}, updateAlpha.bind(metadataArtist));
	}

	function startArtistTimer(_:FlxTween):Void {
		charterFadeTween = FlxTween.num(metadataArtist.alpha, 0, 0.75, {startDelay: 15, ease: FlxEase.quartOut, onComplete: changeToArtist}, updateAlpha.bind(metadataArtist));
	}

	function updateAlpha(text:FlxText, value:Float):Void {
		text.alpha = value;
	}

	function updateY(text:FlxText, value:Float):Void {
		text.y = value;
	}

	function setAlpha(value:Float):Void {
		background.alpha = value;
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
		if (charterFadeTween != null) {
			charterFadeTween.cancel();
    		charterFadeTween = null;
		}
	}

	function onAccept():Void {
		if (changingDifficulty) {
			if (menuItems[curSelected] == 'Back') {
				changingDifficulty = false;
				menuItems = menuItemsOG;

				generateElements();
				changeItem();
				return;
			}

			GameSession.difficulty = Difficulty.displayNameToName(menuItems[curSelected], GameSession.curSong);
			FlxG.resetState();

			return;
		}

		switch menuItems[curSelected] {
			case 'Resume':
				close();
			case 'Restart Song':
				FlxG.resetState();
			case 'Change Difficulty':
				changingDifficulty = true;
				menuItems = [];

				for (diff in Song.get(GameSession.curSong).diff) {
            		menuItems.push(diff.displayName);
        		}

				menuItems.push('Back');

				generateElements();
				changeItem();
			case 'Toggle Practice Mode':
				GameSession.practiceMode = !GameSession.practiceMode;
				metadataPractice.visible = GameSession.practiceMode;
			case 'Exit to menu':
				FlxG.sound.playMusic(Path.music('freakyMenu'), 0.5);
				FlxG.switchState(GameSession.isStoryMode ? new StoryMenuState() : new FreeplayState());

				GameSession.resetProperties();
		}
	}

	function changeItem(dir:Int = 0):Void {
		if (dir != 0) {
			FlxG.sound.play(Path.sound('scroll'), 0.4);
		}

		curSelected = (curSelected + dir + menuItems.length) % menuItems.length;

		for (i => item in textItems) {
			item.targetY = i - curSelected;
			item.alpha = item.targetY == 0 ? 1 : 0.6;
		}
	}
}