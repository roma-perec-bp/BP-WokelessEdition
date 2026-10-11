function onLoad()
{
    black = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xff000000);
	add(black);

    black2 = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xff000000);
    black2.alpha = 0.0001;
	add(black2);

    FlxG.camera.zoom = 1.3;

    //black.cameras = [camHUD];
    black2.cameras = [camOther];
}

function onBeatHit()
{
	switch (curBeat)
	{
		case 8:
            FlxTween.tween(black, {alpha: 0}, 2);

        case 698:
            FlxTween.tween(black2, {alpha: 1}, 5);
    }
}