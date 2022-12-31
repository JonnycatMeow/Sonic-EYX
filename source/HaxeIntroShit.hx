package;

/*#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end*/
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
/*import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;*/
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import options.GraphicsSettingsSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

#if sys
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
import VideoHandler;
#end

using StringTools;

class HaxeIntroShit extends MusicBeatState
{
	var video:VideoHandler;
	override public function create():Void
	{
		FlxG.mouse.visible = false;

		startIntro();
	}
	
	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		var filepath:String = Paths.video(name);
		#if MODS_ALLOWED
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			return;
		}

		video = new VideoHandler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		return;
		#end
	}
	
	var glitchAss:FlxTimer;
	function startIntro()
	{
		startVideo('HaxeFlixelIntro');

		/*glitchAss = new FlxTimer().start(8, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(new TitleState());
		});*/
	}

	var iduncare:Bool = true;
	override function update(elapsed:Float)
	{
		if (iduncare == true)
		{	
			video.finishCallback = function()
			{
				MusicBeatState.switchState(new TitleState());
				iduncare = false;
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				//glitchAss.cancel();
				iduncare = false;
				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new TitleState());
				});
			}
		}

		/*if (iduncare == true)
		{
			if(FlxG.keys.justPressed.ENTER)
			{
				glitchAss.cancel();
				iduncare = false;
				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new TitleState());
				});
			}
		}*/
		super.update(elapsed);
	}

	/*public static var closedState:Bool = false;

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;*/
}
