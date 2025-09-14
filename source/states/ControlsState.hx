package states;

import objects.options.RebindWindow;
import openfl.events.KeyboardEvent;
import objects.options.KeyBind;

class ControlsState extends Scene {
    static var curSelected:Int = 0;
    static var selectedKey:Int = 0;

    var curBind:DisplayKeyBind;

    var displayBinds:Array<DisplayKeyBind> = [];

    var rebindWindow:RebindWindow;

    var _targetCamY:Float;
    var curY:Float = 60;

    var keyHoldTime:Float = 0;
    var heldKey:Int = -1;
    var inputCooldown:Float = 0;

    override function create():Void {
        add(UIUtil.background(0xFFea71fd));

        for (category in generateCategories()) {
            UIUtil.addHeader(category.name, curY, CENTER);

            curY += 50;

            for (i => bind in category.keyBinds) {
                curY += 50 + (i > 0 ? displayBinds[displayBinds.length - 1].bind.offset : 0);

                displayBinds.push(new DisplayKeyBind(bind, curY));
                add(displayBinds[displayBinds.length - 1]);
            }

            curY += 110;
        }

        add(rebindWindow = new RebindWindow());

        Key.onPress(Key.up, changeItem.bind(-1));
        Key.onPress(Key.down, changeItem.bind(1));
        Key.onPress(Key.left, changeKey.bind(-1));
        Key.onPress(Key.right, changeKey.bind(1));
        Key.onPress(Key.accept, onAccept);
        Key.onPress(Key.back, onBack);

        changeItem();
        FlxG.camera.scroll.y = _targetCamY;

        super.create();
    }

    inline function changeItem(dir:Int = 0):Void {
        if (dir != 0) FlxG.sound.play(Path.sound('scroll'), 0.6);

        curSelected = (curSelected + dir + displayBinds.length) % displayBinds.length;
        curBind = displayBinds[curSelected];

        updateHighlight();

        _targetCamY = FlxMath.bound(curBind.y - 170, 0, curY - FlxG.height);
    }

    inline function changeKey(dir:Int):Void {
        if (curBind.bind.type != KEYBIND) return;

        selectedKey = (selectedKey + dir + 2) % 2;

        FlxG.sound.play(Path.sound('scroll'), 0.6);
        updateHighlight();
    }

    function onAccept():Void {
        switch curBind.bind.type {
            case CALLBACK: curBind.bind.bindCallback();
            case KEYBIND: changeBindState();
        }
    }

    function onBack():Void {
        if (inputCooldown > 0) return;
        
        FlxG.sound.play(Path.sound('cancel'), 0.6);
        FlxG.switchState(new OptionsState());
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        FlxG.camera.scroll.y = FlxMath.roundDecimal(Util.lerp(FlxG.camera.scroll.y, _targetCamY, 10), 2);

        if (inputCooldown > 0) inputCooldown -= elapsed;

        if (!Controls.block || heldKey == -1) return;

		keyHoldTime += elapsed;
        if (keyHoldTime < 0.5) return;

		if (heldKey == FlxKey.ESCAPE) {
            finishRebind(true);
        } else if (heldKey == FlxKey.BACKSPACE) {
            finishRebind(true, FlxKey.NONE);
        }
    }

    function resetControls():Void {
        Data.keybinds = Settings.getDefaultKeys();

        Settings.save();
        Settings.load();

        for (bind in displayBinds) {
            bind.updateBind();
        }

        updateHighlight();

        FlxG.sound.play(Path.sound('scroll'), 0.6);
    }

    function changeBindState(finish:Bool = false):Void {
        Controls.block = rebindWindow.visible = !finish;

        if (finish) {
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        } else {
            FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
        }
    }

    function finishRebind(cancel:Bool = false, key:Int = null):Void {
        changeBindState(true);
        
        if (cancel) {
            FlxG.sound.play(Path.sound('cancel'), 0.6);
            inputCooldown = 0.2;
        } else {
            FlxG.sound.play(Path.sound('confirm'), 0.6);
        }

        heldKey = -1;
        keyHoldTime = 0;

        if (key == null) return;

        curBind.bind.bind[selectedKey] = key;
        (selectedKey == 0 ? curBind.firstKey : curBind.secondKey).text = Util.displayKey(key);

        Settings.save();
        Settings.load();
    }

    function onKeyPress(event:KeyboardEvent):Void {
        if (event.keyCode == FlxKey.ESCAPE || event.keyCode == FlxKey.BACKSPACE) {
            heldKey = event.keyCode;
            keyHoldTime = 0;
            return;
        }

        finishRebind(event.keyCode);
    }
    
    function onKeyRelease(event:KeyboardEvent):Void {
        if (event.keyCode != heldKey || keyHoldTime >= 0.5) return;
        finishRebind(event.keyCode);
    }

    inline function updateHighlight():Void {
        for (bind in displayBinds) {
            bind.highlight(bind == curBind, selectedKey);
        }
    }

    function generateCategories():Array<KeyBindCategory> {
        return [
            KeyBind.category('Gameplay', [
                KeyBind.add('Left', Key.left_note),
                KeyBind.add('Down', Key.down_note),
                KeyBind.add('Up', Key.up_note),
                KeyBind.add('Right', Key.right_note)
            ]),
            KeyBind.category('UI Navigation', [
                KeyBind.add('Left', Key.left),
                KeyBind.add('Down', Key.down),
                KeyBind.add('Up', Key.up),
                KeyBind.add('Right', Key.right).addSpacing(),
                KeyBind.add('Accept', Key.accept),
                KeyBind.add('Back', Key.back),
                KeyBind.add('Pause', Key.pause)
            ]),
            KeyBind.category('Volume', [
                KeyBind.add('Mute', Key.mute),
                KeyBind.add('Volume Up', Key.volume_up),
                KeyBind.add('Volume Down', Key.volume_down),
            ]),
            KeyBind.category('Debug', [
                KeyBind.add('Chart Editor', Key.debug),
                KeyBind.add('Character Editor', Key.debug2).addSpacing(),
                KeyBind.callback('Reset Controls...', resetControls)
            ])
        ];
    }
}