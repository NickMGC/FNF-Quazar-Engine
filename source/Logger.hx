package;

import haxe.Log;
import haxe.PosInfos;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.text.TextFormat;
import openfl.text.TextField;

//Code referenced from Vortex's Logger script
class Logger {
    static var bg:Bitmap;
    static var logText:TextField;

    public static function init():Void {
        FlxG.game.addChild(bg = new Bitmap(new BitmapData(FlxG.width, FlxG.height, true, 0x80000000)));

        FlxG.game.addChild(logText = new TextField());
        logText.defaultTextFormat = new TextFormat('VCR OSD Mono', 14, 0xFFFFFFFF);
        logText.x = logText.y = 5;
        logText.width = FlxG.width;
        logText.height = FlxG.height - 10;
        logText.multiline = logText.wordWrap = true;

        logText.selectable = logText.visible = bg.visible = false;

        FlxG.signals.postDraw.add(onPostDraw);

        Log.trace = Logger.trace;
    }

    public static function trace(v:Dynamic, ?infos:PosInfos):Void {
        logText.text += '\n${Log.formatOutput(v, infos)}';
    }

    static function onPostDraw():Void {
        if (FlxG.keys.justPressed.F3) {
            bg.visible = logText.visible = !logText.visible;
        }

        if (FlxG.keys.justPressed.F4) {
            logText.text = '';
        }
    }
}