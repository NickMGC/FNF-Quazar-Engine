package backend;

class Stage {
    public static var stages:Map<String, Class<BaseStage>> = new Map();

    public static function get(stageName:String):BaseStage {
        return stages.exists(stageName) ? Type.createInstance(stages.get(stageName), [stageName]) : return new BaseStage(stageName);
    }
}