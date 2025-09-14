package states;

import substates.GameOverSubState;
import flixel.FlxSubState;

class PlayState extends MusicScene {
	public static var game:PlayState;

	public var song:SongManager = new SongManager();
	public var rating:RatingManager = new RatingManager();

	public var stage:BaseStage;
	public var ui:UI;

	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;
	public var camFollow:FlxObject;
	public static var lastCamFollow:FlxObject;

	public var cameraZoom:Float = 1;
	public var cameraSpeed:Float = 1;

	public var disableCamera:Bool = false;
	public var target:String;

	public var health(default, set):Float = 0.5;

    override public function create():Void {
		game = this;

		Path.clearStoredMemory();
		Path.preloadGameAssets(GameSession.uiSkin, GameSession.curSong);

		FlxG.cameras.add(camHUD = new FlxCamera(), false).bgColor = 0x00000000;
		FlxG.cameras.add(camOther = new FlxCamera(), false).bgColor = 0x00000000;

		FlxG.sound.music.stop();

		song.load(GameSession.curSong, GameSession.difficulty);
		conductor.bpm = song.chart.bpm;

		add(stage = Stage.get(song.chart.stage, song.chart.player1, song.chart.player2, song.chart.player3));
		add(ui = new UI(camHUD));

		initCamera();
		PlayerControls.init();

		super.create();

		Path.clearUnusedMemory();

		stage.createPost();
    }

	function initCamera():Void {
		add(camFollow = new FlxObject(0, 0, 1, 1));
		moveCamera(stage.gf);

		if (lastCamFollow != null) {
			camFollow = lastCamFollow;
			lastCamFollow = null;
		}

		FlxG.camera.follow(camFollow, 0);
		FlxG.camera.snapToTarget();
		FlxG.camera.followLerp = Constants.CAMERA_LERP * cameraSpeed;
		FlxG.camera.zoom = cameraZoom = stage.data.cameraZoom;

		moveCamera(stage.dad);

		for (character in [stage.bf, stage.gf, stage.dad]) {
			character.onAnimPlay.add(updateCamera);
		}
	}

	public function moveCamera(character:Character):Void {
		if (disableCamera) return;

		target = Util.getCharacterTarget(character);

    	var xAdd:Float = target == 'gf' ? 0 : 150 * (target == 'dad' ? 1 : -1);
    
    	var newX:Float = character.getMidpoint().x + character.cameraPosition[0] + character.cameraOffset[0] + xAdd;
    	var newY:Float = character.getMidpoint().y + character.cameraPosition[1] + character.cameraOffset[1] - 100;
    
    	if (camFollow.x == newX && camFollow.y == newY) return;
    	camFollow.setPosition(newX, newY);
    }

	function updateCamera(name:String):Void {
		if (disableCamera) return;
		moveCamera(Util.getCharacter(target));
	}

	override function onBeat():Void {
		if (song.ended) return;

		for (char in [stage.bf, stage.dad, stage.gf]) {
			char.onBeatHit(curBeat);
		}

		for (icon in [ui.iconP1, ui.iconP2]) {
			icon.onBeatHit();
		}

		stage.onBeat(curBeat);
	}

	override function onStep():Void {
		if (song.ended) return;
		stage.onStep(curStep);
	}

	override function onMeasure():Void {
		if (song.ended) return;

		if (Data.cameraZooms && song.started && FlxG.camera.zoom < 1.35) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		stage.onMeasure(curMeasure);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (song.paused) return;

		for (char in [stage.bf, stage.dad, stage.gf]) {
			char.stepLength = stepLength;
		}

		FlxG.camera.followLerp = Constants.CAMERA_LERP * cameraSpeed;

		if (song.started && !song.ended) {
			FlxG.camera.zoom = FlxMath.lerp(cameraZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125));
		}

		triggerEvents();
	}

	public function triggerEvents():Void {
		if (song.events == null || song.events.length <= 0 || conductor.time < song.events[0].time) return;

		for (eventData in song.events[0].events) {
        	Event.trigger(eventData.name, eventData.values);
        }

		song.events.shift();
    }

	override function openSubState(SubState:FlxSubState):Void {
		super.openSubState(SubState);
		song.togglePause(true);
	}

	override function closeSubState():Void {
		super.closeSubState();
		song.togglePause(false);
	}

	function prepareDeath():Void {
		openSubState(new GameOverSubState(ui.curStrumline.character));

		for (sound in [song.inst, song.voices, song.opponentVoices]) {
			sound?.stop();
		}

		GameSession.blueballs++;
        FlxG.camera.followLerp = 0;
	}

	function set_health(value:Float):Float {
		ui.healthBar.health = value = FlxMath.bound(value, 0, 1);

		if (value != 0 || GameSession.botplay || GameSession.practiceMode) return health = value;
		prepareDeath();

		return health = value;
	}

	override function destroy():Void {
		super.destroy();
		game = null;

		for (character in [stage.bf, stage.gf, stage.dad]) {
			character.onAnimPlay.remove(updateCamera);
		}
	}
}