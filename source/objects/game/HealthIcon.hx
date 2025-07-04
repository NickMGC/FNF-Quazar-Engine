package objects.game;

class HealthIcon extends FlxSprite {
    var iconOffset:Array<Float> = [0, 0];
	var character:String = '';

	public function new(x:Float = 0, y:Float = 0, character:String = 'bf', flipX:Bool = false):Void {
		super(x, y);
		changeIcon(character, flipX);
	}

	public function changeIcon(character:String, flipX:Bool = false):Void {
        if (this.character == character) return;

        this.character = character;
		this.flipX = flipX;

		var graphic = Path.image('icon-$character', 'characters/$character');
        if (graphic == null) graphic = Path.image('icon-face');

		loadGraphic(graphic, true, Std.int(graphic.width / 2), graphic.height);
		updateHitbox();
		
		iconOffset = [(width - 150) / 2, (height - 150) / 2];

		animation.add(character, [0, 1], 0, false);
		animation.play(character);

		antialiasing = !character.endsWith('-pixel');
	}

	override function updateHitbox():Void {
		super.updateHitbox();
        offset.set(iconOffset[0], iconOffset[1]);
	}
}