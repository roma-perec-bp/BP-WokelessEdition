import haxe.Json;
import sys.io.File;
import funkin.backend.Conductor;
import flixel.text.FlxText;
import funkin.scripting.PluginsManager;

typedef LyricData = {
	lyric:String,
	timestamp:Float,
	color:String
}

function loadJson() {
	var rawJson = File.getContent(Paths.modFolders(StringTools.replace('songs/' + PlayState.SONG.song.toLowerCase() + '/data/lyrics.json', ' ', '-')));
	var data = Json.parse(rawJson);

	return data;
}

// {"lyric": "", "timestamp": 0},
var json = loadJson();
var data:Array<LyricData> = [];
var textGrp:FlxSpriteGroup;

function onLoad() {
	data = json.stuff;

	subtitlemark = new FlxSprite(0,0).makeGraphic(1, 1, FlxColor.BLACK);
	subtitlemark.visible = false;
	subtitlemark.zIndex = 998;
	subtitlemark.alpha = 0.5;
	subtitlemark.camera = camOther;
	add(subtitlemark);

	poop = new FlxText();
	poop.setFormat(Paths.font('vcr-rus.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	poop.borderSize = 2.5;
	poop.text = "";
	poop.screenCenter(FlxAxes.X);
	poop.y = playHUD.healthBar.y + (ClientPrefs.downScroll ? 65 : -65);
	poop.antialiasing = true;
	poop.camera = camOther;
	add(poop);
	poop.zIndex = 99999;
	refreshZ(playHUD);


	for (i in 0...data.length) {
		var j = data[i];

		modManager.queueFuncOnce(j.timestamp, (s, s2) -> {
			poop.text = StringTools.replace(j.lyric, '\'', '');
			poop.color = FlxColor.fromString(j.color);
			poop.screenCenter(FlxAxes.X);
			subtitlemark.scale.set(poop.width + 20, poop.size + 8);
			subtitlemark.updateHitbox();
			subtitlemark.x = (FlxG.width/2) - subtitlemark.width / 2;
			subtitlemark.y = poop.y + 2;
			//trace(poop.width);

			subtitlemark.visible = poop.text != "";	
		});
	}
}

function onGameOver()
{
	if(subtitlemark != null) subtitlemark.visible = false;
	if(poop != null) poop.visible = false;
}