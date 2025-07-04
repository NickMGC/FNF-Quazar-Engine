package events;

@event('Change Stage')
class ChangeStage implements BaseEvent {
    public var meta:Array<EventMeta> = [
        new EventMeta('Stage Name', 'name').string('stage')
    ];

    public function execute(params:EventParams):Void {
        //i kinda hate this but i cant just do game.stage = Stage.get(params.string('name', 'stage')); for some reason???
        game.stage.name = params.string('name');

        game.stage.data = Path.stage(game.stage.name);

        for (prop in game.stage.props) {
            game.stage.remove(prop, true);
            prop.destroy();
            prop = null;
        }

        game.stage.gf.setPosition(game.stage.data.gf.position[0], game.stage.data.gf.position[1]);
        game.stage.dad.setPosition(game.stage.data.dad.position[0], game.stage.data.dad.position[1]);
        game.stage.bf.setPosition(game.stage.data.bf.position[0], game.stage.data.bf.position[1]);
    
        game.stage.gf.cameraOffset = game.stage.data.gf.cameraPosition;
        game.stage.dad.cameraOffset = game.stage.data.dad.cameraPosition;
        game.stage.bf.cameraOffset = game.stage.data.bf.cameraPosition;

        if (game.stage.data.gf.scroll != null) game.stage.gf.scrollFactor.set(game.stage.data.gf.scroll[0], game.stage.data.gf.scroll[1]);
        if (game.stage.data.dad.scroll != null) game.stage.dad.scrollFactor.set(game.stage.data.dad.scroll[0], game.stage.data.dad.scroll[1]);
        if (game.stage.data.bf.scroll != null) game.stage.bf.scrollFactor.set(game.stage.data.bf.scroll[0], game.stage.data.bf.scroll[1]);

        if (game.stage.data.gf.hide) game.stage.gf.visible = false;
        if (game.stage.data.dad.hide) game.stage.dad.visible = false;
        if (game.stage.data.bf.hide) game.stage.bf.visible = false;

        game.stage.gf.zIndex = game.stage.data.gf.zIndex;
        game.stage.dad.zIndex = game.stage.data.dad.zIndex;
        game.stage.bf.zIndex = game.stage.data.bf.zIndex;

        game.stage.loadStage();
        game.stage.refresh();
        game.stage.createPost();

        game.moveCamera(Util.getCharacter(game.target));
    }
}