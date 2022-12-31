package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import Conductor.Rating;
#if MODS_ALLOWED
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
import VideoHandler;
#end

using StringTools;

class SoundTestState extends MusicBeatState
{
	var motherNum:Int = 0;
	var fuckerNum:Int = 0;
	var daSelect:Int = 0;
	var sT1:FlxText;
	var sT2:FlxText;
	override function create()
	{
		super.create();
		
		FlxG.sound.music.fadeIn(0.25, 0.7, 0);
		
		var bgST:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('backgroundST'));
		bgST.setGraphicSize(1280, 720);
		bgST.screenCenter();
		add(bgST);

		var soundTestTxt:FlxText = new FlxText(500, 165, 0, 'SOUND TEST', 25);
		//soundTestTxt.screenCenter(X);
		soundTestTxt.setFormat('Sonic CD Menu Font Regular', 25, 0xFF00A3FF);
		soundTestTxt.setBorderStyle(SHADOW, FlxColor.BLACK, 4, 1);
		add(soundTestTxt);
		
		sT1 = new FlxText(313, 360, 0, "PCM NO ." + motherNum, 23);
		sT1.scrollFactor.set();
		sT1.setFormat("Sonic CD Menu Font Regular", 23, 0xFFAEB3FB);
		sT1.setBorderStyle(SHADOW, 0xFF6A6E9F, 4, 1);
		add(sT1);
		
		sT2 = new FlxText(768, 360, 0, "DA NO ." + fuckerNum, 23);
		sT2.scrollFactor.set();
		sT2.setFormat("Sonic CD Menu Font Regular", 23, 0xFFAEB3FB);
		sT2.setBorderStyle(SHADOW, 0xFF6A6E9F, 4, 1);
		add(sT2);
	}

	override function update(elapsed:Float)
	{
		/*if (controls.ACCEPT)
		{
			if (motherNum == 15 && fuckerNum == 10)
			{
				//trace('milf-hard');
				#if MODS_ALLOWED
				PlayState.SONG = Song.loadFromJson('endless-encore', 'Endless');
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 0;
				LoadingState.loadAndSwitchState(new PlayState());
				#end
			}
		}*/
		
		if (controls.BACK)
		{	
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		
		if (daSelect > 1)
		{
			daSelect = 0;
		}
		else if (daSelect < 0)
		{
			daSelect = 1;
		}
		
		if (daSelect == 0)
		{
			sT1.color = 0xFFff7f27;
			sT1.setBorderStyle(SHADOW, 0xFFF72203, 4, 1);
		}
		else
		{
			sT1.color = 0xFFAEB3FB;
			sT1.setBorderStyle(SHADOW, 0xFF6A6E9F, 4, 1);
		}
		
		if (daSelect == 1)
		{
			sT2.color = 0xFFff7f27;
			sT2.setBorderStyle(SHADOW, 0xFFF72203, 4, 1);
		}
		else
		{
			sT2.color = 0xFFAEB3FB;
			sT2.setBorderStyle(SHADOW, 0xFF6A6E9F, 4, 1);
		}
		
		if (controls.UI_LEFT_P)
		{
			daSelect = daSelect - 1;
		}
		
		if (controls.UI_RIGHT_P)
		{
			daSelect = daSelect + 1;
		}
		
		if (controls.UI_UP_P)
		{
			if (daSelect == 0)
			{
				motherNum = motherNum + 1;
			}
			
			if (daSelect == 1)
			{
				fuckerNum = fuckerNum + 1;
			}
		}
		
		if (controls.UI_DOWN_P)
		{
			if (daSelect == 0)
			{
				motherNum = motherNum - 1;
			}
			
			if (daSelect == 1)
			{
				fuckerNum = fuckerNum - 1;
			}
		}
		
		if (motherNum < 0)
		{
			motherNum = 0;
		}
		
		if (fuckerNum < 0)
		{
			fuckerNum = 0;
		}
		
		sT1.text = 'PCM NO .' + motherNum;
		sT2.text = 'DA NO .' + fuckerNum;
		
		super.update(elapsed);
	}
	
}