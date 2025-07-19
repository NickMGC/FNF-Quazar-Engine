package backend;

import substates.GameOverSubState;
import substates.PauseSubState;
import states.editors.ChartEditor;

class PlayerInput {
	public static var safeMS:Float = (Data.safeFrames / 60) * 250;

	public static function init():Void {
		Key.onPress(Key.reset, onReset);
		Key.onPress(Key.debug, onChartEditor); //if the game shits itself here, reset your save file by going to `AppData/Roaming` and deleting the folder `NickNGC`
		Key.onPress(Key.accept.concat(Key.back), onPause);

		for (i => bind in Note.notebindNames) {
			Key.onPress(Data.keybinds[bind], onPress.bind(i));
			Key.onRelease(Data.keybinds[bind], onRelease.bind(i));
		}
	}

	static function onChartEditor():Void {
		//FIXME: it doesnt remember the chart if you open the chart editor twice FUCK
		FlxG.switchState(new ChartEditor(PlayField.chartingMode ? ChartEditor.chart : playField.chart));
		PlayField.chartingMode = true;
	}

	static function onPause():Void {
		if (playField.songEnded || game == null) return;
		game.openSubState(new PauseSubState());
	}

	static function onReset():Void {
		if (playField.songEnded || game == null || !Data.reset) return;
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