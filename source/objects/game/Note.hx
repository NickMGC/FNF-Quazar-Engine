package objects.game;

class Note extends NoteSprite {
	public static var notebindNames:Array<String> = ['left_note', 'down_note', 'up_note', 'right_note'];
	public static var direction:Array<String> = ['left', 'down', 'up', 'right'];

	public var time:Float = 0;
	public var length:Float = 0;
	public var type:String = '';

	public var parent:StrumNote;
	public var sustain:Sustain;

	public var sustaining:Bool = false;
	public var hittable:Bool = true;

	public function setup(json:NoteJSON, strumline:Strumline):Void {
		y = FlxG.height * 4 / camera.zoom;
		sustaining = false;
		hittable = visible = true;

		data = json.data ?? 0;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type ?? '';

		animation.play('note$dir');

		parent = strumline.strums[data % strumline.strums.length];

		if (length > 0) {
			sustain = strumline.sustains.recycle(Sustain, newSustain).setup(this);
		}
	}

	public function onSkinChange():Void {
		loadSkin(parent.strumline.skin);
		if (length > 0) {
			sustain.setup(this);
		}
	}

	function newSustain():Sustain {
		return new Sustain();
	}

	public function hit():Void {
		if (game != null) (type == 'gf' ? game.stage.gf : parent.strumline.character).sing(dir);

		hittable = false;

		if (length > 0) {
			parent.confirm(false);
			sustaining = true;
			visible = false;
		} else {
			parent.confirm(parent.strumline.autoHit ? true : false);
			kill();
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		setPosition(parent.x, parent.y - (playField.conductor.time - time) * playField.scrollSpeed * 0.45 * (Data.downScroll ? -1 : 1));

		sustaining ? holding(elapsed) : hitting();

		if (!parent.strumline.autoHit && hittable && (playField.conductor.time >= time + ((FlxG.height / camera.zoom) * 0.5) / (playField.scrollSpeed * 0.45))) {
			miss();
		}

		if (playField.conductor.time >= time + length + ((FlxG.height / camera.zoom) * 0.5) / (playField.scrollSpeed * 0.45)) {
			kill();
		}
	}

	public function holding(elapsed:Float):Void {
		if (game != null) (type == 'gf' ? game.stage.gf : parent.strumline.character).holdTimer = 0;

		if (sustain != null) {
        	sustain.height = Math.max((time + length) - playField.conductor.time, 0) * playField.scrollSpeed * 0.45;
			sustain.setPosition(x + (width - sustain.width) * 0.5, Data.downScroll ? parent.y - sustain.height : parent.y);
		}

		if (!parent.strumline.autoHit) {
			playField.score += Std.int(250 * elapsed);
			playField.health += 0.085 * elapsed;

			if (Data.keybinds[Note.notebindNames[data % Note.notebindNames.length]].foreach(unpressedKey)) {
				kill();
			}
		}

		if (playField.conductor.time >= time + length) {
			if (parent.strumline.autoHit) {
				parent.resetAnim();
			}
			kill();
		}
	}

	public function hitting():Void {
		if (sustain != null) {
			sustain.height = length * playField.scrollSpeed * 0.45;
			sustain.setPosition(x + (width - sustain.width) * 0.5, Data.downScroll ? y - sustain.height : y);
		}

		if (parent.strumline.autoHit && playField.conductor.time >= time) {
			hit();
		}
	}

	public function miss(count:Bool = true):Void {
		hittable = false;

		playField.totalPlayed++;
		playField.recalculateRating();

		if (count) {
			playField.misses++;
			playField.score -= 100;
			playField.combo = 0;
		} else {
			playField.score -= 10;
		}

		if (game != null) {
			var char = type == 'gf' ? game.stage.gf : parent.strumline.character;
			char.sing(dir, true);
			char.holdTimer = -1;
		}

		playField.health -= 0.05;

		FlxG.sound.play(Path.sound('miss' + FlxG.random.int(1, 3)));

		playField.playerStrum.voices.volume = 0;
	}

	function unpressedKey(key:FlxKey):Bool {
		return !Controls.pressedKeys[key];
	}

	override public function kill():Void {
		if (sustain != null) {
			sustain.kill();
			sustain = null;
		}
		super.kill();
	}
}