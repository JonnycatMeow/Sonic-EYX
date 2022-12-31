package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var foundImag:String = '';

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var songsBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var songText:FlxText;
	//var numbersText:FlxText;
	var screenGlowUp:FlxSprite;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var cantFindFil:FlxTypedGroup<FlxSprite>;
	private var shitThing:FlxTypedGroup<FlxSprite>;
	private var grpSongs:FlxTypedGroup<FlxSprite>;
	private var songsBox:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;
	

	private var iconArray:Array<HealthIcon> = [];

	var sexyBG:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	private static var picPosit:Int = 10;
	private static var picPositX:Int = 0;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		sexyBG = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
		sexyBG.antialiasing = false;
		sexyBG.setGraphicSize(1280, 720);
		sexyBG.scrollFactor.set(0.43, 0.43);
		sexyBG.screenCenter();
		add(sexyBG);

		var songSlider:FlxSprite = new FlxSprite(0, 0).makeGraphic(15, 1280, 0xFF000000);
		songSlider.angle = 90;
		songSlider.screenCenter(XY);
		add(songSlider);

		cantFindFil = new FlxTypedGroup<FlxSprite>();
		add(cantFindFil);

		shitThing = new FlxTypedGroup<FlxSprite>();
		add(shitThing);

		grpSongs = new FlxTypedGroup<FlxSprite>();
		add(grpSongs);

		songsBox = new FlxTypedGroup<FlxSprite>();
		add(songsBox);

		for (i in 0...songs.length)
		{
			var unknownFil:FlxSprite = new FlxSprite(0, 0);
			#if MODS_ALLOWED
			unknownFil.loadGraphic(Paths.image('FPstuff/error'));
			#else
			unknownFil.loadGraphic(Paths.image('FPstuff/error'));
			#end
			unknownFil.scale.set(0.5, 0.5);
			cantFindFil.add(unknownFil);

			var blackSquareShit:FlxSprite = new FlxSprite(0, 0).makeGraphic(625, 472, 0xFF000000);
			blackSquareShit.scale.set(0.5, 0.5);
			blackSquareShit.ID = i;
			shitThing.add(blackSquareShit);

			var songPortrait:FlxSprite = new FlxSprite(0, 10); // -355
			//songPortrait.y = (350 * i) + picPosit;
			songPortrait.x = (i * 420) + picPositX; // 395
			#if MODS_ALLOWED
			songPortrait.loadGraphic(Paths.image('FPstuff/' + Paths.formatToSongPath(songs[i].songName)));
			#else
			songPortrait.loadGraphic(Paths.image('FPstuff/' + Paths.formatToSongPath(songs[i].songName)));
			#end
			//songText.isMenuItem = true;
			//songText.scrollFactor.set(0.5, 0.5);
			songPortrait.ID = i;
			songPortrait.scale.set(0.5, 0.5);
			grpSongs.add(songPortrait);
			
			var bOx:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('FreeBox'));
			bOx.scale.set(0.5, 0.5);
			songsBox.add(bOx);

			/*if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				//songText.updateHitbox();
				//trace(songs[i].songName + ' new scale: ' + textScale);
			}*/


			/*Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);*/
		}
		WeekData.setDirectoryFromWeek ();
		var spikyBarTopLeft:FlxSprite = new FlxSprite(-355, -245);
		spikyBarTopLeft.loadGraphic(Paths.image('sidebar'));
		spikyBarTopLeft.scale.set(1, 1);
		spikyBarTopLeft.angle = -90;
		spikyBarTopLeft.flipY = true;
		add(spikyBarTopLeft);

		var spikyBarTopRight:FlxSprite = new FlxSprite(355, -245);
		spikyBarTopRight.loadGraphic(Paths.image('sidebar'));
		spikyBarTopRight.scale.set(1, 1);
		spikyBarTopRight.angle = -90;
		add(spikyBarTopRight);

		var spikyBarBottomLeft:FlxSprite = new FlxSprite(-355, 245);
		spikyBarBottomLeft.loadGraphic(Paths.image('sidebar'));
		spikyBarBottomLeft.scale.set(1, 1);
		spikyBarBottomLeft.angle = 90;
		add(spikyBarBottomLeft);

		var spikyBarBottomRight:FlxSprite = new FlxSprite(355, 245);
		spikyBarBottomRight.loadGraphic(Paths.image('sidebar'));
		spikyBarBottomRight.scale.set(1, 1);
		spikyBarBottomRight.flipY = true;
		spikyBarBottomRight.angle = 90;
		add(spikyBarBottomRight);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		songsBG = new FlxSprite(1093, 155).makeGraphic(1, 66, 0xFF000000); // 436  //855
		songsBG.alpha = 0.6;
		add(songsBG);

		/*numbersText = new FlxText(800, 155, 0, '', 75);
		numbersText.font = scoreText.font;
		numbersText.screenCenter(XY);
		add(numbersText);*/

		songText = new FlxText(835, 635, 0, '', 30);  // width x == 436 when final song  // 815  //1060  // new 835
		songText.font = scoreText.font;
		songText.screenCenter(X);
		add(songText);

		/*if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;*/

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		screenGlowUp = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xffFFFFFF);
		screenGlowUp.screenCenter();
		screenGlowUp.alpha = 0;
		add(screenGlowUp);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	var changeSongSelect:Bool = true;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		songText.text = 'Song Title: ' + songs[curSelected].songName;
		songText.x = (590+songText.width-(songText.width-30)-((songText.width-30)/2));
		
		//songText.x = 1060 - songText.width + 209;
		//songsBG.x = songText.x + songText.width;
		//songsBG.scale.x = songText.width + 455;
		
		for (i in 0...songs.length) // stupid
		{
			cantFindFil.members[i].x = grpSongs.members[i].x;
			cantFindFil.members[i].y = grpSongs.members[i].y;
			cantFindFil.members[i].scale.x = grpSongs.members[i].scale.x;
			cantFindFil.members[i].scale.y = grpSongs.members[i].scale.y;

			shitThing.members[i].x = grpSongs.members[i].x +325;
			shitThing.members[i].y = grpSongs.members[i].y +121;

			songsBox.members[i].x = grpSongs.members[i].x;
			songsBox.members[i].y = grpSongs.members[i].y;
			songsBox.members[i].scale.x = grpSongs.members[i].scale.x;
			songsBox.members[i].scale.y = grpSongs.members[i].scale.y;

			songsBox.members[i].alpha = grpSongs.members[i].alpha;
		}
		

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		//if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (changeSongSelect == true)
			{
				if (controls.UI_LEFT_P) //(upP)
				{
					changeSelection(-shiftMult);
					//changeSongSelect = false;
					//holdTime = 0;
				}
				
				if (controls.UI_RIGHT_P) //(downP)
				{
					changeSelection(shiftMult);
					//changeSongSelect = false;
					//holdTime = 0;
				}
			}

			/*if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}*/

			/*if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}*/
		}

		
		
			if (downP)//(controls.UI_LEFT_P)
				changeDiff(-1);
			else if (upP) //(controls.UI_RIGHT_P)
				changeDiff(1);
			//else if (upP || downP) changeDiff();
		

		if (controls.BACK)
		{
			persistentUpdate = false;
			/*if(colorTween != null) {
				colorTween.cancel();
			}*/
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		/*if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}*/
		if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			

			if (changeSongSelect == true)
			{	FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(screenGlowUp, {alpha: 1}, 0.78, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
				{
					//LoadingState.loadAndSwitchState(new PlayState());
					FlxG.switchState(LoadingState.getNextState(new PlayState()));
				}});
				changeSongSelect = false;
			}

			FlxG.sound.music.volume = 0;
			destroyFreeplayVocals();
		}
		/*else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}*/
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		//positionSongBG();

		if (change == -1)
		{
			if (curSelected == songs.length - 1)
			{
				for (i in 0...grpSongs.length)
				{
					FlxTween.tween(grpSongs.members[i], {x: (i * 420) + (picPositX - ((songs.length - 1) * 420))}, 0.2, {ease: FlxEase.sineOut}); //, onComplete: function(twn:FlxTween)
					/*{
						changeSongSelect = true;
					}});*/
				}
				picPositX = picPositX - ((songs.length - 1) * 420);
			}
			else
			{
				for (i in 0...grpSongs.length)
				{
					FlxTween.tween(grpSongs.members[i], {x: (i * 420) + (picPositX + 420)}, 0.2, {ease: FlxEase.sineOut}); //, onComplete: function(twn:FlxTween)
					/*{
						changeSongSelect = true;
					}});*/
				}
				picPositX = picPositX + 420;
			}
		}

		if (change == 1)
		{
			if (curSelected == 0)
			{
				for (i in 0...grpSongs.length)
				{
					FlxTween.tween(grpSongs.members[i], {x: (i * 420) + (picPositX + ((songs.length - 1) * 420))}, 0.2, {ease: FlxEase.sineOut}); //, onComplete: function(twn:FlxTween)
					/*{
						changeSongSelect = true;
					}});*/
				}
				picPositX = picPositX + ((songs.length - 1) * 420);
			}
			else
			{
				for (i in 0...grpSongs.length)
				{
					FlxTween.tween(grpSongs.members[i], {x: (i * 420) + (picPositX - 420)}, 0.2, {ease: FlxEase.sineOut}); //, onComplete: function(twn:FlxTween)
					/*{
						changeSongSelect = true;
					}});*/
				}
				picPositX = picPositX - 420;
			}
		}

		var tweenAintSelect:FlxTween;
		var tweenSelect:FlxTween;
		grpSongs.forEach(function(grS:FlxSprite)
		{
			grS.alpha = 0.5;
			tweenAintSelect = FlxTween.tween(grS.scale, {x: 0.5, y: 0.5}, 0.12, {ease: FlxEase.sineOut});
			//tweenSelect.cancel();

			if (grS.ID == curSelected)
			{
				grS.alpha = 1;
				tweenSelect = FlxTween.tween(grS.scale, {x: 0.65, y: 0.65}, 0.12, {ease: FlxEase.sineOut});
				tweenAintSelect.cancel();
			}
		});

		shitThing.forEach(function(dick:FlxSprite)
		{
			dick.visible = true;
			if (dick.ID == curSelected)
			{
				dick.visible = false;
			}
		});
		/*var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}*/

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		/*for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;*/

		/*for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			//item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}*/
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	/*private function positionSongBG()
	{
		songsBG.scale.x = FlxG.width - songText.width + 6;
		//songsBG.x = FlxG.width - (songsBG.scale.x / 2);
	}*/
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}