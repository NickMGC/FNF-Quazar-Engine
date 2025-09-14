package objects.game;

import flixel.animation.FlxAnimation;

class SustainCover extends FlxSprite {
    var data:Int = 0;

    public var dir(get, default):String;
    function get_dir():String {
        return Constants.DIRECTION[data % Constants.DIRECTION.length];
    }

    public var offsets:Map<String, Array<Float>> = new Map();
    public var endSplash:Bool = false;

    public function new(data:Int = 0, endSplash:Bool = false):Void {
		super();

        this.data = data;
        this.endSplash = endSplash;

        animation.onFinish.add(onFinish);
        alpha = 0;
	}

    public function loadSkin(skin:NoteSkinData):Void {
        var coverFrames = skin.getAtlas(endSplash ? skin.meta.endSplashes : skin.meta.covers);

        if (skin == null || frames == coverFrames) return;

        var leData = endSplash ? skin.meta.endSplashes : skin.meta.covers;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = coverFrames ?? frames;

        for (anim in leData.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.name, anim.prefix, anim.indices, '',
                    anim.fps == null ? leData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? leData.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.name, anim.prefix,
                    anim.fps == null ? leData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? leData.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset:Array<Float> = anim.offsets == null ? leData.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.name, [leOffset[0], leOffset[1]]);
			}
		}

        var coverScale:Array<Float> = endSplash ? skin.meta.endSplashScale : skin.meta.holdCoverScale;

        scale.set((coverScale[0] ?? 1) * (skin.meta.scale[0] ?? 1), (coverScale[1] ?? 1) * (skin.meta.scale[1] ?? 1));
		updateHitbox();

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}
	}

    public function start():Void {
        alpha = 1;
        playAnim('start $dir', true);
    }

    function onFinish(name:String):Void {
        if (endSplash) {
            kill();
            return;
        }

        if (name != 'start $dir') return;
        playAnim('hold $dir', true);
	}

    public static function spawn(strum:StrumNote, data:Int, ?skinData:NoteSkinData):Void {
        if (skinData == null) {
            skinData = strum.strumline.skinData;
        }

        if (skinData.meta.hasSustainCovers) strum.strumline.sustainCovers[data % strum.strumline.sustainCovers.length].alpha = 0;
        if (skinData.meta.hasSparks) strum.strumline.sparks[data % strum.strumline.sparks.length].alpha = 0;

        if (skinData.meta.hasSustainLights) {
            var sustainLight = strum.strumline.sustainLights[data % strum.strumline.sustainLights.length];
            sustainLight.alpha = 0;
            sustainLight.scale.y = sustainLight.initialHeight / sustainLight.frameHeight;
        }

        if (!skinData.meta.hasSustainCovers) return;

        var endSplash:SustainCover = strum.strumline.endSplashes.recycle(SustainCover, newEndSplash);
        endSplash.endSplash = true;
        endSplash.alpha = 1;
        endSplash.loadSkin(skinData);
        endSplash.setPosition(strum.x + (strum.width - endSplash.width) * 0.5, strum.y + (strum.height - endSplash.height) * 0.5);
        endSplash.playAnim('end ${Constants.DIRECTION[data % Constants.DIRECTION.length]}', true);
        endSplash.camera = strum.camera;
    }

    @:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
        centerOrigin();

		if (offsets.exists(name)) {
			offset.set(
                (frameWidth - width) * 0.5 + ((offsets[name][0] ?? 0) * scale.x),
                (frameHeight - height) * 0.5 + ((offsets[name][1] ?? 0) * scale.y)
            );
		} else {
			centerOffsets();
		}
	}

    static function newEndSplash():SustainCover {
        return new SustainCover(true);
    }
}