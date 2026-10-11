import funkin.FunkinAssets;

function onCreatePost() {
	if (FunkinAssets.exists(Paths.modFolders(StringTools.replace('songs/' + PlayState.SONG.song.toLowerCase() + '/data/lyrics.json', ' ', '-'))))
		initScript('data/scripts/Lyrics');
}