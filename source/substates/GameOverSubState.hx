package substates;

class GameOverSubState extends SubScene {
    var camFollow:FlxObject;
    var bf:Character;

    var isEnding:Bool = false;
    var moveCamera:Bool = false;

    override function create():Void {
		for (sound in [playField.inst, playField.playerStrum.voices, playField.opponentStrum.voices]) {
			sound?.stop();
		}

        FlxG.animationTimeScale = 1;

        game.bgColor = 0x00000000;
        game.persistentDraw = false;

        game.stage.bf.stunned = true;

        add(bf = new Character(game.stage.bf.getScreenPosition().x, game.stage.bf.getScreenPosition().y, game.stage.bf.character, true));
        bf.animation.onFinish.add(playLoop);
        bf.playAnim('firstDeath');

        FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));

		add(camFollow = new FlxObject(bf.getGraphicMidpoint().x + bf.cameraPosition[0], bf.getGraphicMidpoint().y + bf.cameraPosition[1], 1, 1));

        FlxG.sound.play(Path.sound('firstDeath'));

        super.create();

        Key.onPress(Key.accept, onAccept);
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

		if (bf.animation.curAnim.curFrame >= 12 && !moveCamera) {
			FlxG.camera.follow(camFollow, LOCKON, 0.6);
			moveCamera = true;
		}
    }

    function playLoop(name:String):Void {
        if (name != 'firstDeath') return;

        bf.playAnim('deathLoop', true);
        FlxG.sound.playMusic(Path.music('deathLoop'), 1);
    }

    function onAccept():Void {
        if (isEnding) return;

		isEnding = true;
		bf.playAnim('deathConfirm', true);
		FlxG.sound.music?.stop();
		FlxG.sound.play(Path.sound('deathConfirm'));

        FlxTimer.wait(0.7, FlxG.camera.fade.bind(FlxColor.BLACK, 2, false, FlxG.resetState));
	}
}