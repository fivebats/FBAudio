# FBAudio Library

This was created as part of the "Rock and Run" project from [iOSDevCamp11](http://www.iosdevcamp.org/).

We needed code to play songs from the user's iTunes library while making changes to the song tempo to match the runner's pace.

iOSDevCamp takes place over a weekend, so the point is to create an interesting application and demonstrate it very quickly. In that spirit this code is very alpha and not tested very well. Feel free to improve it!

## What is Here

### Players

There are a few different players. From lowest to highest level they are:

*  **FBAudioQueuePlayer**.
   This plays audio using Audio Queue services. A user-provided callback function is called repeatedly to add audio to the playback queue.

*  **FBAVAssetPlayer**.
   This uses the FBAudioQueuePlayer, feeding it audio from a user-specified AVAsset.

*  **FBSoundTouchAVAssetPlayer**.
   A subclass of the  FBAVAssetPlayer that uses the [SoundTouch](http://www.surina.net/soundtouch/) audio processing library to adjust the tempo of the playing audio

### Example iOS project

**FBAudioLibTester** is a program that shows how to use FBSoundTouchAVAssetPlayer. It prompts the user to select a song from the iTunes library on their device and plays it. A tempo slider permits changes to the playing audio tempo.

## How to Use

Copy the contents of the FBAudioLib folder into your project.

Then see the code from FBAudioLibTester. Basically just instantiate a FBSoundTouchAVAssetPlayer and give it a URL pointing to the AVAsset to play. You may adjust the tempo by writing to the tempo property of the player.

## WARNING

The AVAsset players use Apple's AVAssetReader. Apple is very explicit about warning that AVAssetReader is not intended for realtime use. It *seems* to work OK for this application, but there are some drawbacks. I'm pretty sure that using this will prevent the audio player from working in the background, and it doesn't seem to be capable of using the hardware decoder.

An alternative method would be to first copy the song to a sandboxed file and then to play it using a realtime player. Perhaps FBAudio will someday include code that does this.

## Credits

I wrote this while reading Chris Adamson's [*VTM_AViPodReader*](http://www.subfurther.com/blog/2010/12/13/from-ipod-library-to-pcm-samples-in-far-fewer-steps-than-were-previously-necessary/) application. Much of this code is influenced by Chris' work.

The **SoundTouch.framework** included here was pulled from Karl Stenerud's [Aural](https://github.com/kstenerud/Aural) repo, saving me the time to build one myself.

## License

With the exception of the SoundTouch framework, this code is copyright 2011 Mike Coleman, and is released under the Apache 2.0 license.

The SoundTouch framework is covered by the [LGPL v2.1](http://www.surina.net/soundtouch/license.html). Regarding usage of the static library for an iOS application the SoundTouch author states on the [FAQ:](http://www.surina.net/soundtouch/faq.html)
> "I don't mind at all if your application uses static linkage instead of dynamic, as far as you otherwise follow license terms, i.e. include a copyright notice of SoundTouch usage in the application."
