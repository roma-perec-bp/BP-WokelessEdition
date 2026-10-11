package funkin.states;

#if VIDEOS_ALLOWED
import funkin.video.FunkinVideoSprite;
#end


@:nullSafety
class VideoLoadState extends MusicBeatState
{
    override public function create():Void // I DONT LIKE LAG ON WITH CONE BF MIX :<
    {
        var videoCache:FunkinVideoSprite = new FunkinVideoSprite();
		videoCache.onFormat(() -> {
			add(videoCache);
		});
		videoCache.load(Paths.video('lol'), [FunkinVideoSprite.muted]);
        
    	videoCache.play();
		videoCache.alpha = 0.001;

		videoCache.onEnd(() -> {
			FlxG.switchState(MainMenuState.new);
		});
    }
}