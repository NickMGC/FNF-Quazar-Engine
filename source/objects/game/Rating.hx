package objects.game;

class Rating {
	static var the_____counter:Int = 0;

	public static function judge(diff:Float, id:Int):Void {
		playField.playerStrum.voices.volume = 1;

		playField.health += 0.025;
		playField.combo++;
		playField.totalPlayed++;

		var scoreModifier:Int = 350;

		var ratingName:String = switch diff {
			case(_ <= Data.hitWindows[0] + PlayerInput.safeMS) => true:
				NoteSplash.spawn(playField.playerStrum.strums[id]);
				playField.totalHit += 1;
				'sick';
			case(_ <= Data.hitWindows[1] + PlayerInput.safeMS) => true:
				scoreModifier = 200;
				playField.totalHit += 0.67;
				'good';
			case(_ <= Data.hitWindows[2] + PlayerInput.safeMS) => true:
				scoreModifier = 100;
				playField.totalHit += 0.34;
				'bad';
			case(_ <= Data.hitWindows[3] + PlayerInput.safeMS) => true:
				scoreModifier = 50;
				'shit';
			default:
				'invalid';
		};

		playField.recalculateRating();
		playField.score += scoreModifier;

		createRating(ratingName);
	}

	static function createRating(ratingName:String):Void {
		the_____counter++;

		var rating:FlxSprite = playField.comboGroup.recycle(FlxSprite, newRating);
		rating.zIndex = the_____counter;
		rating.animation.play(ratingName);
		rating.scale.set(0.7, 0.7);
		rating.updateHitbox();
		rating.screenCenter();
		rating.offset.set(35 - Data.comboOffsets[0], 25 - Data.comboOffsets[1]);
		rating.velocity.set(-FlxG.random.int(0, 10), -FlxG.random.int(140, 175));
		rating.acceleration.y = 550;

		FlxTween.num(1, 0, 0.2, {type: ONESHOT, onComplete: onTweenComplete.bind(rating), startDelay: playField.beatLength * 0.001}, updateAlpha.bind(rating));

		if (playField.combo >= 10) {
			var numArr:Array<String> = Std.string(playField.combo).lpad('0', 3).split('');
			numArr.reverse();

			for (i => num in numArr) {
				var comboNum:FlxSprite = playField.comboGroup.recycle(FlxSprite, newRating);
				comboNum.zIndex = the_____counter;
				comboNum.animation.play('num$num');
				comboNum.scale.set(0.55, 0.55);
				comboNum.updateHitbox();
				comboNum.screenCenter();
				comboNum.offset.set((comboNum.width + 5) * i + 50 - Data.comboOffsets[0], -(comboNum.height + 25) - Data.comboOffsets[1]);
				comboNum.velocity.set(FlxG.random.float(-5, 5), -FlxG.random.int(140, 160));
				comboNum.acceleration.y = FlxG.random.int(200, 300);

				FlxTween.num(1, 0, 0.2, {type: ONESHOT, onComplete: onTweenComplete.bind(comboNum), startDelay: playField.beatLength * 0.001}, updateAlpha.bind(comboNum));
			}
		}

		playField.comboGroup.sort(byZIndex);
	}

	static function onTweenComplete(sprite:FlxSprite, tween:FlxTween):Void {
		sprite.kill();
	}

	static function updateAlpha(sprite:FlxSprite, value:Float):Void {
		sprite.alpha = value;
	}

	static function byZIndex(order:Int, obj1:FlxBasic, obj2:FlxBasic):Int {
		return FlxSort.byValues(order, obj1.zIndex, obj2.zIndex);
	}

	static function newRating():FlxSprite {
		var rating:FlxSprite = new FlxSprite();
		rating.frames = Path.sparrow('rating');
		rating.updateHitbox();

		for (name in ['sick', 'good', 'bad', 'shit']) {
			rating.animation.addByNames(name, [name]);
		}

		for (i in 0...10) {
			rating.animation.addByNames('num$i', ['num$i']);
		}

		rating.moves = true;
		return rating;
	}
}