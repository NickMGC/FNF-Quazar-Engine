package objects;

class Alphabet extends BitmapText {
	public var bold:Bool = true;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPos:FlxPoint = new FlxPoint(0, 0);

	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;

	public var cutoffRect:FlxRect = FlxRect.get(0, 0, 995);

	public function new(x:Float = 0, y:Float = 0, text:String = '', scale:Float = 1, bold:Bool = true, alignment:FlxTextAlign = LEFT):Void {
		super(x, y, bold ? 'bold' : 'default', text, alignment);

		startPos.set(x, y);

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

	override function setAlign(alignment:FlxTextAlign, fieldWidth:Int):Alphabet {
		super.setAlign(alignment, fieldWidth);
		return cast this;
	}

	override function setFieldWidth(fieldWidth:Int):Alphabet {
		super.setFieldWidth(fieldWidth);
		return cast this;
	}

	override function fitToRect(scaleX:Float, scaleY:Float, maxWidth:Float, maxHeight:Float, ?alignment:FlxTextAlign):Alphabet {
		super.fitToRect(scaleX, scaleY, maxWidth, maxHeight, alignment);
		return cast this;
	}

	override function update(elapsed:Float):Void {
		if (!isMenuItem) return super.update(elapsed);
	
		var lerpVal:Float = Math.exp(-elapsed * 9.6);

		x = FlxMath.lerp((targetY * distancePerItem.x) + startPos.x, x, lerpVal);
		y = FlxMath.lerp((targetY * 1.3 * distancePerItem.y) + startPos.y, y, lerpVal);

		super.update(elapsed);
	}

	public function snapToTarget():Void {
		if (!isMenuItem) return;
		setPosition((targetY * distancePerItem.x) + startPos.x, (targetY * 1.3 * distancePerItem.y) + startPos.y);
	}
}