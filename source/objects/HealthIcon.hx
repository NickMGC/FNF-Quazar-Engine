package objects;

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;

    var iconOffset:Array<Float> = [0, 0];
	var character:String = '';

	public function new(x:Float = 0, y:Float = 0, character:String = 'bf', flipX:Bool = false):Void {
		super(x, y);
		changeIcon(character, flipX);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (sprTracker == null) return;
		setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function changeIcon(character:String, flipX:Bool = false):Void {
        if (this.character == character) return;

        this.character = character;
		this.flipX = flipX;

		var graphic = Path.image('icon-$character', 'data/characters/$character');
        if (graphic == null) graphic = Path.image('misc/icon-face');

		loadGraphic(graphic, true, Std.int(graphic.width * 0.5), graphic.height);
		updateHitbox();
		
		iconOffset = [(width - 150) * 0.5, (height - 150) * 0.5];

		animation.add(character, [0, 1], 0, false);
		animation.play(character);

		antialiasing = !character.endsWith('-pixel');
	}

	public function onBeatHit():Void {
		scale.set(1.15, 1.15);
		updateHitbox();
	}

	override function updateHitbox():Void {
		super.updateHitbox();
        offset.set(iconOffset[0], iconOffset[1]);
	}
}