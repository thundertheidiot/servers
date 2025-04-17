# set("init.allow_root", true)
set("log.stdout", true)

mods = playlist(mode="randomize", "/nix/persist/radio/mods")
general = mods

output.icecast(
	%vorbis(samplerate=44100, channels=2, quality=0.6),
	host = "icecast", port = 8002,
	password = "icecast", mount = "radio.ogg",
	mksafe(general))