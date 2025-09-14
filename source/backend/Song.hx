package backend;

import backend.WeekData.SongData;

class Song {
    /**
        @param name Internal Song name
        @param num Optional Week index
        @return Returns Song's display name
    **/
    public static function displayNameToName(name:String, num:Int = null):String {
        return get(name, num, false)?.name ?? null;
    }

    /**
        @param name Display Song name
        @param num Optional Week index
        @return Returns Song's internal name
    **/
    public static function nameToDisplayName(name:String, num:Int = null):String {
        return get(name, num, true)?.displayName ?? null;
    }

    /**
        @param name Internal Song name
        @param num Optional Week index
        @return Returns Song's artist name
    **/
    public static function nameToArtist(name:String, num:Int = null):String {
        return get(name, num, true)?.artist ?? null;
    }

    /**
        @param name Internal Song name
        @param num Optional Week index
        @return Returns Song's charter name
    **/
    public static function nameToCharter(name:String, num:Int = null):String {
        return get(name, num, true)?.charter ?? null;
    }

    public static function get(name:String, num:Int = null, display:Bool = true):SongData {
        for (song in WeekData.getCurrent(num).songs) {
            if (display ? song.name == name : song.displayName == name) return song;
        }
        return null;
    }
}