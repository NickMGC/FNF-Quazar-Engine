package objects;

import flixel.text.FlxBitmapText;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxText;

class BitmapText extends FlxBitmapText {
	public function new(x:Float = 0, y:Float = 0, path:String, text:String = '', alignment:FlxTextAlign = LEFT):Void {
		super(x, y, text, FlxBitmapFont.fromAngelCode(Path.image(path, 'fonts/bitmap'), Path.fnt('fonts/bitmap/$path')));
		this.alignment = alignment;
		antialiasing = Data.antialiasing;
	}

	public function setAlign(alignment:FlxTextAlign, fieldWidth:Int):BitmapText {
		autoSize = false;
		this.fieldWidth = fieldWidth;
		this.alignment = alignment;
		return this;
	}

	public function setFieldWidth(fieldWidth:Int):BitmapText {
		autoSize = false;
		this.fieldWidth = fieldWidth;
		return this;
	}
	
	public function setFormat(path:String, scale:Float = 1, color:FlxColor = FlxColor.WHITE, ?alignment:FlxTextAlign, ?borderStyle:FlxTextBorderStyle, borderColor:FlxColor = FlxColor.TRANSPARENT):BitmapText {
		this.borderStyle = (borderStyle == null) ? NONE : borderStyle;

		var font = FlxBitmapFont.fromAngelCode(Path.image(path, 'fonts/bitmap'), Path.fnt('fonts/bitmap/$path'));

		this.font = (font == null) ? FlxBitmapFont.getDefaultFont() : font;

		this.scale.set(scale, scale);
		updateHitbox();

		textColor = color;
		useTextColor = true;

		if (alignment != null) {
			this.alignment = alignment;
		}

		this.borderColor = borderColor;

		return this;
	}

	//flixel 5.9.0 didnt account for centered text so heres a band-aid fix for now, will make a pr later
	override function computeTextSize():Void {
		final finalTxtWidth = textWidth;
		final txtWidth = autoSize ? finalTxtWidth + padding * 2 : fieldWidth;
		final txtHeight = textHeight + padding * 2;
		
		frameWidth = (txtWidth == 0) ? 1 : txtWidth;
		frameHeight = (txtHeight == 0) ? 1 : txtHeight;
	}
}