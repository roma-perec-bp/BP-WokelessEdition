import funkin.game.shaders.DropShadowShader;
import flixel.addons.display.FlxBackdrop;

var wireframe:BGSprite;
var day:FlxSprite;
var light:FlxSprite;
var shad1:FlxSprite;
var shad2:FlxSprite;
var black:FlxSprite;

var rimD:DropShadowShader;
var rimB:DropShadowShader;
var rimG:DropShadowShader;

var mist0:FlxBackdrop;
function onLoad()
{
	day = new FlxSprite(0, 0);
	day.loadGraphic(Paths.image("bf-stage/day"));
    day.screenCenter();
	day.scrollFactor.set(1, 1);
	day.antialiasing = true;
    day.setGraphicSize(Std.int(day.width * 1.5));
	add(day);

    wireframe = new BGSprite('bf-stage/wireframe', 0, 0, 1, 1, ['grass_anim'], true);
    wireframe.screenCenter();
	wireframe.scrollFactor.set(1, 1);
	wireframe.antialiasing = true;
    wireframe.setGraphicSize(Std.int(day.width * 1.5));
    wireframe.alpha = 0.0001;
	add(wireframe);

    if(!ClientPrefs.lowQuality)
    {
        light = new FlxSprite(0, 0);
        light.loadGraphic(Paths.image("bf-stage/light"));
        light.screenCenter();
        light.scrollFactor.set(1, 1);
        light.antialiasing = true;
        light.setGraphicSize(Std.int(light.width * 1.5));
        add(light);
        light.blend = 0;
    
        shad1 = new FlxSprite(0, 0);
        shad1.loadGraphic(Paths.image("bf-stage/shad1"));
        shad1.screenCenter();
        shad1.scrollFactor.set(1, 1);
        shad1.antialiasing = true;
        shad1.setGraphicSize(Std.int(shad1.width * 1.5));
        add(shad1);
        shad1.alpha = 0.5;
        shad1.blend = 0;
    
        shad2 = new FlxSprite(0, 0);
        shad2.loadGraphic(Paths.image("bf-stage/shad2"));
        shad2.screenCenter();
        shad2.scrollFactor.set(1, 1);
        shad2.antialiasing = true;
        shad2.setGraphicSize(Std.int(shad2.width * 1.5));
        add(shad2);
        shad2.alpha = 0.5;
        shad2.blend = 0;
    
        mist0 = new FlxBackdrop(Paths.image('bf-stage/mistFront'), 0x01);
        mist0.setPosition(-650, 100);
        mist0.scrollFactor.set(1.2, 1.2);
        mist0.zIndex = 700;
        mist0.blend = 0;
        mist0.color = 0xFF5c5c5c;
        mist0.alpha = 0.6;
        mist0.velocity.x = 172;
        add(mist0);

        light.zIndex = 500;
        shad1.zIndex = 500;
        shad2.zIndex = 500;
    }

    grad = new FlxSprite(0, 0);
	grad.loadGraphic(Paths.image("bf-stage/grad"));
    grad.screenCenter();
	grad.scrollFactor.set(1, 1);
	grad.antialiasing = true;
    grad.y += 200;
    grad.setGraphicSize(Std.int(grad.width * 1.5));
	add(grad);

    black = new FlxSprite(-2000, -2000).makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xff000000);
    black.alpha = 0.0001;
    black.scrollFactor.set(0,0);
	add(black);

    grad.zIndex = 999;
    black.zIndex = 999;

    if(!ClientPrefs.lowQuality)
    {
        fire = new FlxSprite(-140, -100);
        fire.frames = Paths.getSparrowAtlas("bf-stage/awesome fire");
        fire.animation.addByPrefix('idle', 'awesome fire', 24, true);
        fire.animation.play('idle');
        fire.scrollFactor.set(0, 0);
        fire.setGraphicSize(Std.int(fire.width * 2));
        fire.blend = BlendMode.ADD;
        fire.alpha = 0.001;
        fire.zIndex = 20;

        add(fire);
    }
}

function onEvent(name, v1, v2)
    {
        switch (name)
        {
            case 'OF':
                switch (v1)
                {
                    case 'start':
                        black.alpha = 0.6;
                        light.alpha = 0;
                        
                        boyfriend.shader = makeCharShader(-100, -42, 24, -22);
                        dad.shader = makeCharShader(-100, -42, 24, -22);
                        gf.shader = makeCharShader(-100, -42, 24, -22);

                    case 'wireframe':
                        camGame.flash(FlxColor.WHITE, 0.5);
                        camGame.filters = [];
                        wireframe.alpha = 1;
                        shad1.visible = false;
                        shad2.visible = false;
                        day.visible = false;
                        gf.visible = false;
                        black.alpha = 0;
                        mist0.alpha = 0;
                    
                    case 'black':
                        wireframe.alpha = 0;
                        shad1.visible = true;
                        shad2.visible = true;
                        day.visible = true;
                        gf.visible = true;
                        black.alpha = 1;
                        mist0.alpha = 0.6;

                    case 'back':
                        camGame.flash(FlxColor.WHITE, 1);
                        black.alpha = 0.6;

                    case 'end':
                        FlxTween.tween(black, {alpha: 1}, 1);
                }
            case 'WC':
                switch (v1)
                {
                    case 'boom':
                        if(ClientPrefs.lowQuality) return;

                        FlxTween.tween(fire, {alpha: 1}, 30, {ease: FlxEase.quintOut});

                    case 'boom_end':
                        if(ClientPrefs.lowQuality) return;

                        FlxTween.cancelTweensOf(fire);
                        FlxTween.tween(fire, {alpha: 0}, 7, {ease: FlxEase.quintOut});
                    
                    case 'that part':
                        camGame.flash(FlxColor.WHITE, 1);

                        if(!ClientPrefs.lowQuality)
                        {
                            light.visible = false;
                            shad1.visible = false;
                            shad2.visible = false;
                        }

                        day.visible = false;
                        gf.visible = false;

                        if(!ClientPrefs.lowQuality) mist0.alpha = 0;

                        boyfriend.colorTransform.redOffset = 0;
                        boyfriend.colorTransform.blueOffset = 255;
                        boyfriend.colorTransform.greenOffset = 200;

                        boyfriend.colorTransform.redMultiplier = 0;
                        boyfriend.colorTransform.blueMultiplier = 0;
                        boyfriend.colorTransform.greenMultiplier = 0;

                        dad.colorTransform.redOffset = 255;
                        dad.colorTransform.blueOffset = 0;
                        dad.colorTransform.greenOffset = 0;

                        dad.colorTransform.redMultiplier = 0;
                        dad.colorTransform.blueMultiplier = 0;
                        dad.colorTransform.greenMultiplier = 0;

                        dad.shader = null;
                        boyfriend.shader = null;
    
                    case 'black':
                        black.alpha = 1;
    
                    case 'part end':
                        camGame.flash(FlxColor.WHITE, 1);
                        black.alpha = 0.0001;

                        if(!ClientPrefs.lowQuality)
                        {
                            light.visible = true;
                            shad1.visible = true;
                            shad2.visible = true;
                        }

                        day.visible = true;
                        gf.visible = true;
                        if(!ClientPrefs.lowQuality) mist0.alpha = 0.6;

                        boyfriend.colorTransform.redOffset = 0;
                        boyfriend.colorTransform.blueOffset = 0;
                        boyfriend.colorTransform.greenOffset = 0;

                        boyfriend.colorTransform.redMultiplier = 1;
                        boyfriend.colorTransform.blueMultiplier = 1;
                        boyfriend.colorTransform.greenMultiplier = 1;

                        dad.colorTransform.redOffset = 0;
                        dad.colorTransform.blueOffset = 0;
                        dad.colorTransform.greenOffset = 0;

                        dad.colorTransform.redMultiplier = 1;
                        dad.colorTransform.blueMultiplier = 1;
                        dad.colorTransform.greenMultiplier = 1;

                        dad.shader = rimD;
                        boyfriend.shader = rimB;
                }
        }
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
    day.shader = makeCharShader(-100, -22, 24, -22);

    if (gf.animateAtlas != null) gf.animateAtlas.useRenderTexture = true;

	rimD = new DropShadowShader();
	rimD.setAdjustColor(-100, -42, 24, -22);
	rimD.color = 0xFFDFEF3C;
	rimD.angle = 120;
    rimD.distance = 15;

    dad.shader = rimD;
    dad.animation.onFrameChange.add(() -> {
        rimD.updateFrameInfo(dad.frame);
    });

    rimG = new DropShadowShader();
	rimG.setAdjustColor(-100, -42, 24, -22);
	rimG.color = 0xFFDFEF3C;
	rimG.angle = 120;
    rimG.distance = 15;

    gf.shader = rimG;
    gf.animation.onFrameChange.add(() -> {
        rimG.updateFrameInfo(gf.frame);
    });

    rimB = new DropShadowShader();
	rimB.setAdjustColor(-100, -42, 24, -22);
	rimB.color = 0xFFDFEF3C;
	rimB.angle = 120;
    rimB.distance = 15;

    boyfriend.shader = rimB;
    boyfriend.animation.onFrameChange.add(() -> {
        rimB.updateFrameInfo(boyfriend.frame);
    });
}