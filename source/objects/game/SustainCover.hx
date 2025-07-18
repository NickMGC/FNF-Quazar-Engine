package objects.game;

class SustainCover extends FlxSprite {
    var data:Int = 0;

    public var dir(get, default):String;
    function get_dir():String {
        return Note.direction[data % Note.direction.length];
    }

    public function new(data:Int = 0):Void {
		super();

        this.data = data;

        animation.onFinish.add(onFinish);
        loadSkin(Path.sparrow('noteSkins/default/covers'));

        alpha = 0;

        scale.set(0.95, 0.95);
        updateHitbox();
	}

    public function loadSkin(skin:FlxAtlasFrames):Void {
		if (frames == skin) return;

		frames = skin ?? frames;
		animation.destroyAnimations();

        for (dir in Note.direction) {
            animation.addByPrefix('start $dir', 'start $dir', 24, false);
            animation.addByPrefix('hold $dir', 'hold $dir', 24, true);
            animation.addByPrefix('end $dir', 'end $dir', 24, false);
		}
		updateHitbox();
	}

    public function start():Void {
        alpha = 1;
        animation.play('start $dir', true);
    }

    function onFinish(name:String):Void {
        if (name != 'start $dir') return;
        animation.play('hold $dir', true);
	}

    public static function spawn(strum:StrumNote, data:Int):Void {
        strum.strumline.sustainCovers[data % strum.strumline.sustainCovers.length].alpha = 0;

        var endSplash:SustainCover = strum.strumline.endSplashes.recycle(SustainCover, newEndSplash);
        endSplash.loadSkin(strum.strumline.coverFrames);
        endSplash.setPosition(strum.x, strum.y);
        endSplash.animation.play('end ${Note.direction[data % Note.direction.length]}', true);
        endSplash.animation.onFinish.add(killSustain.bind(endSplash));
    }

    static function killSustain(spr:SustainCover, anim:String):Void {
        spr.kill();
    }

    static function newEndSplash():SustainCover {
        var endSplash = new SustainCover();
        endSplash.camera = game.camHUD;
        return endSplash;
    }
}