package objects.game;

import flixel.animation.FlxAnimation;

class NoteSplash extends FlxSprite {
	public var offsets:Map<String, Array<Float>> = new Map();

	public function new():Void {
		super();

		animation.onFinish.add(killSpr);
	}

	public function loadSkin(skin:NoteSkinData):Void {
		var splashFrames = skin.getAtlas(skin.meta.splashes);

        if (skin == null || frames == splashFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = splashFrames ?? frames;

        for (anim in skin.meta.splashes.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.name, anim.prefix, anim.indices, '',
                    anim.fps == null ? skin.meta.splashes.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.splashes.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.name, anim.prefix,
                    anim.fps == null ? skin.meta.splashes.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.splashes.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.meta.splashes.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.name, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set((skin.meta.splashScale[0] ?? 1) * (skin.meta.scale[0] ?? 1), (skin.meta.splashScale[1] ?? 1) * (skin.meta.scale[1] ?? 1));
		updateHitbox();

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}
	}

	function killSpr(_:String):Void {
		kill();
	}

	public static function spawn(strum:StrumNote):Void {
		var splash:NoteSplash = strum.strumline.splashes.recycle(NoteSplash, newSplash);
		splash.loadSkin(strum.strumline.skinData);
		splash.setPosition(strum.x + (strum.width - splash.width) * 0.5, strum.y + (strum.height - splash.height) * 0.5);
		splash.playAnim('splash${FlxG.random.int(1, 2)} ' + Constants.DIRECTION[strum.data % Constants.DIRECTION.length]);
		splash.camera = strum.camera;
	}
	
	static function newSplash():NoteSplash {
		return new NoteSplash();
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set((offsets[name][0] ?? 0) * scale.x, (offsets[name][1] ?? 0) * scale.y);
	}
}