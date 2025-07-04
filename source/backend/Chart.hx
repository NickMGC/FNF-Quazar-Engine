package backend;

typedef Chart = {notes:Array<NoteJSON>, events:Array<EventJSON>, bpm:Float, speed:Float, player1:String, player2:String, player3:String, stage:String, ?song:String}
typedef NoteJSON = {data:Int, time:Float, ?length:Float, ?type:String}
typedef EventJSON = {time:Float, events:Array<EventData>}
typedef EventData = {name:String, ?values:Array<EventValue>}
typedef EventValue = {name:String, value:String}