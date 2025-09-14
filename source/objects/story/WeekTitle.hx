package objects.story;

class WeekTitle extends FlxSpriteGroup {
    var flashTick:Float = 0;

    var title:FlxSprite;
    var lock:FlxSprite;

    public var selected(default, set):Bool = false;
    var locked:Bool = false;

    public var targetY:Float;

    var animFrames:Array<{x:Float, color:Int}> = [
        {x: -10, color: FlxColor.RED},
        {x: 12, color: FlxColor.WHITE},
        {x: -4, color: FlxColor.RED},
        {x: 0, color: FlxColor.WHITE}
    ];

    var curFrame:Int = 0;
    var animTimer:Float = 0;
    var frameDuration:Float = 1 / 24;

    var lerpTimer:Float = 0;

    public function new(x:Int, y:Int, titleImage:String, locked:Bool = false):Void {
        super(x, y);

        this.locked = locked;

        var graphic = Path.image('storymenu/titles/$titleImage');
        if (graphic == null) graphic = Path.image('storymenu/titles/tutorial');

        add(title = new FlxSprite(graphic));

        if (locked) {
            add(lock = new FlxSprite());
            lock.frames = Path.sparrow('storymenu/ui');
            lock.animation.addByPrefix('lock', 'lock', 0, false);
            lock.animation.play('lock');
            lock.x = title.x + title.width + Constants.WEEK_LOCK_PAD;
        }

        screenCenter(X);
    }

    function set_selected(value:Bool):Bool {
        lerpTimer = 0;

        if (!locked) return selected = value;

        if (Data.flashingLights) {
            animTimer = curFrame = 0;
            updateFrame();
        } else {
            title.color = 0xFFFF0000;
        }

        return selected = value;
    }

    public override function update(elapsed:Float):Void {
        y = Util.lerp(y, targetY, 10);

        if (!selected) return;

        if (locked) {
            if (Data.flashingLights) {
                animTimer += elapsed;

                while (animTimer >= frameDuration) {
                    animTimer -= frameDuration;

                    if (curFrame < animFrames.length - 1) {
                        curFrame++;
                        updateFrame();
                    } else {
                        break;
                    }
                }

            } else {
                lerpFromColor(0xFFFF0000, 5, elapsed);
            }

            return;
        }

        if (!Data.flashingLights) {
            title.color = 0xFF33ffff;
            lerpFromColor(0xFF33ffff, 1, elapsed);
            return;
        }

        flashTick += elapsed;

        if (flashTick < 0.05) return;

        flashTick %= 0.05;
        title.color = (title.color == FlxColor.WHITE) ? 0xFF33ffff : FlxColor.WHITE;
    }

    function lerpFromColor(color:Int, factor:Float, elapsed:Float):Void {
        lerpTimer += elapsed;
        title.color = Util.lerpColor(color, FlxColor.WHITE, Math.min(lerpTimer * factor, 1));
    }

    function updateFrame():Void {
        title.offset.x = -animFrames[curFrame].x;
        title.color = animFrames[curFrame].color;
    }

    override function get_width():Float {
        return length == 0 ? 0 : lock != null ? (title.width + lock.width + Constants.WEEK_LOCK_PAD) : title.width;
    }
}