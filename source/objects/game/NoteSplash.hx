package objects.game;

import flixel.animation.FlxAnimation;

class NoteSplash extends FlxSprite {
	public var strumline:Strumline;
	public var offsets:Map<String, Array<Float>> = new Map();

	public function new(strumline:Strumline):Void {
		super();

		this.strumline = strumline;

		animation.onFinish.add(killSpr);
		loadSkin(strumline.skinData);
	}

	public function loadSkin(skin:NoteSkinData):Void {
        if (skin == null || frames == skin.splashFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = skin.splashFrames ?? frames;

        for (anim in skin.splashData.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.anim, anim.name, anim.indices, "",
                    anim.fps == null ? skin.splashData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.splashData.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.anim, anim.name,
                    anim.fps == null ? skin.splashData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.splashData.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.splashData.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.anim, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set(skin.splashData.scale[0] ?? 1, skin.splashData.scale[1] ?? 1);
		updateHitbox();

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}
	}

	function killSpr(_:String):Void {
		kill();
	}

	public static function spawn(strum:StrumNote):Void {
		var splash:NoteSplash = strum.strumline.splashes.recycle(NoteSplash, newSplash.bind(strum.strumline));
		splash.loadSkin(strum.strumline.skinData);
		splash.setPosition(strum.x + (strum.width - splash.width) * 0.5, strum.y + (strum.height - splash.height) * 0.5);
		splash.playAnim('splash${FlxG.random.int(1, 2)} ' + Note.direction[strum.data % Note.direction.length]);
		splash.camera = strum.camera;
	}
	
	static function newSplash(strumline:Strumline):NoteSplash {
		return new NoteSplash(strumline);
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set(offsets[name][0] ?? 0, offsets[name][1] ?? 0);
	}
}