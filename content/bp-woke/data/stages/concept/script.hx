

var bg:FlxSprite;
var bg2:FlxSprite;

var player:Bool = false;

function onLoad()
{
	bg = new FlxSprite(0, 0);
	bg.loadGraphic(Paths.image("concept/draft"));
    bg.screenCenter();
	bg.scrollFactor.set(0.9, 0.9);
	bg.antialiasing = true;
    bg.alpha = 0.25;
    bg.setGraphicSize(Std.int(bg.width * 1.5));
	add(bg);

    bg2 = new FlxSprite(0, 0);
	bg2.loadGraphic(Paths.image("concept/colored"));
    bg2.screenCenter();
	bg2.scrollFactor.set(0.9, 0.9);
	bg2.antialiasing = true;
    bg2.setGraphicSize(Std.int(bg2.width * 1.5));
    bg2.alpha = 0.0001;
	add(bg2);

    mosaic = newShader('mosaic');
    mosaic.setFloatArray('uBlocksize', [0.00001, 0.00001]);

    camGame.addShader(mosaic);
    camHUD.addShader(mosaic);
}

function opponentNoteHit(note)
{
	if (!player) return;
	
	if (health > .3) health -= 0.020;
}

function onEvent(name, v1, v2)
{
    switch (name)
    {
        case 'HWAW':
            switch (v1)
            {
                case 'show':
                    camGame.flash(FlxColor.WHITE, 1);
                    playHUD.iconP2.color = 0xFFFFFFFF;
                    bg.alpha = 1;
                    player = true;

                case 'bg2 show':
                    camGame.flash(FlxColor.WHITE, 1);
                    bg2.alpha = 1;

                case 'bg2 disable':
                    camGame.flash(FlxColor.WHITE, 1);
                    bg2.alpha = 0.0001;

                case 'finale':
                    camGame.flash(FlxColor.WHITE, 1);
                    bg2.alpha = 0.26;
                    bg.alpha = 0.25;

                case 'glitch':
                    FlxTween.num(0.000001, 66.0, 4, { ease: FlxEase.expoIn, onUpdate: (t)->{
						mosaic.setFloatArray('uBlocksize', [t.value, t.value]);
					}});

                case 'black':
                    camOther.flash(FlxColor.WHITE, 1);
                    camGame.alpha = 0;
                    camHUD.alpha = 0;
            }
    }
}
function onCreatePost()
{
   dad.color = 0xFF000000;
   gf.visible = false; //hide gf just CRASHES OK?????
   playHUD.iconP2.color = 0xFF000000;
}