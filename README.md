# watch-your-profanity
An OBS plugin that displays a running tally of how many swear words you say during a stream.

### General problems to solve
- find a way to get mic input from computer using Python
- can you even make an OBS plugin using Python?
  - using the OBS scripting option which supports Python may be enough. If I can get the script to just handle everything in the background and display the text in the scene it could work. But the mic input would need to be handled outside OBS, it seems only Lua supports adding obslib sources.
- how do you make an OBS plugin?
- find a good free speech-to-text API or an efficient on-device model
  - [whisper.cpp](https://github.com/ggerganov/whisper.cpp) seems like a very efficient model that can offload the transcription to each user and with no API cost. I also tested it briefly and it does transcribe swear words.
- Things to include in overlay display:
  - Swear counter: ##
  - Relative swearing: (# swear words/minutes streamed)
- optional or automatic output from each session that displays frequency of each word count
  - see if you can use Twitch API or soemthing to define sessions when stream starts and ends
 - ???
