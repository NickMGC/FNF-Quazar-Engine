package backend;

import objects.Character.AnimArray;
import objects.Character.GlobalAnimData;

class NoteSkinData {
    public var noteData:BaseData;
    public var coverData:BaseData;
    public var splashData:BaseData;
    public var metadata:NoteMetadata;

    public var skin:String;

    public var noteFrames:FlxAtlasFrames;
    public var splashFrames:FlxAtlasFrames;
	public var coverFrames:FlxAtlasFrames;

    public function new(skin:String):Void {
        loadSkin(skin);
    }

    public function loadSkin(key:String):Void {
        skin = key;

        noteData = loadData('notes');
        coverData = loadData('covers');
        splashData = loadData('splashes');
        metadata = loadData('metadata');

        noteFrames = Path.sparrow('game/noteSkins/$skin/${noteData.image}');
        splashFrames = Path.sparrow('game/noteSkins/$skin/${splashData.image}');
		coverFrames = Path.sparrow('game/noteSkins/$skin/${coverData.image}');
    }

    function loadData<T>(key:String):T {
        return Path.parseJSON('assets/images/game/noteSkins/$skin/$key.json');
    }
}

typedef BaseData = {image:String, scale:Array<Float>, ?globalAnimData:GlobalAnimData, animations:Array<AnimArray>}
typedef NoteMetadata = {name:String, hasSustainCovers:Bool, hasNoteSplashes:Bool, ?autoOffsetStrums:Bool, ?sustainRender:String}