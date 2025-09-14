package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class AgnosticOffsetMacro {
    public static macro function build():Array<Field> {
        #if macro
        var fields:Array<Field> = Context.getBuildFields();

        if (!Context.unify(Context.getLocalType(), Context.getType('flixel.FlxSprite'))) {
            Context.error('Class ${Context.getLocalClass().get().name} must extend flixel.FlxSprite to use agnostic offsetting.', Context.currentPos());
            return fields;
        }

        var impl:Expr = macro {
            frame.prepareMatrix(_matrix, flixel.graphics.frames.FlxFrame.FlxFrameAngle.ANGLE_0);
            _matrix.translate(-origin.x, -origin.y);
            _matrix.scale(scale.x, scale.y);

            if (checkFlipX()) {
                _matrix.a *= -1;
                _matrix.c *= -1;
                _matrix.tx *= -1;
            }

            if (checkFlipY()) {
                _matrix.b *= -1;
                _matrix.d *= -1;
                _matrix.ty *= -1;
            }

            if (bakedRotationAngle <= 0) {
                var radians:Float = angle * flixel.math.FlxAngle.TO_RAD;
                if (radians != 0) {
                    _matrix.rotateWithTrig(Math.cos(radians), Math.sin(radians));
                }
            }

            var ogOffsetX:Float = offset.x;
            var ogOffsetY:Float = offset.y;

            offset.x *= scale.x * (flipX ? -1 : 1);
            offset.y *= scale.y * (flipY ? -1 : 1);
            offset.degrees += angle;

            getScreenPosition(_point, camera).subtract(offset);
            _point.add(origin.x, origin.y);

            if (isPixelPerfectRender(camera)) {
                _point.floor();
            }

            offset.x = ogOffsetX;
            offset.y = ogOffsetY;

            _matrix.translate(_point.x, _point.y);

            camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
        };

        for (field in fields) {
            if (field.name != 'drawFrameComplex') continue;
            Context.error("Class '" + Context.getLocalClass().get().name + "' already implements a custom 'drawFrameComplex' method!", Context.currentPos());
            return fields;
        }

        fields.push({
            name: 'drawFrameComplex',
            pos: Context.currentPos(),
            access: [APublic, AOverride],
            kind: FFun({
                args: [
                    {name: 'frame', type: macro:flixel.graphics.frames.FlxFrame},
                    {name: 'camera', type: macro:flixel.FlxCamera}
                ],
                ret: macro:Void,
                expr: impl,
            })
        });

        return fields;
        #end
    }
}