package;

import flixel.addons.display.FlxBackdrop;

class Scene extends FlxState {
	var transitions:FlxSpriteGroup;

	override function create():Void {
		persistentUpdate = persistentDraw = true;

		super.create();

		add(transitions = new FlxSpriteGroup(2));
		transitions.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		if (!skipNextTransOut) {
			transitions.add(new Transition());
		}

		skipNextTransOut = Controls.block = false;

		Path.clearUnusedMemory();
	}

	override function startOutro(onOutroComplete:Void -> Void):Void {
		if (skipNextTransIn) {
			skipNextTransIn = false;
			return super.startOutro(onOutroComplete);
		}

		transitions.add(new Transition(true, onOutroComplete));
		transitions.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		Controls.block = true;
	}

	override function draw():Void {
		super.draw();
		transitions.draw();
	}
}

class Transition extends FlxBackdrop {
    var callback:Void -> Void;

	var leTween:FlxTween;
	public function new(transIn:Bool = false, callback:Void -> Void = null):Void {
		super(Path.image('transition'), Y);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		scale.set(scale.x / camera.zoom, scale.y / camera.zoom);
		scrollFactor.set();
		this.callback = callback;

		final center:Float = (FlxG.width - width) / 2;
		final offscreen:Float = width / camera.zoom;

		if (transIn) {
			leTween = FlxTween.num(offscreen, center, 0.3, {ease: FlxEase.circIn, onComplete: finish}, updatePosition);
		} else {
			leTween = FlxTween.num(center, -offscreen, 0.3, {ease: FlxEase.circOut, onComplete: finish, startDelay: 0.1}, updatePosition);
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		leTween.active = true;
	}

	inline function updatePosition(value:Float):Void {
		this.x = value;
	}

	inline function finish(_:FlxTween):Void {
		if (callback == null) {
			destroy();
			return;
		}
		callback();
	}
}