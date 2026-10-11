package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FirstEndState extends MusicBeatState
{
	public static var leftState:Bool = false;
	
	var warnText:FlxText;
	
	override function create()
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		warnText = new FlxText(0, 0, FlxG.width, "You Did It! You saved grass!\nBut we are not done yet!\n\nCHECK FREEPLAY", 32);
		warnText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}
	
	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				leftState = true;

				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.volume = 1;
					
				CoolUtil.cancelMusicFadeTween();
				FlxG.switchState(() -> new MainMenuState());
			}
		}
		super.update(elapsed);
	}
}
