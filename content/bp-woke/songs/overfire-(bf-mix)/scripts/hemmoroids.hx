import openfl.filters.ShaderFilter;

var rainShader:FlxShader;
var rainTime:Float = 0;

var startIntensity:Float = 0;
var endIntensity:Float = 0.1;

function onCreatePost()
{
    skipCountdown = true;
    camGame.alpha = 0.0001;

    playHUD.healthBar.visible = false;
    playHUD.iconP2.visible = false;
    playHUD.iconP1.visible = false;
    playHUD.scoreTxt.visible = false;

    opponentStrums.visible = false;

    playerStrums.visible = false;

    timeTxt.visible = false;
    timeBar.visible = false;
    timeBarBG.visible = false;

    startIntensity = 0.2;
	endIntensity = 0.4;

    rainShader = newShader('rain');
	rainShader.setFloatArray('uScreenResolution', [FlxG.width, FlxG.height]);
	rainShader.setFloat('uTime', 0);
	rainShader.setFloat('uScale', FlxG.height / 300);
	rainShader.setFloat('uIntensity', startIntensity);
}

function onUpdate(elapsed)
{
	rainTime += elapsed;
	rainTime++;
	
	var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, startIntensity, endIntensity);
	
	rainShader.setFloatArray('uCameraBounds', [
		camGame.scroll.x + camGame.viewMarginX,
		camGame.scroll.y + camGame.viewMarginY,
		camGame.scroll.x + camGame.viewMarginX + camGame.width,
		camGame.scroll.y + camGame.viewMarginY + camGame.height
	]);
	rainShader.setFloat('uTime', rainTime);
	rainShader.setFloat('uIntensity', remappedIntensityValue);
}

function onEvent(name, v1, v2)
{
    switch (name)
    {
        case 'OF':
            switch (v1)
            {
                case '1':
                    opponentStrums.visible = true;

                case '2':
                    playerStrums.visible = true;

                case '3':
                    playHUD.healthBar.visible = true;
                    playHUD.iconP2.visible = true;
                    playHUD.iconP1.visible = true;
                    playHUD.scoreTxt.visible = true;

                case '4':
                    timeTxt.visible = true;
                    timeBar.visible = true;
                    timeBarBG.visible = true;
                
                case 'start':
                    camGame.alpha = 1;
                    camGame.flash(FlxColor.WHITE, 1);
                    camGame.filters = [new ShaderFilter(rainShader) /*, new ShaderFilter(rain2)*/];

                case 'back':
                    camGame.filters = [new ShaderFilter(rainShader) /*, new ShaderFilter(rain2)*/];
            }
    }
}