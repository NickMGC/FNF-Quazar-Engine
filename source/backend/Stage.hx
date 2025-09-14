package backend;

class Stage {
    public static var stages:Map<String, Class<BaseStage>> = new Map();

    public static function get(stageName:String, player1:String = 'bf', player2:String = 'dad', player3:String = 'gf'):BaseStage {
        return stages.exists(stageName) ? Type.createInstance(stages.get(stageName), [stageName]) : return new BaseStage(stageName, player1, player2, player3);
    }
}