package objects.story;

import flixel.graphics.FlxGraphic;
import objects.Character.AnimArray;

class WeekDifficulty extends FlxSprite {
    public var posTween:FlxTween;
    public var alphaTween:FlxTween;

    public function new(x:Float = 0, y:Float = 0):Void {
        super(x, y);
    }

    public function updateGraphic(arrowX:Float = 0, arrowY:Float = 0, difficulty:String):Void {
        var newImage:FlxGraphic = Path.image('storymenu/difficulties/$difficulty');
        var newXml:String = 'assets/images/storymenu/difficulties/$difficulty.xml';
        var newJson:AnimArray = null;
        var newFrames:FlxAtlasFrames = null;

        if (FileSystem.exists(newXml)) {
            newFrames = FlxAtlasFrames.fromSparrow(newImage, newXml);

            if (frames == newFrames) return;

            var jsonPath:String = Path.json('images/storymenu/difficulties/$difficulty');
    
            if (FileSystem.exists(jsonPath)) {
                newJson = Path.parseJSON(jsonPath);
            }

            frames = newFrames;
            animation.addByPrefix('idle', newJson != null ? newJson.name : 'idle', newJson != null ? newJson.fps : 24, newJson != null ? newJson.loop : true);
            animation.play('idle');
        } else {
            if (graphic == newImage) return;
            loadGraphic(newImage);
        }

        updateHitbox();

        setPosition(arrowX + 55 + (308 - width) * 0.5, arrowY - height + 75);

        if (posTween != null) posTween.cancel();
        if (alphaTween != null) alphaTween.cancel();

        posTween = FlxTween.num(y - 30, y, 0.07, updateY);
        alphaTween = FlxTween.num(0, 1, 0.07, updateAlpha);
    }

    function updateY(value:Float):Void {
        y = value;
    }

    function updateAlpha(value:Float):Void {
        alpha = value;
    }
}