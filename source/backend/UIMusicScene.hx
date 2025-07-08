package backend;

class UIMusicScene extends UIScene {
	public var conductor:Conductor = new Conductor();

	public var curStep(get, set):Int;
	public var curBeat(get, set):Int;
	public var curMeasure(get, set):Int;

	public var stepLength(get, never):Float;
	public var beatLength(get, never):Float;
	public var measureLength(get, never):Float;

	function onStep():Void {}
	function onBeat():Void {}
	function onMeasure():Void {}

	override public function create():Void {
		super.create();

		addStepSignal(onStep);
		addBeatSignal(onBeat);
		addMeasureSignal(onMeasure);
	}

	public override function destroy():Void {
		conductor.reset();
		removeStepSignal(onStep);
		removeBeatSignal(onBeat);
		removeMeasureSignal(onMeasure);

		super.destroy();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		conductor.update(elapsed);
	}

	@:noCompletion @:keep inline public function addStepSignal(callback:Void -> Void):Void conductor.step.signal.add(callback);
	@:noCompletion @:keep inline public function addBeatSignal(callback:Void -> Void):Void conductor.beat.signal.add(callback);
	@:noCompletion @:keep inline public function addMeasureSignal(callback:Void -> Void):Void conductor.measure.signal.add(callback);

	@:noCompletion @:keep inline public function removeStepSignal(callback:Void -> Void):Void conductor.step.signal.remove(callback);
	@:noCompletion @:keep inline public function removeBeatSignal(callback:Void -> Void):Void conductor.beat.signal.remove(callback);
	@:noCompletion @:keep inline public function removeMeasureSignal(callback:Void -> Void):Void conductor.measure.signal.remove(callback);

	@:noCompletion @:keep inline function get_curStep():Int return conductor.step.cur;
	@:noCompletion @:keep inline function get_curBeat():Int return conductor.beat.cur;
	@:noCompletion @:keep inline function get_curMeasure():Int return conductor.measure.cur;

	@:noCompletion @:keep inline function set_curStep(val:Int):Int return conductor.step.cur = val;
	@:noCompletion @:keep inline function set_curBeat(val:Int):Int return conductor.beat.cur = val;
	@:noCompletion @:keep inline function set_curMeasure(val:Int):Int return conductor.measure.cur = val;

	@:noCompletion @:keep inline function get_stepLength():Float return conductor.step.length;
	@:noCompletion @:keep inline function get_beatLength():Float return conductor.beat.length;
	@:noCompletion @:keep inline function get_measureLength():Float return conductor.measure.length;
}