package objects.game;

import flixel.animation.FlxAnimation;

class NoteSprite extends FlxSprite {
	public var data:Int = 0;

	public var dir(get, default):String;
    function get_dir():String {
        return Constants.DIRECTION[data % Constants.DIRECTION.length];
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
		var noteFrames = skin.getAtlas(skin.meta.notes);

		if (skin == null || frames == noteFrames) return;

		var lastAnim:FlxAnimation = null;
		var lastAnimName:String = null;

		if (animation.curAnim != null) {
			lastAnim = animation.curAnim;
			lastAnimName = animation.name;
		}

		frames = noteFrames ?? frames;

        for (anim in skin.meta.notes.animations) {
		    if (anim.indices != null && anim.indices.length > 0) {
		    	animation.addByIndices(anim.name, anim.prefix, anim.indices, '',
                    anim.fps == null ? skin.meta.notes.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.notes.globalAnimData.loop ?? false : anim.loop
                );
		    } else {
		    	animation.addByPrefix(anim.name, anim.prefix,
                    anim.fps == null ? skin.meta.notes.globalAnimData.fps ?? 24 : anim.fps,
                    anim.loop == null ? skin.meta.notes.globalAnimData.loop ?? false : anim.loop
                );
		    }

            var leOffset = anim.offsets == null ? skin.meta.notes.globalAnimData.offsets : anim.offsets;

		    if (leOffset != null) {
				offsets.set(anim.name, [leOffset[0], leOffset[1]]);
			}
		}

		scale.set((skin.meta.noteScale[0] ?? 1) * (skin.meta.scale[0] ?? 1), (skin.meta.noteScale[1] ?? 1) * (skin.meta.scale[1] ?? 1));
		playAnim('note $dir');
		updateHitbox();

        if (lastAnim != null) {
			playAnim(lastAnimName, true, lastAnim.reversed, lastAnim.curFrame);
		}
	}

	@:inheritDoc(flixel.animation.FlxAnimationController.play)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		animation.play(name, force, reversed, frame);
		if (offsets.exists(name)) offset.set((offsets[name][0] ?? 0) * scale.x, (offsets[name][1] ?? 0) * scale.y);
	}
}