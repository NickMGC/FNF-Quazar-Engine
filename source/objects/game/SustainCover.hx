package objects.game;

import flixel.animation.FlxAnimation;

class SustainCover extends FlxSprite {
    var data:Int = 0;

    public var dir(get, default):String;
    function get_dir():String {
        return Note.direction[data % Note.direction.length];
    }

    public var offsets:Map<String, Array<Float>> = new Map();
    public var strumline:Strumline;

    public function new(data:Int = 0, strumline:Strumline):Void {
		super();

        this.data = data;
        this.strumline = strumline;

        loadSkin(strumline.skinData);
        animation.onFinish.add(onFinish);
        alpha = 0;
	}

    public function loadSkin(skin:NoteSkinData):Void {
        if (skin == null || frames == skin.coverFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = skin.coverFrames ?? frames;

        for (anim in skin.coverData.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.anim, anim.name, anim.indices, "",
                    anim.fps == null ? skin.coverData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.coverData.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.anim, anim.name,
                    anim.fps == null ? skin.coverData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.coverData.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.noteData.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.anim, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set(skin.coverData.scale[0] ?? 1, skin.coverData.scale[1] ?? 1);
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
        if (name != 'start $dir') return;
        playAnim('hold $dir', true);
	}

    public static function spawn(strum:StrumNote, data:Int):Void {
        strum.strumline.sustainCovers[data % strum.strumline.sustainCovers.length].alpha = 0;

        var sustainCover:SustainCover = strum.strumline.endSplashes.recycle(SustainCover, newSustainCover.bind(strum.strumline));
        sustainCover.alpha = 1;
        sustainCover.loadSkin(strum.strumline.skinData);
        sustainCover.setPosition(strum.x + (strum.width - sustainCover.width) * 0.5, strum.y + (strum.height - sustainCover.height) * 0.5);
        sustainCover.playAnim('end ${Note.direction[data % Note.direction.length]}', true);
        sustainCover.animation.onFinish.add(killSustain.bind(sustainCover));
        sustainCover.camera = strum.camera;
    }

    @:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set(offsets[name][0] ?? 0, offsets[name][1] ?? 0);
	}

    static function killSustain(sustainCover:SustainCover, anim:String):Void {
        sustainCover.kill();
    }

    static function newSustainCover(strumline:Strumline):SustainCover {
        return new SustainCover(strumline);
    }
}