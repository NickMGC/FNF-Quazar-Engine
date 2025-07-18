//dont look at this code im embarrassed (spoiler alert its ass)
// package backend;

// import objects.Character.AnimArray;
// import objects.Character.GlobalAnimData;

// class NoteSkinData {
//     public var noteData:BaseData;
//     public var coverData:BaseData;
//     public var splashData:BaseData;
//     public var metadata:NoteMetadata;

//     public var skin:String;
//     public var path:String;

//     public var noteFrames:FlxAtlasFrames;
//     public var splashFrames:FlxAtlasFrames;
// 	public var coverFrames:FlxAtlasFrames;

//     public function new(skin:String):Void {
//         loadSkin(skin);
//     }

//     public function loadSkin(key:String):Void {
//         skin = key;
//         path = Path.get('images/noteSkins/$skin');

//         noteData = loadData('notes');
//         coverData = loadData('covers');
//         splashData = loadData('splashes');
//         metadata = loadData('metadata');

//         noteFrames = Path.sparrow('noteSkins/$skin/notes');
//         splashFrames = Path.sparrow('noteSkins/$skin/splashes');
// 		coverFrames = Path.sparrow('noteSkins/$skin/covers');
//     }

//     function loadData<T>(key:String):T {
//         return Path.parseJSON('$path/$key.json');
//     }

//     public static function get(name:String):NoteSkinData {
//         return new NoteSkinData(name);
//     }
// }

// typedef BaseData = {name:String, scale:Array<Float>, ?globalAnimData:GlobalAnimData, animations:Array<AnimArray>}
// typedef NoteMetadata = {name:String, ?sustainRender:String}