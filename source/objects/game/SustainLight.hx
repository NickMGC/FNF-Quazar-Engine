package objects.game;

import flixel.animation.FlxAnimation;

class SustainLight extends FlxSprite {
    var data:Int = 0;

    public var offsets:Map<String, Array<Float>> = new Map();

    public var initialWidth:Float;
    public var initialHeight:Float;

    public function new(data:Int = 0):Void {
		super();

        this.data = data;

        alpha = 0;

        blend = LIGHTEN;
	}

    public function loadSkin(skin:NoteSkinData):Void {
        var lightFrames = skin.getAtlas(skin.meta.lights);

        if (skin == null || frames == lightFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = lightFrames ?? frames;

        for (anim in skin.meta.lights.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.name, anim.prefix, anim.indices, '',
                    anim.fps == null ? skin.meta.lights.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.lights.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.name, anim.prefix,
                    anim.fps == null ? skin.meta.lights.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.lights.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.meta.lights.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.name, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set((skin.meta.sustainLightScale[0] ?? 1) * (skin.meta.scale[0] ?? 1), (skin.meta.sustainLightScale[1] ?? 1) * (skin.meta.scale[1] ?? 1));
		updateHitbox();

        playAnim('light ${Constants.DIRECTION[data % Constants.DIRECTION.length]}', true);

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}

        initialWidth = width;
        initialHeight = height;
	}

    public function start():Void {
        alpha = 1;
        playAnim('light ${Constants.DIRECTION[data % Constants.DIRECTION.length]}', true);
    }

    @:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set((offsets[name][0] ?? 0) * scale.x, (offsets[name][1] ?? 0) * scale.y);
	}
}