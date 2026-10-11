var canDance:Bool = false;
var vignette:FlxSprite;

function onCreatePost()
{
    phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];

    FlxG.camera.zoom = 1;
    camGame.alpha = camHUD.alpha = 0;
    skipCountdown = true;
        
    intro = new FunkinVideoSprite();
    intro.onFormat(() -> {
        intro.cameras = [camOther];
        intro.setGraphicSize(FlxG.width);
        intro.screenCenter();
        add(intro);
    });
    intro.onEnd(() -> {
        camGame.alpha = 1;
        camHUD.alpha = 1;
        camGame.flash(0xFFFFFFFF, 0.35);
        intro.kill();
    });
    intro.load(Paths.video('intro_withcone'), [FunkinVideoSprite.muted]);
    intro.antialiasing = ClientPrefs.globalAntialiasing;
        
    // Desync prevention (at least as much as I can do)
    intro.play();
    intro.pause();
    intro.tiedToGame = false;
    
    //camSpecialThing([-650, 700], [650, 800]);

    vignette = new FlxSprite(0, 0);
	vignette.loadGraphic(Paths.image("bf-stage/discoVin"));
    vignette.screenCenter();
	vignette.scrollFactor.set(1, 1);
	vignette.antialiasing = true;
    vignette.cameras = [campreHUD];
    vignette.setGraphicSize(Std.int(FlxG.width));
    vignette.alpha = 0.0001;
	add(vignette);
}
    
function onSongStart()
{
    intro.play();
    intro.tiedToGame = true;
}
    
function onEvent(name, v1, v2)
{
    switch (name)
    {
        case 'WC':
            switch (v1)
            {
                case 'skip vid':
                    if (intro != null)
				    {
					    camGame.alpha = 1;
					    camHUD.alpha = 1;
					    intro.kill();
					    camGame.flash(FlxColor.WHITE, 0.35);
				    }
                case 'dance':
                    canDance = true;
                    camGame.flash(FlxColor.WHITE, 0.5);

                case 'end dance':
                    canDance = false;
                    FlxTween.tween(vignette, {alpha: 0.0001}, 1);
            }
    }
}
   
var curLight:Int = -1;

function onBeatHit()
{
    if (canDance)
    {
        FlxTween.cancelTweensOf(vignette);
        vignette.alpha = 0.5;
        curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
        vignette.color = phillyLightsColors[curLight];
        FlxTween.tween(vignette, {alpha: 0.0001}, Conductor.stepCrotchet * 0.01);
    }

    switch (curBeat)
	{
		case 696:
            FlxG.camera.fade(FlxColor.BLACK, 3, false);
    }
}