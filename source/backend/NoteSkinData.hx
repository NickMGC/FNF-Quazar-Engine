package backend;

import objects.Character.AnimArray;
import objects.Character.GlobalAnimData;

class NoteSkinData {
    public var meta:NoteMetadata;
    public var skin:String;

    public function new(skin:String):Void {
        loadSkin(skin);
    }

    public function loadSkin(key:String):Void {
        skin = key;

        meta = Path.parseJSON(Path.json('images/noteSkins/$skin/animData'));

        if (meta.hasSustainCovers == null) {
            meta.hasSustainCovers = true;
        }

        if (meta.hasNoteSplashes == null) {
            meta.hasNoteSplashes = true;
        }

        if (meta.hasSparks == null) {
            meta.hasSparks = true;
        }

        if (meta.hasSustainLights == null) {
            meta.hasSustainLights = true;
        }

        if (meta.sustainRender == null) {
            meta.sustainRender = 'tiled';
        }
        
        if (meta.scale == null) {
            meta.scale = [1, 1];
        }

        if (meta.padding == null) {
            meta.padding = 115;
        }

        if (meta.position == null) {
            meta.position = [50, 50];
        }
    }

    public function getAtlas(base:BaseData):FlxAtlasFrames {
        return Path.sparrow('noteSkins/$skin/${base.image}');
    }
}

typedef BaseData = {image:String, ?globalAnimData:GlobalAnimData, animations:Array<AnimArray>}

typedef NoteMetadata = {
    var name:String;
    @:optional var sustainRender:String;

    @:optional var hasSustainCovers:Bool;
    @:optional var hasSparks:Bool;
    @:optional var hasSustainLights:Bool;
    @:optional var hasNoteSplashes:Bool;

    var scale:Array<Float>;
    @:optional var padding:Float;
    @:optional var position:Array<Float>;

    var noteScale:Array<Float>;
    var strumScale:Array<Float>;
    @:optional var splashScale:Array<Float>;
    @:optional var holdCoverScale:Array<Float>;
    @:optional var endSplashScale:Array<Float>;
    @:optional var sparkScale:Array<Float>;
    @:optional var sustainLightScale:Array<Float>;



    var notes:BaseData;
    @:optional var splashes:BaseData;
    @:optional var endSplashes:BaseData;
    @:optional var covers:BaseData;
    @:optional var sparks:BaseData;
    @:optional var lights:BaseData;
}

typedef BasePropData = {
    var scale:Array<Float>;
}