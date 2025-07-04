package objects;

//metadata that will be used for the chart editor, so i can like render it correctly or sumthin
class EventMeta {
    public var name:String;
    public var value:String;
    public var type:String;
    public var defaultValue:String;
    public var options:Array<String> = [];

    public var step:String;
    public var min:String;
    public var max:String;

    public var condition:String;

    public function new(name:String, value:String):Void {
        this.name = name;
        this.value = value;
    }

    public function when(condition:String):EventMeta {
        this.condition = condition;
        return this;
    }

    public function string(defaultValue:String):EventMeta {
        type = 'string';
        this.defaultValue = defaultValue;
        return this;
    }

    public function list(options:Array<String>, defaultValue:String):EventMeta {
        type = 'list';
        this.defaultValue = defaultValue;
        this.options = options;
        return this;
    }

    public function float(step:Float, defaultValue:Float, ?min:Float, ?max:Float):EventMeta {
        type = 'float';
        this.defaultValue = Std.string(defaultValue);
        this.step = Std.string(step);
        if (min != null) this.min = Std.string(min);
        if (max != null) this.max = Std.string(max);
        return this;
    }

    public function int(step:Int, defaultValue:Int, ?min:Int, ?max:Int):EventMeta {
        type = 'int';
        this.defaultValue = Std.string(defaultValue);
        this.step = Std.string(step);
        if (min != null) this.min = Std.string(min);
        if (max != null) this.max = Std.string(max);

        return this;
    }

    public function bool(defaultValue:Bool):EventMeta {
        type = 'bool';
        this.defaultValue = Std.string(defaultValue);
        return this;
    }
}