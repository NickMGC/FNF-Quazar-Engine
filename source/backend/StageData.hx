package backend;

typedef CharData = {
    var position:Array<Float>;
    var cameraPosition:Array<Float>;
    var zIndex:Int;
    @:optional var hide:Bool;
    @:optional var scroll:Array<Float>;
}

typedef AnimationData = {
    var name:String;
    var prefix:String;
    var fps:Float;
    var looped:Bool;
    @:optional var indices:Array<Int>;
    @:optional var offset:Array<Float>;
}

typedef StageObject = {
    var name:String;
    var path:String;
    var position:Array<Float>;
    var zIndex:Int;
    @:optional var prefix:String;
    @:optional var scale:Array<Float>;
    @:optional var scroll:Array<Float>;
    @:optional var angle:Float;
    @:optional var alpha:Float;
    @:optional var color:String;
    @:optional var blendMode:Int;
    @:optional var animations:Array<AnimationData>;
    @:optional var flipX:Bool;
    @:optional var flipY:Bool;
}

typedef StageData = {
	var gf:CharData;
	var dad:CharData;
    var bf:CharData;

	var cameraZoom:Float;
    var cameraSpeed:Float;

	@:optional var preload:Array<String>;
	@:optional var objects:Array<StageObject>;
}