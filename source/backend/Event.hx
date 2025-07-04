package backend;

import backend.Chart.EventValue;
import objects.BaseEvent;

class Event {
    public static var events:Map<String, Class<BaseEvent>> = new Map();

    public static function trigger(eventName:String, values:Array<EventValue>):Void {
        if (!events.exists(eventName) || eventName == null || values == null) {
            trace('Warning: Event "$eventName" not found.');
            return;
        }

        Type.createInstance(events.get(eventName), []).execute(new EventParams(values));
    }
}