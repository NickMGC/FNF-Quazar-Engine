package objects.game;

import flixel.animation.FlxAnimation;

class Spark extends FlxSprite {
    var data:Int = 0;

    public var offsets:Map<String, Array<Float>> = new Map();

    public function new(data:Int = 0):Void {
		super();

        this.data = data;

        alpha = 0;
	}

    public function loadSkin(skin:NoteSkinData):Void {
        var sparkFrames = skin.getAtlas(skin.meta.sparks);

		if (skin == null || frames == sparkFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = sparkFrames ?? frames;

        for (anim in skin.meta.sparks.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.name, anim.prefix, anim.indices, '',
                    anim.fps == null ? skin.meta.sparks.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.sparks.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.name, anim.prefix,
                    anim.fps == null ? skin.meta.sparks.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.sparks.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.meta.sparks.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.name, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set((skin.meta.sparkScale[0] ?? 1) * (skin.meta.scale[0] ?? 1), (skin.meta.sparkScale[1] ?? 1) * (skin.meta.scale[1] ?? 1));
		updateHitbox();

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}
	}

    public function start():Void {
        alpha = 1;
        playAnim('spark ${Constants.DIRECTION[data % Constants.DIRECTION.length]}', true);
    }

    @:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set((offsets[name][0] ?? 0) * scale.x, (offsets[name][1] ?? 0) * scale.y);
	}
}