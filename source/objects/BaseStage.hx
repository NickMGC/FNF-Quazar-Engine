package objects;

import flixel.group.FlxContainer;

class BaseStage extends FlxContainer {
	public var bf:Character;
    public var gf:Character;
    public var dad:Character;

    public var name:String;

    public var props:Map<String, FlxSprite> = new Map();
    public var data:StageData;

    public function new(name:String):Void {
        super();

        this.name = name;

        data = Path.stage(name);

        add(gf = new Character(data.gf.position[0], data.gf.position[1], playField.chart.player3));
        add(dad = new Character(data.dad.position[0], data.dad.position[1], playField.chart.player2));
        add(bf = new Character(data.bf.position[0], data.bf.position[1], playField.chart.player1, true));
    
        gf.cameraOffset = data.gf.cameraPosition;
        dad.cameraOffset = data.dad.cameraPosition;
        bf.cameraOffset = data.bf.cameraPosition;

        if (data.gf.scroll != null) gf.scrollFactor.set(data.gf.scroll[0], data.gf.scroll[1]);
        if (data.dad.scroll != null) dad.scrollFactor.set(data.dad.scroll[0], data.dad.scroll[1]);
        if (data.bf.scroll != null) bf.scrollFactor.set(data.bf.scroll[0], data.bf.scroll[1]);

        if (data.gf.hide) gf.visible = false;
        if (data.dad.hide) dad.visible = false;
        if (data.bf.hide) bf.visible = false;

        gf.onAnimPlay.add(onGFAnim);
        dad.onAnimPlay.add(onDadAnim);
        bf.onAnimPlay.add(onBFAnim);

        gf.zIndex = data.gf.zIndex;
        dad.zIndex = data.dad.zIndex;
        bf.zIndex = data.bf.zIndex;

        loadStage();
        refresh();

        create();
    }

    function onBFAnim(animation:String):Void {}
    function onGFAnim(animation:String):Void {}
    function onDadAnim(animation:String):Void {}

    public function loadStage():Void {
        if (data.objects == null) return;

        for (obj in data.objects) {
            var sprite:FlxSprite = new FlxSprite(obj.position[0], obj.position[1]);

            if (obj.animations != null) {
                for (animData in obj.animations) {
                    if (animData.indices == null || animData.indices.length == 0) {
                        sprite.animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);
                    } else {
                        sprite.animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
                    }
                }
            } else {
                sprite.loadGraphic(Path.image(obj.path, obj.prefix == null ? 'stages/$name' : obj.prefix));
            }

            if (obj.scroll != null) sprite.scrollFactor.set(obj.scroll[0], obj.scroll[1]);
            if (obj.scale != null) sprite.scale.set(obj.scale[0], obj.scale[1]);
            if (obj.angle != null) sprite.angle = obj.angle;
            if (obj.alpha != null) sprite.alpha = obj.alpha;
            if (obj.color != null) sprite.color = FlxColor.fromString(obj.color);
            if (obj.flipX != null) sprite.flipX = obj.flipX;
            if (obj.flipY != null) sprite.flipY = obj.flipY;

            sprite.zIndex = obj.zIndex;
            sprite.updateHitbox();

            props.set(obj.name, sprite);
            add(sprite);
        }
    }

    public function create():Void {}
	public function createPost():Void {}

    public function refresh():Void {
        sort(byZIndex);
    }

    public function getProp(prop:String):FlxSprite {
        return props.exists(prop) ? props.get(prop) : null;
    }

    public function onBeat():Void {}
    public function onStep():Void {}
    public function onMeasure():Void {}

    override function destroy():Void {
        super.destroy();

        gf.onAnimPlay.remove(onGFAnim);
        dad.onAnimPlay.remove(onDadAnim);
        bf.onAnimPlay.remove(onBFAnim);
    }

    function byZIndex(order:Int, obj1:FlxBasic, obj2:FlxBasic):Int {
		return FlxSort.byValues(order, obj1.zIndex, obj2.zIndex);
	}
}