package tools;

import openfl.display.BlendMode;

class Util {
    public static function getEase(ease:String):Float -> Float {
		return switch ease.toLowerCase().trim() {
			case 'backin': FlxEase.backIn;
			case 'backinout': FlxEase.backInOut;
			case 'backout': FlxEase.backOut;
			case 'bouncein': FlxEase.bounceIn;
			case 'bounceinout': FlxEase.bounceInOut;
			case 'bounceout': FlxEase.bounceOut;
			case 'circin': FlxEase.circIn;
			case 'circinout': FlxEase.circInOut;
			case 'circout': FlxEase.circOut;
			case 'cubein': FlxEase.cubeIn;
			case 'cubeinout': FlxEase.cubeInOut;
			case 'cubeout': FlxEase.cubeOut;
			case 'elasticin': FlxEase.elasticIn;
			case 'elasticinout': FlxEase.elasticInOut;
			case 'elasticout': FlxEase.elasticOut;
			case 'expoin': FlxEase.expoIn;
			case 'expoinout': FlxEase.expoInOut;
			case 'expoout': FlxEase.expoOut;
			case 'quadin': FlxEase.quadIn;
			case 'quadinout': FlxEase.quadInOut;
			case 'quadout': FlxEase.quadOut;
			case 'quartin': FlxEase.quartIn;
			case 'quartinout': FlxEase.quartInOut;
			case 'quartout': FlxEase.quartOut;
			case 'quintin': FlxEase.quintIn;
			case 'quintinout': FlxEase.quintInOut;
			case 'quintout': FlxEase.quintOut;
			case 'sinein': FlxEase.sineIn;
			case 'sineinout': FlxEase.sineInOut;
			case 'sineout': FlxEase.sineOut;
			case 'smoothstepin': FlxEase.smoothStepIn;
			case 'smoothstepinout': FlxEase.smoothStepInOut;
			case 'smoothstepout': FlxEase.smoothStepOut;
			case 'smootherstepin': FlxEase.smootherStepIn;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'smootherstepout': FlxEase.smootherStepOut;
            default: FlxEase.linear;
		}
    }

    public static function getTweenType(type:String):FlxTweenType {
		return switch type.toLowerCase().trim() {
			case 'backward': FlxTweenType.BACKWARD;
			case 'looping' | 'loop': FlxTweenType.LOOPING;
			case 'persist': FlxTweenType.PERSIST;
			case 'pingpong': FlxTweenType.PINGPONG;
            default: FlxTweenType.ONESHOT;
		}
	}

    public static function getblendMode(blend:String):BlendMode {
		return switch blend.toLowerCase().trim() {
			case 'add': ADD;
			case 'alpha': ALPHA;
			case 'darken': DARKEN;
			case 'difference': DIFFERENCE;
			case 'erase': ERASE;
			case 'hardlight': HARDLIGHT;
			case 'invert': INVERT;
			case 'layer': LAYER;
			case 'lighten': LIGHTEN;
			case 'multiply': MULTIPLY;
			case 'overlay': OVERLAY;
			case 'screen': SCREEN;
			case 'shader': SHADER;
			case 'subtract': SUBTRACT;
            default: NORMAL;
		}
	}

	public static function getCharacter(character:String):Character {
		if (game == null) {
			trace('Game is not initialized yet');
			return null;
		}

		return switch character {
            case 'dad': game.stage.dad;
            case 'gf': game.stage.gf;
            case 'bf': game.stage.bf;
            default: null;
        }
	}

	public static function getCamera(camera:String):FlxCamera {
		if (game == null) {
			trace('Game is not initialized yet');
			return null;
		}

		return switch camera {
            case 'camGame': game.camera;
            case 'camHUD': game.camHUD;
            case 'camOther': game.camOther;
            default: null;
        }
	}

	public static function lerpColor(Color1:FlxColor, Color2:FlxColor, Factor:Float = 0.5):FlxColor {
		return FlxColor.interpolate(Color1, Color2, Factor);
	}
}