//TODO: clean this shit up
#if !macro
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import backend.Settings.Data;
import backend.Settings.DefaultData;
import backend.*;
import backend.Conductor;
import backend.Chart;
import backend.StageData;
import objects.*;
import objects.game.*;
import objects.game.ui.*;
import objects.editors.*;
import states.*;
import tools.*;
import managers.*;
import sys.FileSystem;
import sys.io.File;
import flixel.input.keyboard.FlxKey;
import states.PlayState.game;

import backend.Controls.key as Key;

import tools.Util;
import tools.Util.UIUtil;
import tools.Util.ImplementableUtil;

import states.editors.ChartEditor;

import flixel.util.FlxSort;

import flixel.math.FlxRect;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.addons.transition.FlxTransitionableState.skipNextTransIn;
import flixel.addons.transition.FlxTransitionableState.skipNextTransOut;

using Lambda;
using tools.Util.ImplementableUtil;
#end
using StringTools;
