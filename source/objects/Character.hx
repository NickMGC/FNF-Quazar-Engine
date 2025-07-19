package objects;

typedef CharacterData = {animations:Array<AnimArray>, image:String, healthbarColor:String, ?singDuration:Float, ?cameraPosition:Array<Float>, ?scale:Float, ?flipX:Bool, ?flipY:Bool, ?pixel:Bool}

typedef AnimArray = {anim:String, name:String, offsets:Array<Int>, ?fps:Int, ?loop:Bool, ?indices:Array<Int>}
typedef GlobalAnimData = {?offsets:Array<Int>, ?fps:Int, ?loop:Bool}

class Character extends FlxSprite {
	public var offsets:Map<String, Array<Float>> = new Map();

	public var character:String = 'bf';
	public var singDuration:Float = 4;

	public var cameraPosition:Array<Float> = [0, 0];
	public var cameraOffset:Array<Float> = [0, 0];
	public var healthbarColor:String = '31b0d1';

	public var onAnimPlay:FlxTypedSignal<String -> Void> = new FlxTypedSignal();

	public var altSuffix:String = '';

	public var specialAnim:Bool = false;
	public var stunned:Bool = false;

	public var danceIdle:Bool = false;
	public var player:Bool = false;

	public var sustaining:Bool = false;

	public var iconOffset:Array<Float> = [0, 0];
	public var danceEveryNumBeats:Int = 2;
	public var holdTimer:Float = 0;

	public var speed:Float = 1;

	public var _editor:Bool = false;
	public var imageFile:String;

	var danced:Bool = false;

	public function new(x:Float = 0, y:Float = 0, character:String, player:Bool = false):Void {
		super(x, y);

		this.player = player;
		this.character = character;

		loadCharacter(character);
	}

	public function loadCharacter(character:String):Void {
		offsets = [];

		var json:CharacterData = Path.character(character);

		antialiasing = !json.pixel ?? Data.antialiasing;
		flipX = (json.flipX == player) ?? false;
		flipY = json.flipY ?? false;

		healthbarColor = json.healthbarColor ?? '31b0d1';
		cameraPosition = json.cameraPosition ?? [0, 0];
		singDuration = json.singDuration ?? 4;

		frames = Path.multiSparrow(json.image.split(','), 'characters/$character');

		imageFile = json.image;

		for (anim in json.animations) {
			if (anim?.indices.length > 0) {
				animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
			} else {
				animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
			}

			offsets.set(anim.anim, [anim.offsets[0] ?? 0, anim.offsets[1] ?? 0]);
		}

		scale.set(json.scale ?? 1, json.scale ?? 1);
		updateHitbox();

		danceIdle = (offsets.exists('danceLeft') && offsets.exists('danceRight'));
    	danceEveryNumBeats = danceIdle ? 1 : 2;
		dance();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (specialAnim && animation.curAnim.finished) {
			specialAnim = false;
			dance();
		}

		if (_editor) return;

		if (animation.curAnim.name.startsWith('sing')) {
			if (holdTimer >= 0.15 * singDuration) {
				dance();
			}
			holdTimer += elapsed;
		} else {
			holdTimer = 0;
		}
	}

	public function sing(dir:String, miss:Bool = false):Void {
		if (specialAnim || stunned) return;

		playAnim('sing${dir.toUpperCase()}${miss ? 'miss' : ''}', true);
		holdTimer = 0;
	}

	public function dance():Void {
		if (specialAnim || stunned) return;
		playAnim(danceIdle ? (danced = !danced) ? 'danceRight' : 'danceLeft' : 'idle');
	}

	public function playAnim(name:String, force:Bool = false, reverse:Bool = false, frame:Int = 0):Void {
		animation.play(name + altSuffix, force, reverse, frame);
		if (offsets.exists(name)) offset.set(offsets[name][0] ?? 0, offsets[name][1] ?? 0);
		onAnimPlay.dispatch(animation.curAnim.name);
	}
}