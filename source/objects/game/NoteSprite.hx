package objects.game;

import flixel.animation.FlxAnimation;

class NoteSprite extends FlxSprite {
	public var data:Int = 0;

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
	}

	public function loadSkin(skin:NoteSkinData):Void {
        if (skin == null || frames == skin.noteFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = skin.noteFrames ?? frames;

        for (anim in skin.noteData.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.anim, anim.name, anim.indices, "",
                    anim.fps == null ? skin.noteData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.noteData.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.anim, anim.name,
                    anim.fps == null ? skin.noteData.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.noteData.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.noteData.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.anim, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set(skin.noteData.scale[0] ?? 1, skin.noteData.scale[1] ?? 1);
		playAnim('note $dir');
		updateHitbox();

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set(offsets[name][0] ?? 0, offsets[name][1] ?? 0);
	}
}