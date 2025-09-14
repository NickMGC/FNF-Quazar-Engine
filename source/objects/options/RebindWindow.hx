package objects.options;

class RebindWindow extends FlxSpriteGroup {
    public function new():Void {
        super();

        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x60000000));

        final background = new FlxSprite().makeGraphic(1080, 520, 0xFFFAFD6D);
        background.screenCenter();
        add(background);

        add(new Alphabet(0, 185, 'Press any key to rebind').setAlign(CENTER, FlxG.width));
        add(new Alphabet(0, 415, 'Backspace to unbind\nEscape to cancel').setAlign(CENTER, FlxG.width));

        scrollFactor.set();

        visible = false;
    }
}