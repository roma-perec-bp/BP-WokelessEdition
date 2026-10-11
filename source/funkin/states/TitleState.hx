package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import funkin.game.shaders.ColorSwap;
import funkin.data.WeekData;
import funkin.objects.Alphabet;

@:nullSafety
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	public static var closedState:Bool = false;
	
	var skippedIntro:Bool = false;
	var transitioning:Bool = true;
	
	var introEndingText:Array<String> = ['BRUTAL PIZDEC', 'WOKELESS', 'EDITION'];
	var randomIntroText:Array<String> = [];
	
	// objects
	var textGroup:Null<FlxGroup> = null;
	var ngSpr:Null<FlxSprite> = null;
	var logo:Null<FlxSprite> = null;
	var titleText:Null<FlxSprite> = null;
	var swagShader:Null<ColorSwap> = null;
	
	var danceLeft:Bool = false;
	
	public static function init():Void
	{
		FunkinAssets.cache.clearStoredMemory();
		FunkinAssets.cache.clearUnusedMemory();
		
		// for some reason the plugin scripts dont run sometimes when first loaded. oh well
		funkin.scripting.PluginsManager.prepareSignals();
		funkin.scripting.PluginsManager.populate();
		
		if (FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			CoolUtil.setTransSkip();
			FlxG.switchState(FlashingState.new);
			return;
		}
	}
	
	inline public static function getUnlockSave():Bool
	{
		return getFlixelSave('OgreCrew', "Pepper-s-Files", 'OgreCrew', 'unlock');
	}
	
	override public function create():Void
	{
		init();

		if(!getUnlockSave())
			openfl.Lib.application.window.close();
		
		randomIntroText = FlxG.random.getObject(getIntroText());
		
		initStateScript();
		
		super.create();

		startIntro();
		
		persistentUpdate = true;
		
		FlxG.mouse.visible = false;
	}
	
	function startIntro()
	{
		transitioning = false;
		if (!initialized)
		{
			FunkinSound.playMusic(Paths.music('freakyMenu'), 0);
		}
		
		Conductor.bpm = 102;
		
		if (scriptGroup.call('onStartIntro') != ScriptConstants.STOP_FUNC)
		{
			swagShader = new ColorSwap();
			
			logo = new FlxSprite(-150, -100).loadAtlasFrames(Paths.getAtlasFrames('menus/title/logoBumpin'));
			logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logo.animation.play('bump');
			logo.updateHitbox();
			logo.screenCenter();
			add(logo);
			logo.shader = swagShader.shader;
			
			titleText = new FlxSprite(100, 630).loadAtlasFrames(Paths.getAtlasFrames('menus/title/titleEnter'));
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
			titleText.animation.play('idle');
			titleText.updateHitbox();
			add(titleText);
			
			textGroup = new FlxGroup();
			add(textGroup);
			
			ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image('menus/title/newgrounds_logo'));
			add(ngSpr);
			ngSpr.visible = false;
			ngSpr.scale.scale(0.8);
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			
			logo.alpha = 0.001;
			titleText.alpha = 0.001;
		}
		
		if (initialized)
		{
			skipIntro();
		}
		else
		{
			initialized = true;
		}
		
		scriptGroup.call('onCreatePost', []);
	}
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		
		final pressedEnter:Bool = FlxG.gamepads.lastActive?.justPressed.START || FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		
		if (!transitioning && skippedIntro)
		{
			if (pressedEnter && scriptGroup.call('onEnter', []) != ScriptConstants.STOP_FUNC)
			{
				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				transitioning = true;
				
				if (titleText != null)
				{
					titleText.animation.play('press');
				}
				
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				
				FlxTimer.wait(1, () -> {
					FlxG.switchState(VideoLoadState.new);
					closedState = true;
				});
			}
		}
		
		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}
		
		if (swagShader != null)
		{
			if (controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}
		
		super.update(elapsed);
	}
	
	function createCoolText(textArray:Array<String>, offset:Float = 0)
	{
		if (textGroup == null) return;
		
		for (i in 0...textArray.length)
		{
			final text:Alphabet = new Alphabet(0, 0, textArray[i], true);
			text.screenCenter(X);
			text.y += (i * 60) + 200 + offset;
			
			textGroup.add(text);
		}
	}
	
	function addMoreText(text:String, offset:Float = 0)
	{
		if (textGroup == null) return;
		
		final coolText:Alphabet = new Alphabet(0, 0, text, true);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200 + offset;
		textGroup.add(coolText);
	}
	
	function deleteCoolText()
	{
		if (textGroup != null && textGroup.members[0] != null)
		{
			for (i in 0...textGroup.length)
			{
				var txt = textGroup.members[0];
				textGroup.remove(txt, true);
				
				txt = FlxDestroyUtil.destroy(txt);
			}
		}
	}
	
	function getIntroText():Array<Array<String>>
	{
		if (!FunkinAssets.exists(Paths.txt('introText'))) return [];
		
		final fullText:String = FunkinAssets.getContent(Paths.txt('introText'));
		
		return [for (i in fullText.split('\n')) i.split('--')];
	}
	
	var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen
	
	override function beatHit()
	{
		super.beatHit();
		
		if (!closedState)
		{
			sickBeats++;
			scriptGroup.set('curBeat', sickBeats);
		}
		
		if (logo != null)
		{
			logo.animation.play('bump', true);
		}
		
		if (!closedState)
		{
			switch (sickBeats)
			{
				case 1:
					FunkinSound.playMusic(Paths.music('freakyMenu'), 0);
					
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['We tried', 'to do']);
				case 4:
					addMoreText('This shit');
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['But we', 'decided to'], -40);
				case 8:
					addMoreText('CANCEL IT', -40);
					if (ngSpr != null) ngSpr.visible = true;
				case 9:
					deleteCoolText();
					if (ngSpr != null) ngSpr.visible = false;
				case 10:
					createCoolText(['Ladies and gentlemants'], -40);
				case 12:
					addMoreText('We present you!');
				case 13:
					deleteCoolText();
				case 14:
					if (introEndingText[0] != null) addMoreText(introEndingText[0]);
				case 15:
					if (introEndingText[1] != null) addMoreText(introEndingText[1]);
				case 16:
					if (introEndingText[2] != null) addMoreText(introEndingText[2]);
				case 17:
					skipIntro();
			}
		}
	}
	
	public function skipIntro():Void
	{
		if (scriptGroup.call('onSkipIntro', []) != ScriptConstants.STOP_FUNC && !skippedIntro)
		{
			ngSpr?.kill();
			textGroup?.kill();
			
			if (logo != null) logo.alpha = 1;
			if (titleText != null) titleText.alpha = 1;
			
			FlxG.camera.flash(FlxColor.WHITE, 4);
			
			skippedIntro = true;
		}
	}

		/**
	 * Check for an existing HaxeFlixel save file.
	 *
	 * @param   company		The company of the HaxeFlixel title, required for saves before 5.0.0+.
	 * @param   title		The title/name of the HaxeFlixel title, required for saves before 5.0.0+.
	 * @param   localPath	The path of the save file.
	 * @param   name			The name of the save file.
	 * @param   newPath		Whether or not the save file is from a HaxeFlixel title that's on 5.0.0+.
	**/
	public static function getFlixelSave(company:String, title:String, localPath:String = 'ninjamuffin99', name:String = 'funkin', newPath:Bool = false):Bool
	{
		// before anyone asks, this is copy-pasted from FlxSave
		var invalidChars = ~/[ ~%&\\;:"',<>?#]+/;

		// Avoid checking for .sol files directly in AppData
		if (localPath == "")
		{
			var path = company;

			if (path == null || path == "")
			{
				path = "HaxeFlixel";
			}
			else
			{
				#if html5
				// most chars are fine on browsers
				#else
				path = invalidChars.split(path).join("-");
				#end
			}

			localPath = path;
		}

		var directory = lime.system.System.applicationStorageDirectory;
		var path = '';

		if (newPath)
			path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		else
			path = haxe.io.Path.normalize('$directory/../../../$company/$title') + "/";

		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}

		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}

		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		//trace(path + name + ".sol");

		return FileSystem.exists(path + name + ".sol");
	}
}
