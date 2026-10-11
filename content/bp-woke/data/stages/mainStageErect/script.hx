import funkin.objects.Bopper;
import funkin.utils.MathUtil;
import funkin.objects.stageobjects.DadBattleFog;

final path = 'backgrounds/week1/erect';
var rom:Character;
public var singAnimations = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

var rom_appear:FlxSprite;
var gf_appear:FlxSprite;

var dadbattleBlack:BGSprite;
var dadbattleLight:BGSprite;
var dadbattleFog:DadBattleFog;

var sc1:FlxSprite;
var sc2:FlxSprite;

function onLoad()
{
	var solid = new FlxSprite(-500, -1000).makeGraphic(2400, 2000, 0xFF222026);
	solid.scrollFactor.set();
	add(solid);
	
	brightLightSmall = new FlxSprite(967, -103).loadGraphic(Paths.image('$path/brightLightSmall'));
	brightLightSmall.scrollFactor.set(1.2, 1.2);
	brightLightSmall.zIndex = 10;
	add(brightLightSmall);
	
	crowd = new Bopper(682, 290).setFrames(Paths.getSparrowAtlas('$path/crowd'));
	crowd.addAnimByPrefix('idle', 'idle', 12, true);
	crowd.dance();
	crowd.scrollFactor.set(.8, .8);
	crowd.zIndex = 5;
	add(crowd);
	
	var bg = new FlxSprite(-765, -247).loadGraphic(Paths.image('$path/bg'));
	bg.zIndex = 20;
	add(bg);
	
	var server = new FlxSprite(-991, 205).loadGraphic(Paths.image('$path/server'));
	server.zIndex = 30;
	add(server);
	
	lights = new FlxSprite(-847, -245).loadGraphic(Paths.image('$path/lights'));
	lights.zIndex = 4000;
	lights.scrollFactor.set(1.2, 1.2);
	add(lights);
	
	orangeLight = new FlxSprite(189, -500).loadGraphic(Paths.image('$path/orangeLight'));
	orangeLight.setScale(1, 1700);
	orangeLight.zIndex = 80;
	add(orangeLight);
	
	lightgreen = new FlxSprite(-171, 242).loadGraphic(Paths.image('$path/lightgreen'));
	lightgreen.zIndex = 40;
	add(lightgreen);
	
	lightred = new FlxSprite(-101, 560).loadGraphic(Paths.image('$path/lightred'));
	lightred.zIndex = 40;
	add(lightred);
	
	lightAbove = new FlxSprite(804, -117).loadGraphic(Paths.image('$path/lightAbove'));
	lightAbove.zIndex = 4500;
	add(lightAbove);

	dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
	dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
	dadbattleBlack.alpha = 0.6;
	dadbattleBlack.visible = true;
	dadbattleBlack.zIndex = 5000;
	add(dadbattleBlack);

	dadbattleLight = new BGSprite('spotlight', 400, -400);
	dadbattleLight.alpha = 0.375;
	dadbattleLight.blend = 0;
	dadbattleLight.visible = false;
	dadbattleLight.zIndex = 5000;
	add(dadbattleLight);

	dadbattleFog = new DadBattleFog();
	dadbattleFog.visible = true;
	dadbattleFog.zIndex = 5000;
	add(dadbattleFog);
	
	brightLightSmall.blend = orangeLight.blend = lightgreen.blend = lightred.blend = lightAbove.blend = 0;

	mosaic = newShader('mosaic');
    mosaic.setFloatArray('uBlocksize', [0.00001, 0.00001]);

    camGame.addShader(mosaic);

	sc1 = new FlxSprite(0, 0);
	sc1.loadGraphic(Paths.image('$path/penis'));
    sc1.screenCenter();
	sc1.scrollFactor.set(1, 1);
	sc1.antialiasing = true;
    sc1.cameras = [campreHUD];
    sc1.alpha = 0.0001;
	add(sc1);

	sc2 = new FlxSprite(0, 0);
	sc2.loadGraphic(Paths.image('$path/penis2'));
    sc2.screenCenter();
	sc2.scrollFactor.set(1, 1);
	sc2.antialiasing = true;
    sc2.cameras = [campreHUD];
    sc2.alpha = 0.0001;
	add(sc2);
}

function makeCharShader(_brightness, _hue, _contrast, _saturation)
{
	var shader = newShader('adjustColor');
	shader.setFloat('brightness', _brightness);
	shader.setFloat('hue', _hue);
	shader.setFloat('contrast', _contrast);
	shader.setFloat('saturation', _saturation);
	
	return shader;
}

function onCreatePost()
{
	rom = new Character(dad.x + 400, dad.y, 'discovery-rom');
	rom.danceEveryNumBeats = 2;
	rom.zIndex = 100;
	rom.animSuffix = '-intro';
	//startCharacterPos(rom);
	stage.add(rom);

	//boyfriend.shader = makeCharShader(-23, 12, 7, 0);
	//gf.shader = makeCharShader(-30, -9, -4, 0);
	dad.shader = makeCharShader(-33, -32, -23, 0);
	rom.shader = makeCharShader(-30, -25, -10, 0);

	rom.visible = false;
	gf.visible = false;

	rom_appear = new Bopper(dad.x + 400, dad.y + 50).setFrames(Paths.getSparrowAtlas('$path/rom_hi'));
	rom_appear.addAnimByPrefix("idle", "rom_appear", 24, false);
	rom_appear.animation.play("idle");
	rom_appear.scrollFactor.set(1, 1);
	rom_appear.antialiasing = true;
	add(rom_appear);
	rom_appear.alpha = 0.0001;
	rom_appear.zIndex = 100;

	gf_appear = new Bopper(-600, -300).setFrames(Paths.getSparrowAtlas('$path/gf_hi'));
	gf_appear.addAnimByPrefix("idle", "gf_appear", 24, false);
	gf_appear.animation.play("idle");
	gf_appear.scrollFactor.set(1, 1);
	gf_appear.antialiasing = true;
	add(gf_appear);
	gf_appear.alpha = 0.0001;
	gf_appear.zIndex = 100;

	black = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xff000000);
	black.cameras = [campreHUD];
	add(black);
}

function onSongStart()
{
	FlxTween.tween(black, {alpha: 0}, 1);
}

function onEvent(name, v1, v2)
{
    switch (name)
    {
		case "Dadbattle Spotlight":
			if(v1 == null) v1 = 0;
			var val:Int = Math.round(v1);

			switch(val)
			{
				case 1, 2, 3: //enable and target dad
					if(val == 1) //enable
					{
						dadbattleBlack.visible = true;
						dadbattleLight.visible = true;
						//dadbattleFog.visible = true;
						//defaultCamZoom += 0.12;
					}

					var who:Character = dad;
					if(val > 2) who = boyfriend;
					//2 only targets dad
					dadbattleLight.alpha = 0;
	
					dadbattleLight.alpha = 0.375;

						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);
					FlxTween.tween(dadbattleFog, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});

				default:
					dadbattleBlack.visible = false;
					dadbattleLight.visible = false;
					//defaultCamZoom -= 0.12;
					camGame.flash(FlxColor.WHITE, 0.5);
					FlxTween.tween(dadbattleFog, {alpha: 0}, 0.7, {onComplete: function(twn:FlxTween) dadbattleFog.visible = false});
			}

         case 'LORE':
            switch (v1)
            {
				case 'black':
					camGame.flash(FlxColor.BLACK, 0.5);

				case 'rom-default':
					rom.playAnim('trans', true);
					rom.animSuffix = '';
					rom.specialAnim = true;

				case 'anger':
					rom.animSuffix = '-shock';
					rom.playAnim('trans', true);
					rom.specialAnim = true;

					dad.animSuffix = '-angry';
					dad.playAnim('trans', true);
					dad.specialAnim = true;

				case 'mad-umbra':
					dad.animSuffix = '-curious';
					FlxG.sound.play(Paths.sound('hitStatic1'));

					camGame.shake(0.010, 0.3);
					campreHUD.shake(0.010, 0.3);

					sc1.alpha = 1;
					new FlxTimer().start(0.1, function(_) {
						sc1.alpha = 0.001;
						sc2.alpha = 1;
						new FlxTimer().start(0.1, function(_) {
							sc2.alpha = 0.001;
						});
					});

				case 'rom-cutscene':
					rom.playAnim('cutscene', true);
					rom.specialAnim = true;

                case 'rom visible':
					playHUD.iconP3.visible = true;
					camGame.flash(FlxColor.WHITE, 0.5);
					rom.visible = true;
					rom_appear.visible = false;

				case 'gf visible':
					playHUD.iconGF.visible = true;
					camGame.flash(FlxColor.WHITE, 0.5);
					gf.visible = true;
					gf_appear.visible = false;

				case 'rom appear':
					rom_appear.alpha = 1;
					rom_appear.animation.play("idle", true);

				case 'gf appear':
					gf_appear.alpha = 1;
					gf_appear.animation.play("idle", true);
				case 'end':
					FlxTween.num(0.000001, 66.0, 2, {onUpdate: (t)->{
						mosaic.setFloatArray('uBlocksize', [t.value, t.value]);
					}});
					FlxTween.tween(camGame, {alpha: 0}, 2);
			}
	}

}
function onDestroy():Void
{
	rom.destroy();
}

function onBeatHit()
{
	rom.onBeatHit(curBeat);
}

function onCountdownTick()
{
	rom.onBeatHit(curBeat);
}

function goodNoteHitPre(note)
{
	if (note.noteType == 'Both Opponents Sing')
	{
		final animToPlay = singAnimations[Std.int(Math.abs(note.noteData))];
				
		gf.holdTimer = 0;
				
		if (!(gf.vSliceSustains && note.isSustainNote))
		{		
			gf.playAnim(animToPlay, true);
		}
	}
}

function opponentNoteHitPre(note)
{
	var romSing:Bool = (note.noteType == 'Rom Sing');
	
	if (note.noteType == 'Both Opponents Sing')
	{
		final animToPlay = singAnimations[Std.int(Math.abs(note.noteData))];
				
		rom.holdTimer = 0;
				
		if (!(rom.vSliceSustains && note.isSustainNote))
		{		
			rom.playAnim(animToPlay, true);
		}
	}

	if (romSing)
	{
		note.owner = rom;
	}
}
