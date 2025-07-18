package states;

import flixel.FlxSubState;

class PlayState extends Scene {
	public static var game:PlayState;

	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var stage:BaseStage;
	public var playField:PlayField;

	public var camFollow:FlxObject;
	public static var prevCamFollow:FlxObject;

	public var defaultCamZoom:Float = 1;
	public var cameraSpeed:Float = 1;

	public var forceCameraPos:Bool = false;
	public var target:String;

	override public function create():Void {
		game = this;

		FlxG.cameras.add(camHUD = new FlxCamera(), false).bgColor = 0x00000000;
		FlxG.cameras.add(camOther = new FlxCamera(), false).bgColor = 0x00000000;

		add(playField = new PlayField(camHUD));
        add(stage = Stage.get(playField.chart.stage));

		playField.opponentStrum.character = stage.dad;
		playField.playerStrum.character = stage.bf;

		add(camFollow = new FlxObject(0, 0, 1, 1));
		moveCamera(stage.gf);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		FlxG.camera.follow(camFollow, 0);
		FlxG.camera.snapToTarget();
		FlxG.camera.followLerp = 2.4 * cameraSpeed;
		FlxG.camera.zoom = defaultCamZoom = stage.data.cameraZoom;

		moveCamera(stage.dad);

		playField.addBeatSignal(onBeat);
		playField.addStepSignal(onStep);
		playField.addMeasureSignal(onMeasure);

		super.create();

		stage.createPost();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (playField.paused) return;

		FlxG.camera.followLerp = 2.4 * cameraSpeed;

		if (playField.songStarted && !playField.songEnded) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125));
		}

		triggerEvents();
	}

	function triggerEvents():Void {
		if (playField.events == null || playField.events.length <= 0 || playField.conductor.time < playField.events[0].time) return;

		for (eventData in playField.events[0].events) {
        	Event.trigger(eventData.name, eventData.values);
        }

		playField.events.shift();
    }

	public function moveCamera(character:Character):Void {
		if (forceCameraPos) return;

		target = switch character {
			case(_ == stage.gf) => true: 'gf';
			case(_ == stage.dad) => true: 'dad';
			case(_ == stage.bf) => true: 'bf';
			default: 'invalid';
		};

		var xAdd:Float = target == 'gf' ? 0 : (target == 'dad' ? 150 : -150);

		camFollow.x = character.getMidpoint().x + character.cameraPosition[0] + character.cameraOffset[0] + xAdd;
		camFollow.y = character.getMidpoint().y + character.cameraPosition[1] + character.cameraOffset[1] - 100;
    }

	function onBeat():Void {
		if (playField.songEnded) return;

		for (char in [stage.bf, stage.dad, stage.gf]) {
			if (playField.curBeat % Math.round(char.speed * char.danceEveryNumBeats) != 0 || char.animation.curAnim.name.startsWith('sing')) continue;
			char.dance();
		}

		for (icon in [playField.healthBar.iconP1, playField.healthBar.iconP2]) {
			icon.scale.set(1.15, 1.15);
			icon.updateHitbox();
		}

		stage.onBeat();
	}

	function onStep():Void {
		if (playField.songEnded) return;
		stage.onStep();
	}

	function onMeasure():Void {
		if (playField.songEnded) return;

		if (playField.songStarted && FlxG.camera.zoom < 1.35) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		stage.onMeasure();
	}

	override function openSubState(SubState:FlxSubState):Void {
		super.openSubState(SubState);
		playField.togglePause(true);
	}

	override function closeSubState():Void {
		super.closeSubState();
		playField.togglePause(false);
	}

	override public function destroy():Void {
		super.destroy();

		game = null;

		playField.removeBeatSignal(onBeat);
		playField.removeStepSignal(onStep);
		playField.removeMeasureSignal(onMeasure);
	}
}