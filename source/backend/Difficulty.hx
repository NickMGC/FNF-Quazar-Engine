package backend;

class Difficulty {
    /**
        @param name Display Difficulty name
        @param songName The song name to check difficulties for
        @param num Optional Week index
        @return Returns Difficulty's internal name
    **/
    public static function displayNameToName(name:String, songName:String, num:Int = null):String {
        return findDiff(name, songName, num, false);
    }

    /**
        @param name Internal Difficulty name
        @param songName The song name to check difficulties for
        @param num Optional Week index
        @return Returns Difficulty's display name
    **/
    public static function nameToDisplayName(name:String, songName:String, num:Int = null):String {
        return findDiff(name, songName, num, true);
    }

    static function findDiff(name:String, songName:String, num:Int = null, display:Bool):String {
        final week:WeekData = WeekData.getCurrent(num);
        return songName != null ? findSongDiff(week, songName, name, display) : week.difficulties != null ? findWeekDiff(week, name, display) : null;
    }

    static function findSongDiff(week:WeekData, songName:String, diffName:String, display:Bool):String {
        for (song in week.songs) {
            if (song.name != songName || song.diff == null) continue;
        
            for (diff in song.diff) {
                if ((display ? diff.name : diff.displayName) != diffName) continue;
                return display ? diff.displayName : diff.name;
            }
        }
        return null;
    }

    static function findWeekDiff(week:WeekData, name:String, display:Bool):String {
        for (diff in week.difficulties) {
            if ((display ? diff.name : diff.displayName) != name) continue;
            return display ? diff.displayName : diff.name;
        }
        return null;
    }
}