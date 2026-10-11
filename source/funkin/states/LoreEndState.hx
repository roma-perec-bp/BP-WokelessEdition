package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class LoreEndState extends MusicBeatState
{
	public static var leftState:Bool = false;
	
	var warnText:FlxText;
	
	override function create()
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		warnText = new FlxText(0, 0, FlxG.width, "Great job!\nThere is one more song to play\n\nTime to play against the one who you controlled most of the time...", 32);
		warnText.setFormat(Paths.DEFAULT_FONT, 32, 0xFF440000, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		FlxG.save.data.loreCompleted = true;
		FlxG.save.flush();
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
