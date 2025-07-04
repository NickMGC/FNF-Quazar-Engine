package objects;

class Alphabet extends BitmapText {
	public var bold:Bool = true;

	public function new(x:Float = 0, y:Float = 0, text:String = '', scale:Float = 1, bold:Bool = true, alignment:FlxTextAlign = LEFT):Void {
		super(x, y, bold ? 'bold' : 'default', text, alignment);

		this.bold = bold;
		this.scale.set(scale, scale);
		updateHitbox();

		if (bold) {
			autoUpperCase = true;
			letterSpacing = -5;
			lineSpacing = -15;
		} else {
			letterSpacing = -2;
			lineSpacing = 0;
		}
	}
}