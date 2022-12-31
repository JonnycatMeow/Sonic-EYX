package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;
	
	var redBox:FlxSprite;
	var staShit:FlxSprite;
	var difficultySelectors:FlxGroup;
	var leftArrowWeek:FlxSprite;
	var rightArrowWeek:FlxSprite;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;
		
		var bgSM:FlxSprite = new FlxSprite();
		bgSM.frames = Paths.getSparrowAtlas('SMMStatic');
		bgSM.animation.addByPrefix('staticShit', 'damfstatic', 24, true);
		bgSM.animation.play('staticShit');
		bgSM.setGraphicSize(1280, 720);
		bgSM.updateHitbox();
		bgSM.screenCenter();
		//bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgSM);
		
		var greyBox:FlxSprite = new FlxSprite().loadGraphic(Paths.image('greybox'));
		greyBox.screenCenter(XY);
		greyBox.scale.set(0.7, 0.7);
		add(greyBox);
		
		var yellowBox:FlxSprite = new FlxSprite().loadGraphic(Paths.image('yellowbox'));
		yellowBox.screenCenter(XY);
		yellowBox.scale.set(0.7, 0.7);

		var boyBruh:FlxSprite = new FlxSprite(0, 195);
		boyBruh.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
		boyBruh.animation.addByPrefix('IDLE', 'BF idle dance', 24, true);
		boyBruh.animation.play('IDLE');
		boyBruh.scale.set(0.45, 0.45);
		boyBruh.antialiasing = ClientPrefs.globalAntialiasing;
		boyBruh.screenCenter(X);
		add(boyBruh);
		
		redBox = new FlxSprite().loadGraphic(Paths.image('redbox'));
		redBox.screenCenter(XY);
		redBox.scale.set(0.7, 0.7);
		add(redBox);
		

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(-10, -187).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bgYellow.scale.set(0.3, 0.28);
		
		bgSprite = new FlxSprite(-10, -187); // -187
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		bgSprite.setGraphicSize(1280, 720);
		bgSprite.scale.set(0.3, 0.28);
		
		staShit = new FlxSprite(-12, -186);
		staShit.frames = Paths.getSparrowAtlas('screenstatic');
		staShit.animation.addByPrefix('stat', 'screenSTATIC', 24, true);
		staShit.animation.play('stat');
		staShit.alpha = 0.45;
		staShit.updateHitbox();
		staShit.setGraphicSize(1280, 720);
		staShit.scale.set(0.3, 0.28);

		/*var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		blackBarThingie.alpha = 0;
		add(blackBarThingie);*/

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		//var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		/*for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}*/

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrowWeek = new FlxSprite(345, 175);
		leftArrowWeek.frames = ui_tex;
		leftArrowWeek.animation.addByPrefix('idle', "arrow left");
		leftArrowWeek.animation.addByPrefix('press', "arrow push left");
		leftArrowWeek.animation.addByPrefix('idle-alt', 'arrow-left alt');
		leftArrowWeek.animation.play('idle');
		leftArrowWeek.scale.set(0.8, 0.8);
		leftArrowWeek.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrowWeek);

		leftArrow = new FlxSprite(400, 590);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.addByPrefix('idle-alt', 'arrow-left alt');
		leftArrow.animation.play('idle');
		leftArrow.scale.set(0.8, 0.8);
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		//sprDifficulty.screenCenter(X);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		sprDifficulty.scale.set(1.1, 1.1);
		difficultySelectors.add(sprDifficulty);

		rightArrowWeek = new FlxSprite(leftArrowWeek.x + 522, leftArrowWeek.y);
		rightArrowWeek.frames = ui_tex;
		rightArrowWeek.animation.addByPrefix('idle', 'arrow right');
		rightArrowWeek.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrowWeek.animation.addByPrefix('idle-alt', 'arrow-right alt');
		rightArrowWeek.animation.play('idle');
		rightArrowWeek.scale.set(0.8, 0.8);
		rightArrowWeek.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrowWeek);

		rightArrow = new FlxSprite(leftArrow.x + 416, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.addByPrefix('idle-alt', 'arrow-right alt');
		rightArrow.animation.play('idle');
		rightArrow.scale.set(0.8, 0.8);
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		add(bgYellow);
		add(bgSprite);
		add(staShit);
		add(yellowBox);
		//add(grpWeekCharacters);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);


		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				//weekThing.y += ((weekThing.height + 20) * num);
				weekThing.screenCenter(X);
				weekThing.visible = false;
				weekThing.targetY = num;
				grpWeekText.add(weekThing);

				//weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.screenCenter(XY);
					lock.visible = false;
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		txtTracklist = new FlxText(FlxG.width * 0.05, 5, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFff0000;
		//add(txtTracklist);
		
		//add(scoreText);
		//add(txtWeekTitle);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}
	
	var tweenStat:FlxTween;
	var changeDiffc:Int = 0;
	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;

			if (upP)
			{
				changeDiffc = changeDiffc + 1;
			}

			if (downP)
			{
				changeDiffc = changeDiffc - 1;
			}

			if (changeDiffc > 1)
				changeDiffc = 0;

			if (changeDiffc < 0)
				changeDiffc = 1;

			if (changeDiffc == 1)
			{
				rightArrow.animation.play('idle-alt');
				leftArrow.animation.play('idle-alt');
				if (controls.UI_LEFT_P) //(upP)
				{
					changeWeek( -1);
					staShit.alpha = 1;
					if (tweenStat != null)
					{
						tweenStat.cancel();
					}
					tweenStat = FlxTween.tween(staShit, {alpha: 0.45}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					{
						tweenStat = null;
					}});
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				
				if (controls.UI_RIGHT_P) //(downP)
				{
					changeWeek(1);
					staShit.alpha = 1;
					if (tweenStat != null)
					{
						tweenStat.cancel();
					}
					tweenStat = FlxTween.tween(staShit, {alpha: 0.45}, 0.5, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
					{
						tweenStat = null;
					}});
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (controls.UI_RIGHT)
				{
					rightArrowWeek.animation.play('press');
				}
				else
				{
					rightArrowWeek.animation.play('idle');
				}
							
				if (controls.UI_LEFT)
				{
					leftArrowWeek.animation.play('press');
				}
				else
				{
					leftArrowWeek.animation.play('idle');
				}
			}

			if (changeDiffc == 0)
			{
				rightArrowWeek.animation.play('idle-alt');
				leftArrowWeek.animation.play('idle-alt');
				if (controls.UI_RIGHT)
				{
					rightArrow.animation.play('press');
				}
				else
				{
					rightArrow.animation.play('idle');
				}
						
				if (controls.UI_LEFT)
				{
					leftArrow.animation.play('press');
				}
				else
				{
					leftArrow.animation.play('idle');
				}
					
				if (controls.UI_RIGHT_P)
				{
					changeDifficulty(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else if (controls.UI_LEFT_P)
				{	changeDifficulty( -1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			/*else if (upP || downP)
				changeDifficulty();*/

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpWeekText.forEach(function(week: MenuItem)
		{
			week.y = 110;
		});

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			//lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				//grpWeekText.members[curWeek].startFlashing();
				FlxFlicker.flicker(redBox, 1, 0.06, false, false);
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 90;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 23;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		/*for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}*/

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.visible = false;
			if (lock.ID == curWeek && unlocked == false)
			{
				lock.visible = true;
			}
		});

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		difficultySelectors.visible = unlocked;

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
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
