package stages;

@stage('stage')
class TestStage extends BaseStage {
    override function create():Void {
        super.create();

        trace('hi');
    }
}