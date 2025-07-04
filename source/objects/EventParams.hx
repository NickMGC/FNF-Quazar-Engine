package objects;

//this shit laced!!!!! i kinda hate how you always have to call Std.parseThing so i just uhhhh,,, yeah
@:forward abstract EventParams(Map<String, String>) from Map<String, String> to Map<String, String> {
    public inline function new(eventValues:Array<EventValue>):Void {
        this = new Map<String, String>();

        if (eventValues == null) return;

        for (event in eventValues) {
            this.set(event.name, event.value);
        }
    }

    public inline function string(name:String):String {
        return this.get(name);
    }

    public inline function int(name:String):Int {
        return Std.parseInt(string(name));
    }

    public inline function float(name:String):Float {
        return Std.parseFloat(string(name));
    }

    public inline function bool(name:String):Bool {
        return string(name).toLowerCase() == 'true';
    }

    public inline function arrayString(name:String):Array<String> {
        var rawString = string(name);
        if (rawString == null || rawString.trim() == '') return [];

        return [for (string in rawString.split(',')) string.trim()];
    }

    public inline function arrayInt(name:String):Array<Int> {
        var intArray:Array<Int> = [];

        for (val in arrayString(name)) {
            var int = Std.parseInt(val);
            if (int != null && !Math.isNaN(int)) {
                intArray.push(int);
            }
        }
        return intArray;
    }

    public inline function arrayFloat(name:String):Array<Float> {
        var floatArray:Array<Float> = [];

        for (val in arrayString(name)) {
            var float = Std.parseFloat(val);
            if (!Math.isNaN(float)) {
                floatArray.push(float);
            }
        }
        return floatArray;
    }

    public inline function arrayBool(name:String):Array<Bool> {
        return [for (strVal in arrayString(name)) strVal.toLowerCase() == 'true'];
    }
}