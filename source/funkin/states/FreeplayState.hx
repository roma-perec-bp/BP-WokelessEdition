package funkin.states;

import funkin.backend.FallbackState;
import funkin.states.editors.ChartConverterState;
import funkin.data.Chart.ChartFormat;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

import funkin.backend.Difficulty;
import funkin.Mods;
import funkin.data.SongMetaData;
import funkin.states.editors.ChartEditorState;
import funkin.data.WeekData;
import funkin.states.*;
import funkin.states.substates.*;
import funkin.data.*;
import funkin.objects.*;

// todo rewrite this its kinda messy and not that safe
class FreeplayState extends MusicBeatState
{
	public static var vocals:Null<FlxSound> = null;
	
	public var debugBG:FlxSprite;
	public var debugTxt:FlxText;
	
	public var songs:Array<FreeplaySong> = [];
	
	public var freeplayTabs:Array<FreeplayTab> = [];
	
	public static var currentTab:Int = 0;
	
	public var selector:FlxText;
	
	public static var curSelected:Int = 0;
	
	public var curDifficulty:Int = -1;
	
	public static var lastDifficultyName:String = '';
	
	public var scoreBG:FlxSprite;
	public var scoreText:FlxText;
	public var lerpScore:Int = 0;
	public var lerpRating:Float = 0;
	public var intendedScore:Int = 0;
	public var intendedRating:Float = 0;
	
	public var grpSongs:FlxTypedGroup<FlxText>;
	public var curPlaying:Bool = false;
	
	public var bg:FlxSprite;
	public var intendedColor:Int;
	
	var mayGoToChartConverter:Bool = false;

	var icon:HealthIcon;

	var portrait:FlxSprite;
	
	override function create()
	{
		FunkinAssets.cache.clearStoredMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		
		DiscordClient.changePresence("In the Menus");
		
		loadFreeplayData();
		
		if (freeplayTabs.length == 0)
		{
			CoolUtil.setTransSkip(true, false);
			persistentUpdate = false;
			FlxG.switchState(() -> new FallbackState('Cannot load Freeplay as there are no tabs loaded.', () -> FlxG.switchState(MainMenuState.new)));
			return;
		}
		
		initStateScript();
		
		scriptGroup.set('SongMetadata', FreeplaySong); // backwards compat bs ig
		scriptGroup.set('FreeplaySong', FreeplaySong);
		scriptGroup.set('WeekData', WeekData);
		
		bg = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
		add(bg);
		bg.screenCenter();

		portrait = new FlxSprite();
		portrait.loadGraphic(Paths.image('menus/freeplay/lamar'));
		portrait.antialiasing = ClientPrefs.globalAntialiasing;
		portrait.setPosition(750, 150);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		add(portrait);

		FlxTween.tween(portrait, {x: 550}, 1, {ease: FlxEase.quadOut});
		
		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);
	
		icon = new HealthIcon('test');
		icon.x = 50;
		icon.screenCenter(Y);
		add(icon);
		
		scoreText = new FlxText(0, 15, FlxG.width - 6, "", 32);
		scoreText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, RIGHT);
		
		final scoreBGSize = 66;
		
		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeScaledGraphic(1, scoreBGSize, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);
		
		add(scoreText);
		
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		
		final leText:String = "Press RESET to Reset your Score and Accuracy.";
		final size:Int = 16;
		
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.DEFAULT_FONT, size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		
		debugBG = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		debugBG.alpha = 0;
		add(debugBG);
		
		debugTxt = new FlxText(25, 0, FlxG.width - 50, '', 32);
		debugTxt.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		debugTxt.borderSize = 2;
		debugTxt.screenCenter(Y);
		add(debugTxt);
		
		WeekData.setDirectoryFromWeek();
		
		changeTab();
		
		changeDiff();
		changePortrait(songs[curSelected].charPort);
		
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		
		if (lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(lastDifficultyName)));
		
		super.create();
		scriptGroup.call('onCreate', []);
	}
	
	override function closeSubState()
	{
		changeSelection();
		persistentUpdate = true;
		super.closeSubState();
	}
	
	var displayName:String;
	function createSongs()
	{
		var curID:Int = -1;
		for (i in 0...songs.length)
		{
			curID += 1;
			var songText:FlxText;

			displayName = songs[i].songName;
			if(!FlxG.save.data.playedSongs.contains(spaceToDash(songs[i].songName.toLowerCase())))
			{
				var stringArray:Array<String> = displayName.split('');
				displayName = '';
				for (j in stringArray)
				{
					if (j == '-')
						displayName += '-';
					else
						displayName += '?';
				}
			}

			songText = new FlxText(0, (70 * i) + 30, songs[i].displayName, 87);
			songText.setFormat(Paths.font("HouseofTerror.ttf"), 87,  FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songText.borderSize = 4;
			songText.ID = curID;
			grpSongs.add(songText);
			
			songText.scale.x = Math.min(1, 980 / songText.width);
			
			Mods.currentModDirectory = songs[i].folder;
		}
		
		changeSelection();
	}
	
	public function addSong(songName:String, ?info:Array<Dynamic>, weekName:String = "")
	{
		var displayName:String = songName;
		var icon:String = "face";
		var color:String = "#8DA399";
		var charPort:String = "lamar";
		
		final meta = getSongMeta(songName);
		
		if (meta == null && info != null)
		{
			if (info[0] != null) displayName = info[0];
			if (info[1] != null) icon = info[1];
			if (info[2] != null) color = FlxColor.fromRGB(info[2][0], info[2][1], info[2][2]).toHexString();
			if (info[3] != null) charPort =  info[3];
		}
		else if (meta != null)
		{
			if (meta.displayName != null) displayName = meta.displayName;
			if (meta.freeplayIcon != null) icon = meta.freeplayIcon;

			if(FlxG.save.data.playedSongs.contains(spaceToDash(songName.toLowerCase())))
			{
				if (meta.freeplayColor != null) color = meta.freeplayColor;
			}
			else
			{
				color = '#333333';
			}

			charPort =  info[3];
		}

		if(!FlxG.save.data.playedSongs.contains(spaceToDash(songName.toLowerCase())))
		{
			var stringArray:Array<String> = displayName.split('');
			displayName = '';
			for (j in stringArray)
			{
				if (j == '-')
					displayName += '-';
				else
					displayName += '?';
			}
		}
		
		songs.push(new FreeplaySong(songName, displayName, weekName, icon, FlxColor.fromString(color), charPort));
	}

	inline public static function spaceToDash(string:String):String
		return string.replace(" ", "-");

	var portTween:FlxTween;
	function changePortrait(char:String = 'lamar')
	{
		portrait.loadGraphic(Paths.image('menus/freeplay/'+char));

		if(!FlxG.save.data.playedSongs.contains(spaceToDash(songs[curSelected].songName.toLowerCase())))
		{
			portrait.color = 0xff000000;
		}
		else
		{
			portrait.color = 0xffffffff;
		}

		switch(char)
		{
			case 'jap_1':
				portrait.offset.set(-190, 110);
			case 'jap_2':
				portrait.offset.set(-196, 70);
			case 'jap_3':
				portrait.offset.set(-190, 110);
			case 'jap_4':
				portrait.offset.set(-198, 110);
			case 'gandons':
				portrait.offset.set(-13, 147);
			case 'hwaw':
				portrait.offset.set(-190, 110);
			default:
				portrait.offset.set(0, 0);
		}
		if(portTween != null) portTween.cancel();
		portrait.y == 150;
		portrait.y += 30;
		portTween = FlxTween.tween(portrait, {y: 150}, 0.3, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
            {
                portTween = null;
            }});
	}
	
	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		if (leWeek == null) return false;
		
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}
	
	var instPlaying:Int = -1;
	
	var holdTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		if (freeplayTabs.length == 0) return;

		var mult:Float = FlxMath.lerp(1, icon.scale.x, Math.exp(-elapsed * 9));
		icon.scale.set(mult, mult);
		icon.updateHitbox();
		
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));
		
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;
		
		var ratingSplit:Array<String> = Std.string(funkin.utils.MathUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}
		
		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();
		
		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT) shiftMult = 3;
		
		if (songs.length > 1)
		{
			if (controls.UI_UP_P)
			{
				changeSelection(-shiftMult);
				changePortrait(songs[curSelected].charPort);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				changePortrait(songs[curSelected].charPort);
				holdTime = 0;
			}
			
			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
				
				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changePortrait(songs[curSelected].charPort);
					changeDiff();
				}
			}
		}
		
		if (mayGoToChartConverter)
		{
			if (controls.ACCEPT)
			{
				FlxG.switchState(() -> new funkin.states.editors.ChartConverterState());
				ChartConverterState.goToFreeplay = true;
			}
			if (controls.BACK)
			{
				mayGoToChartConverter = false;
				changeSelection();
			}
			
			super.update(elapsed);
			return;
		}
		
		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxTween.cancelTweensOf(bg, ['color']);
			
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(MainMenuState.new);
		}
		
		if (controls.ACCEPT)
		{
			persistentUpdate = false;
			
			final songName = Paths.sanitize(songs[curSelected].songName.toLowerCase());
			
			final songRet = PlayState.prepareForSong(songName, curDifficulty, false);
			
			if (songRet != null)
			{
				var error = songRet.toString();
				
				if (error.contains('incompatible format') && !error.contains(ChartFormat.UNKNOWN)) // scuffed method...
				{
					error += "\n\nIf you'd like to enter the chart converter press Accept.\nOtherwise, press Cancel to go back";
					mayGoToChartConverter = true;
				}
				
				final message = 'Failed to load song.\nException: $error';
				debugBG.alpha = 0.7;
				debugTxt.text = message;
				debugTxt.screenCenter(Y);
				
				FlxG.sound.play(Paths.sound('cancelMenu'));
				
				super.update(FlxG.elapsed);
				return;
			}
			
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			
			FlxTween.cancelTweensOf(bg, ['color']);
			
			FlxG.switchState(PlayState.new);
			
			if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
			
			destroyFreeplayVocals();
		}
		else if (controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		super.update(elapsed);

		grpSongs.forEach(function(spr:FlxText)
        {
			var centX = (FlxG.height/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);

            spr.y = FlxMath.lerp(spr.y, centY - (curSelected-spr.ID) * 250, FlxMath.bound(elapsed * 10, 0, 1));

            var contrY = centX - Math.abs((curSelected-spr.ID))*200;
			var contrAngle = centY - Math.abs((curSelected-spr.ID))*20;

            spr.x = FlxMath.lerp(spr.x, contrY + 150, FlxMath.bound(elapsed * 10, 0, 1));

			spr.angle = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.angle, 0, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.angle, ((curSelected-spr.ID)) * -20, FlxMath.bound(elapsed * 10.2, 0, 1))
            );

            spr.scale.set(
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1))
            );
            spr.alpha = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.7, FlxMath.bound(elapsed * 5, 0, 1))
            );
        });
	}
	
	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}
	
	function loadFreeplayData()
	{
		var mods:Array<{folder:String, enabled:Bool}> = Mods.getListAsArray();
		
		for (i in mods)
		{
			if (!i.enabled) continue;
			
			var freeplayData = getFreeplayData(i.folder);
			Mods.currentModDirectory = i.folder;
			
			var tabs = freeplayData?.tabs ?? null;
			
			if (tabs == null)
			{
				var dir = FunkinAssets.readDirectory('content/${i.folder}/data/weeks');
				
				var fromWeeks = [];
				for (week in dir)
				{
					final sanitizedWeek = Paths.sanitize(week).replace('.json', '');
					fromWeeks.push(sanitizedWeek);
				}
				
				tabs = [];
				tabs.push(
					{
						title: i.folder,
						directory: i.folder,
						fromWeeks: fromWeeks,
						songs: [],
					});
			}
			
			for (tab in tabs){
				tab.directory = i.folder;
				freeplayTabs.push(tab);
			}
		}
	}
	
	function getSongMeta(song:String):Null<SongMetaData>
	{
		var path = SongMeta.getFromPath(Paths.json('$song/data/meta'));
		
		if (path == null) path = SongMeta.getFromPath(Paths.json('$song/meta'));
		
		return path;
	}
	
	function getFreeplayData(modFolder:String):Null<FreeplayData>
	{
		final freeplayDataPath = Paths.getPath('data/freeplay.json', modFolder, true);
		
		return FunkinAssets.exists(freeplayDataPath) ? FunkinAssets.parseJson5(FunkinAssets.getContent(freeplayDataPath)) : null;
	}
	
	function loadTab(tab:Int):Void
	{
		var tab = freeplayTabs[tab];
		Mods.currentModDirectory = tab.directory; 

		addSong(Paths.sanitize('With Cone (BF Mix)'), [Paths.sanitize('with-cone-(bf-mix)'), 'jap', '#4d250e', 'jap_1']);
		addSong(Paths.sanitize('BOOM (BF Mix)'), [Paths.sanitize('boom-(bf-mix)'), 'jap', '#FF0000', 'jap_2']);
		addSong(Paths.sanitize('Overfire (BF Mix)'), [Paths.sanitize('overfire-(bf-mix)'), 'jap-wheel', '#ff5800', 'jap_3']);


		addSong(Paths.sanitize('Discovery'), [Paths.sanitize('discovery'), 'lore-woke', '#340a54', 'gandons']);
		if (FlxG.save.data.loreCompleted == true) addSong(Paths.sanitize('Untitled'), [Paths.sanitize('Untitled'), 'hwaw-real', '#a88577', 'hwaw']);
	}
	
	function changeDiff(change:Int = 0)
	{
		debugBG.alpha = 0;
		debugTxt.text = '';
		
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.difficulties.length - 1);
		
		lastDifficultyName = Difficulty.difficulties[curDifficulty];
		
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		
		PlayState.storyMeta.difficulty = curDifficulty;
		positionHighscore();
	}
	
	var tweenDiskUp:FlxTween;
	function changeSelection(diff:Int = 0)
	{
		debugBG.alpha = 0;
		debugTxt.text = '';
		
		if (diff != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelected = FlxMath.wrap(curSelected + diff, 0, songs.length - 1);

		icon.changeIcon(songs[curSelected].songCharacter);

		if(!FlxG.save.data.playedSongs.contains(spaceToDash(songs[curSelected].songName.toLowerCase())))
		{
			icon.color = 0xFF000000;
		}
		else
		{
			icon.color = 0xFFFFFFFF;
		}

		if (diff != 0)
		{
			icon.scale.set(1.5, 1.5);

			icon.angle = 0;
			if(tweenDiskUp != null) tweenDiskUp.cancel();
			tweenDiskUp = FlxTween.tween(icon, {angle: 360}, 0.3, {ease: FlxEase.backOut, onComplete: function(twn:FlxTween)
			{
				tweenDiskUp = null;
			}});
		}
		
		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			FlxTween.cancelTweensOf(bg, ['color']);
			intendedColor = newColor;
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		
		Difficulty.reset();
		
		var songMeta = getSongMeta(songs[curSelected].songName);
		
		var weekDiffs:Array<String> = [];
		var songWeek = WeekData.weeksLoaded[songs[curSelected].week];
		if (songWeek != null) weekDiffs = songWeek.difficulties;
		
		if (songMeta != null && songMeta.difficulties != null)
		{
			Difficulty.difficulties = songMeta.difficulties;
		}
		else if (weekDiffs != null && weekDiffs.length > 0)
		{
			Difficulty.difficulties = weekDiffs;
		}
		
		if (Difficulty.difficulties.contains(Difficulty.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(Difficulty.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}
		
		var newPos:Int = Difficulty.difficulties.indexOf(lastDifficultyName);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
	}
	
	function changeTab(diff:Int = 0)
	{
		if (diff != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		var len = freeplayTabs.length - 1;
		if (len < 0) len = 0;
		
		currentTab = FlxMath.wrap(currentTab + diff, 0, len);
		
		clearSongs();
		
		loadTab(currentTab);
		
		createSongs();
	}
	
	function clearSongs()
	{
		songs = [];
		
		if (grpSongs != null)
		{
			grpSongs.forEach(song -> song?.destroy());
			
			grpSongs.clear();
		}
	}
	
	private function positionHighscore()
	{
		scoreBG.scale.x = scoreText.textField.textWidth + 12 + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}
}

class FreeplaySong
{
	public var displayName:String = "";
	public var songName:String = "";
	public var week:String = "";
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var charPort:String = "";
	
	public function new(song:String, displayName:String, week:String, songCharacter:String, color:Int, charPort:String)
	{
		this.songName = song;
		this.displayName = displayName;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.charPort = charPort;
		this.folder = Mods.currentModDirectory;
		if (this.folder == null) this.folder = '';
	}
}

typedef FreeplayData =
{
	var tabs:Array<FreeplayTab>;
}

typedef FreeplayTab =
{
	var title:String;
	
	// if you load a mod freshly without any week jsons the currentModDirectory isn't set
	// you dont have to define this in the mod folder but like you can i guess
	var directory:String;
	
	var ?fromWeeks:Array<String>;
	var ?songs:Array<String>;
}
