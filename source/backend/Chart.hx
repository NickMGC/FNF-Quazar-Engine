package backend;

typedef Chart = {
    song:String,
    difficulty:String,
    bpm:Float,
    speed:Float,
    stage:String,
    player1:String,
    player2:String,
    player3:String,
    notes:Array<NoteJSON>,
    events:Array<EventJSON>,
}

typedef NoteJSON = {data:Int, time:Float, ?length:Float, ?type:String}
typedef EventJSON = {time:Float, events:Array<EventData>}
typedef EventData = {name:String, ?values:Array<EventValue>}
typedef EventValue = {name:String, value:String}