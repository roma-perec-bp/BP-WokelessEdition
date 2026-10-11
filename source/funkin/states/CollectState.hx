package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;

import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;

import flixel.tweens.FlxTween;

class CollectState extends MusicBeatState
{
	override function create()
	{
		FlxTransitionableState.skipNextTransOut = true;
		super.create();

		FlxG.camera.flash(FlxColor.BLACK, 1, null, true);

		var love = new FlxSprite().loadGraphic(Paths.image('unlock/end_sections'));
		love.antialiasing = false;
		add(love);
		love.screenCenter();
		love.alpha = 0.0001;

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('unlock/Mario_static');
		bg.animation.addByPrefix('idle', "static play", 24);
        bg.animation.play('idle');
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.0001;
		bg.scrollFactor.set();
		add(bg);

		FlxG.sound.play(Paths.sound('unlock_end'), 1);

		FlxTween.tween(bg, {alpha: 1}, 0.6);

		FlxTween.tween(love.scale, {x: 1.2, y: 1.2}, 10, {
			onComplete: function(twn:FlxTween) {
				FlxTransitionableState.skipNextTransOut = false;
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.switchState(() -> new FreeplayState());
			}
		});

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxTween.tween(love, {alpha: 1}, 1, {ease: FlxEase.sineOut});
			FlxTween.tween(bg, {alpha: 0.3}, 1, {ease: FlxEase.sineOut});
		});

		new FlxTimer().start(9, function(tmr:FlxTimer) {
			FlxTween.tween(bg, {alpha: 1}, 1, {ease: FlxEase.expoIn});
			FlxTween.tween(love, {alpha: 0}, 1, {ease: FlxEase.expoIn});
		});

		var save:FlxSave = new FlxSave();
		save.bind('unlock', CoolUtil.getSavePath());
		save.data.smth = 'There is nothing much';
		save.flush();

		FlxG.save.data.end = true;
		FlxG.save.flush();
	}
}