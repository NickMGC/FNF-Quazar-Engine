package states;

import objects.options.*;
import objects.options.Option.OptionCategory;
import objects.options.Option.DisplayOption;

class OptionsState extends Scene {
	static var curOption:Option;
	static var curSelected:Int = 0;

	//TODO: find a way to apply the values without creating anonymous functions
	var categories:Array<OptionCategory> = [
		Option.category("Gameplay Settings", [
			Option.bool("Downscroll", "Reverses the direction of incoming notes, making them travel downward", Data.downScroll, v -> Data.downScroll = v),
			Option.bool("Middlescroll", "Puts player's notes in the centre", Data.middleScroll, v -> Data.middleScroll = v),
			Option.bool("Ghost Tapping", "Allows you to tap notes without penalty even when no notes are active", Data.ghostTapping, v -> Data.ghostTapping = v),
			Option.bool("Reset Character", "Determines whether the character should reset or not", Data.reset, v -> Data.reset = v),
			Option.bool("Flashing Lights", "Includes flashing lights during some in-game moments\nIf you are sensitive to flashing lights, it is best to turn this setting off", Data.flashingLights, v -> Data.flashingLights = v).addSpacing(),
			Option.float("Safe frames", "Adjusts how strict the timing window is for hitting notes\nIncrease this number for less strict judgements", Data.safeFrames, v -> Data.safeFrames = v).bound(0, 10).addSpacing(),
			Option.state("Change Controls...", "", ControlsState),
			Option.state("Change Delay...", "", DelayState)
		]),
		Option.category("Visual Settings", [
			Option.bool("Opponent notes", "Toggles the visibility of Opponent notes", Data.opponentNotes, v -> Data.opponentNotes = v),
			Option.bool("Hide HUD", "Toggles the visibility of most HUD elements", Data.hideHud, v -> Data.hideHud = v).addSpacing(),
			Option.bool("Note Splashes", "Toggles the visibility of Note Splashes", Data.cameraZooms, v -> Data.cameraZooms = v),
			Option.bool("Note Hold Covers", "Toggles the visibility of Hold Covers", Data.cameraZooms, v -> Data.cameraZooms = v),
			Option.bool("Release Splashes", "Toggles the visibility of Release Splashes", Data.cameraZooms, v -> Data.cameraZooms = v),
			Option.bool("Sparks", "Toggles the visibility of Sparks", Data.cameraZooms, v -> Data.cameraZooms = v)
		]),
		Option.category("Graphics Settings", [
			Option.int("Framerate", "Changes the frequency rate at which frames are being redrawn", Data.framerate, v -> {
				if (v > FlxG.drawFramerate) {
					FlxG.updateFramerate = v;
					FlxG.drawFramerate = v;
				} else {
					FlxG.drawFramerate = v;
					FlxG.updateFramerate = v;
				}

				Data.framerate = v;
			}).bound(30, 500),
			Option.string("Fullscreen", "Choose a desired fullscreen option.", Data.fullscrenType, ['Windowed', 'Fullscreen', 'Borderless'], v -> {
				var window = lime.app.Application.current.window;

				switch v {
					case "Windowed":
						window.fullscreen = false;
						Util.resizeWindow(Std.parseInt(Data.screenRes.split('x')[0]), Std.parseInt(Data.screenRes.split('x')[1]));

					case "Fullscreen":
						window.fullscreen = true;

					case "Borderless":
						window.fullscreen = false;

						var display = lime.system.System.getDisplay(0);
						Util.resizeWindow(Std.int(display.bounds.width), Std.int(display.bounds.width));
				}

				Data.fullscrenType = v;
			}),
			Option.string("Window Resolution", "Changes the window size", Data.screenRes, Constants.RESOLUTIONS, v -> {
				if (Data.fullscrenType == "Windowed") {
					Util.resizeWindow(Std.parseInt(v.split('x')[0]), Std.parseInt(v.split('x')[1]));
				}

				Data.screenRes = v;
			}).addSpacing(),
			Option.bool("Anti-Aliasing", "Smooths out jagged edges, making them appear less pixelated", Data.antialiasing, v -> Data.antialiasing = v),
			Option.bool("GPU Rendering", "Offloads rendering to the GPU, improves CPU performance", Data.gpuRendering, v -> Data.gpuRendering = v),
			Option.bool("Shaders", "Shaders enhance visuals but may impact performance on older hardware", Data.shaders, v -> Data.shaders = v),
			Option.bool("Low Quality", "Reduces graphical detail to maximize performance. Useful for low-end devices", Data.antialiasing, v -> Data.antialiasing = v)
		])
	];

	var options:Array<DisplayOption> = [];

	var descBG:FlxSprite;
	var desc:Alphabet;

	var curY:Float = 60;
	var holdTime:Float = 0;

	override function create():Void {
		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Path.music('freakyMenu'), 0.5);
		}

		add(UIUtil.background(0xFFea71fd));

		for (i => category in categories) {
			UIUtil.addHeader(category.name, curY, CENTER);

			curY += 50;
	
			for (num => option in category.options) {
				curY += 50 + (num > 0 ? options[options.length - 1].option.offset : 0);

				options.push(new DisplayOption(option, curY, options.length, i));
				add(options[options.length - 1]);
			}
	
			final lastOption:DisplayOption = options[options.length - 1];
			category.length = lastOption.y + lastOption.height + 170 - FlxG.height;
	
			curY += 110;
		}

		add(descBG = UIUtil.background(0xFFea71fd));
		descBG.clipRect = new FlxRect(0, 630, 1280, 90);

		add(desc = new Alphabet(0, 630, '', 0.6, false).setAlign(CENTER, Std.int(1270 / 0.6)));
		desc.scrollFactor.set();

		Key.onPress(Key.accept, onAccept);
		Key.onPress(Key.back, onBack);

		Key.onPress(Key.left, valueChange.bind(-1));
		Key.onPress(Key.right, valueChange.bind(1));

		Key.onPress(Key.down, changeItem.bind(1));
		Key.onPress(Key.up, changeItem.bind(-1));

		Key.onHold(Key.left, valueChange.bind(-1, true));
		Key.onHold(Key.right, valueChange.bind(1, true));

		Key.onRelease(Key.left.concat(Key.right), onKeyRelease);

		changeItem();

		FlxG.camera.scroll.y = Util.bound(options[curSelected].y - 170, 0, categories[options[curSelected].index].length);

		super.create();
	}
	
	function onKeyRelease():Void {
		holdTime = 0;
	}

	function onAccept():Void {
		options[curSelected].updateValue();
	}

	function onBack():Void {
		FlxG.sound.play(Path.sound('cancel'), 0.6);

		Settings.save();
		Settings.load();

		FlxG.switchState(new MainMenuState());
	}

	function valueChange(dir:Int = 0, hold:Bool = false):Void {
		if (curOption.type == 'bool' || curOption.type == 'state' || (hold && holdTime < 0.5)) return;
		options[curSelected].updateValue(dir);
	}

	function changeItem(dir:Int = 0):Void {
		if (dir != 0) {
			FlxG.sound.play(Path.sound('scroll'), 0.4);
		}

		curSelected = (curSelected + dir + options.length) % options.length;

		curOption = options[curSelected].option;

		descBG.visible = curOption.desc != '';
		desc.text = curOption.desc;

		desc.fitToRect(0.6, 0.6, 1270, 80, CENTER);
		desc.screenCenterIn(XY, FlxG.width, 90);

		desc.y += 630;

		for (option in options) {
			option.label.alpha = option == options[curSelected] ? 1 : 0.6;
		}
	}

	override function update(elapsed:Float):Void { 
		super.update(elapsed);

		FlxG.camera.scroll.y = FlxMath.roundDecimal(Util.lerp(FlxG.camera.scroll.y, Util.bound(options[curSelected].y - 170, 0, categories[options[curSelected].index].length), 10), 2);

		if (curOption.type == 'bool' || curOption.type == 'state' || !FlxG.keys.anyPressed(Key.left.concat(Key.right))) return;
		holdTime += elapsed;
	}
}