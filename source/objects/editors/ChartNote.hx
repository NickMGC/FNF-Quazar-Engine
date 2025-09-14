package objects.editors;

class ChartNote extends FlxSprite {
	public var index:Int = 0;

	public var dir(get, default):String;
    function get_dir():String {
        return Constants.DIRECTION[index % Constants.DIRECTION.length];
    }

	public var data:NoteJSON;

	public function new(x:Float = 0, y:Float = 0, data:NoteJSON):Void {
		super(x, y);

        this.data = data;
		index = data.data;

		frames = Path.sparrow('noteSkins/default/notes');

		for (dir in Constants.DIRECTION) {
			for (name in ['strum', 'note', 'tail', 'hold']) {
				animation.addByPrefix('$name$dir', '$name $dir', 24);
			}

			animation.addByPrefix('confirm$dir', 'confirm $dir', 24, false);
			animation.addByPrefix('press$dir', 'press $dir', 24, false);
		}

		animation.play('note$dir');
        setGraphicSize(ChartEditor.GRID_SIZE, ChartEditor.GRID_SIZE);
		updateHitbox();
	}
}