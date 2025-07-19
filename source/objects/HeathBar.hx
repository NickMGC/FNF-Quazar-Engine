package objects;

class HealthBar extends FlxSpriteGroup {
	public var playerBar:FlxSprite;
	public var opponentBar:FlxSprite;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new(y:Float = 0):Void {
		super(0, y);

		add(playerBar = new FlxSprite(Path.image('game/healthBar')));
		playerBar.color = FlxColor.fromString(Path.character(playField.chart.player1).healthbarColor);

		add(opponentBar = new FlxSprite(Path.image('game/healthBar')));
		opponentBar.color = FlxColor.fromString(Path.character(playField.chart.player2).healthbarColor);
		opponentBar.clipRect = FlxRect.get(0, 0, playerBar.width, playerBar.height);
		opponentBar.clipRect.width = playerBar.width * (1 - playField.health);

		screenCenter(X);

		add(iconP1 = new HealthIcon(0, -75, playField.chart.player1, true));
		add(iconP2 = new HealthIcon(0, -75, playField.chart.player2));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		opponentBar.clipRect.width = FlxMath.lerp(opponentBar.clipRect.width, playerBar.width * (1 - playField.health), 10 * elapsed);

		for (i => icon in [iconP1, iconP2]) {
			icon.scale.x = icon.scale.y = FlxMath.lerp(1, icon.scale.x, Math.exp(-elapsed * 9));
			icon.updateHitbox();
			icon.x = opponentBar.x + opponentBar.clipRect.width - (20 + (i * 100));
		}
	}
}