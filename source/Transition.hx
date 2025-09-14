package;

import flixel.addons.display.FlxBackdrop;

class Transition extends FlxBackdrop {
    var callback:Void -> Void;
	var transitionTween:FlxTween;

	public function new(transIn:Bool = false, callback:Void -> Void = null):Void {
		super(Path.image('misc/transition'), Y);

		this.callback = callback;

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		scale.set(scale.x / camera.zoom, scale.y / camera.zoom);
		updateHitbox();

		scrollFactor.set();

		final center:Float = (FlxG.width - width) * 0.5;
		final offscreen:Float = width / camera.zoom;
		final duration:Float = Data.flashingLights ? 0.3 : 0.5;

		if (transIn) {
			transitionTween = FlxTween.num(offscreen, center, duration, {ease: Data.flashingLights ? FlxEase.circIn : FlxEase.quadIn, onComplete: finish}, updatePosition);
		} else {
			transitionTween = FlxTween.num(center, -offscreen, duration, {ease: Data.flashingLights ? FlxEase.circOut : FlxEase.quadOut, onComplete: finish, startDelay: 0.1}, updatePosition);
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		transitionTween.active = true;
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