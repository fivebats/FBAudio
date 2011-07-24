//
// Copyright 2011 Mike Coleman
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Note: You are NOT required to make the license available from within your
// iOS application. Including it in your project is sufficient.
//
// Attribution is not required, but appreciated :)
//

#import "FBSoundTouchAVAssetPlayer.h"
#include <SoundTouch/SoundTouch.h>
//#define FB_DEBUG
#import "FBDebugSupport.h"

@interface FBSoundTouchAVAssetPlayer()
{
    soundtouch::SoundTouch soundTouchEngine;    
}
-(void)setupSoundTouch;

@end

@implementation FBSoundTouchAVAssetPlayer

- (id)init
{
    self = [super init];
    if (self) 
    {
        [self setupSoundTouch];
        self.filteringCallback = ^(FBAVAssetPlayer *player, char *srcBuffer, UInt32 srcBytesAvailable, char *dstBuffer, UInt32 dstBufferCapacity, UInt32 *dstBytesWritten )
        {
            soundTouchEngine.setTempoChange( tempo );
            soundTouchEngine.putSamples((soundtouch::SAMPLETYPE*)srcBuffer, srcBytesAvailable / 4);
            UInt32 samplesWritten = soundTouchEngine.receiveSamples((soundtouch::SAMPLETYPE*) dstBuffer, 32768 / 4 );
            *dstBytesWritten = samplesWritten * 4;
        };
    }
    
    return self;
}

- (float)tempo
{
    LOGFUNC_ENTRY;
    return tempo;
}

- (void)setTempo:(float)aTempo 
{
    LOGFUNC_ENTRY;
    if ( aTempo < -95.0f )
    {
        aTempo = -95.0f;
    }
    else if ( aTempo > 5000.0f )
    {
        aTempo = 5000.0f;
    }
    tempo = aTempo;
    soundTouchEngine.setTempoChange( tempo );
}

-(void)setupSoundTouch
{
    LOGFUNC_ENTRY;
    int sampleRate = 44100;
    int channels = 2;
    soundTouchEngine.setSampleRate( sampleRate );
    soundTouchEngine.setChannels( channels );
    soundTouchEngine.setTempoChange( 0.0f );
    soundTouchEngine.setPitchSemiTones( 0.0f );
    soundTouchEngine.setRateChange( 0.0f );
    soundTouchEngine.setSetting( SETTING_USE_QUICKSEEK, TRUE );
    soundTouchEngine.setSetting( SETTING_USE_AA_FILTER, FALSE );
}

-(void)stop
{
    LOGFUNC_ENTRY;
    soundTouchEngine.clear();
    [super stop];
}

@end
