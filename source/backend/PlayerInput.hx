package backend;

// import editors.ChartEditor;
import substates.GameOverSubState;
import substates.PauseSubState;

class PlayerInput {
	public static var safeMS:Float = Data.safeFrames * 4;

	public static function init():Void {
		if (Data.reset) {
			Key.onPress(Key.reset, onReset);
		}

		// Key.onPress([FlxKey.SEVEN], onChartEditor);
		Key.onPress(Key.accept.concat(Key.back), onPause);

		if (playField.playerStrum == null) return;

		for (i => bind in Note.notebindNames) {
			Key.onPress(Data.keybinds[bind], onPress.bind(i));
			Key.onRelease(Data.keybinds[bind], onRelease.bind(i));
		}
	}

	// static function onChartEditor():Void {
	// 	FlxG.switchState(new ChartEditor(playField.chart));
	// }

	static function onPause():Void {
		if (playField.songEnded || game == null) return;
		game.openSubState(new PauseSubState());
	}

	static function onReset():Void {
		if (playField.songEnded || game == null) return;
		game.openSubState(new GameOverSubState());
	}

	static function onRelease(id:Int):Void {
		playField.playerStrum.strums[id].resetAnim();
	}

	static function onPress(id:Int):Void {
		if (playField.songEnded) return;

		for (note in playField.playerStrum.notes.members) {
			if (note?.exists && note.alive && note.data % Note.notebindNames.length == id && note.hittable) {
				var diff:Float = Math.abs(playField.conductor.time - note.time);

				if (diff <= Data.hitWindows[3] + safeMS) {
					note.hit();
					Rating.judge(diff, id);
					return;
				}

				if (!Data.ghostTapping) {
					note.miss(false);
				}
			}
		}

		playField.playerStrum.strums[id].press();
	}
}