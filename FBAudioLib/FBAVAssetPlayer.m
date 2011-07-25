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

#import "FBAVAssetPlayer.h"
#import "FBAudioQueuePlayer.h"
//#define FB_DEBUG
#import "FBDebugSupport.h"

@interface FBAVAssetPlayer()
{
    AVAssetReader *assetReader;
    AVAssetReaderOutput *assetReaderOutput;
    char *tempBuffer;
}

@end

@implementation FBAVAssetPlayer
@synthesize audioPlayer;
@synthesize filteringCallback;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) 
    {
        NSError *err = nil;
        tempBuffer = calloc( 32768, 1 );
        filteringCallback = nil;
        [[AVAudioSession sharedInstance] setDelegate:self];
        if ( NO == [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil] )
        {
            NSLog( @"error setting audio session category: %@", [err localizedDescription]);
        }
        if ( NO == [[AVAudioSession sharedInstance] setPreferredHardwareSampleRate: 44100.0f error: &err] )
        {
            NSLog( @"error setting hardware sampling rate: %@", [err localizedDescription]);
        }
        UInt32 one = 1;
        OSStatus status = AudioSessionSetProperty( kAudioSessionProperty_OverrideCategoryMixWithOthers, 
                                                  sizeof(UInt32), &one );
        if ( status != kAudioSessionNoError )
        {
            NSLog( @"error setting mix override: %04lx", status );
        }
        if ( NO == [[AVAudioSession sharedInstance] setActive: YES error: &err] )
        {
            NSLog( @"error activating audio session: %@", [err localizedDescription]);
        }
        if ( NO == [[AVAudioSession sharedInstance] setPreferredIOBufferDuration: 1024.0/44100.0 error: &err] )
        {
            NSLog( @"error setting audio buffer duration: %@", [err localizedDescription]);
        }
    }
    return self;
}

- (void)dealloc
{
    delegate = nil;
    [assetReader release], assetReader = nil;
    [assetReaderOutput release], assetReaderOutput = nil;
    free( tempBuffer ), tempBuffer = NULL;
    [super dealloc];
}

-(void)playFromAssetURL:(NSURL *)assetURL
{
    LOGFUNC_ENTRY;
	AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
	NSError *assetError = nil;
	assetReader = [[AVAssetReader assetReaderWithAsset:songAsset error:&assetError] retain];
	if (assetError)
    {
		NSLog (@"error: %@", assetError);
		return;
	}
	assetReaderOutput = [[AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks audioSettings: nil] retain];
	if (! [assetReader canAddOutput: assetReaderOutput]) 
    {
		NSLog (@"error adding asset reader output");
		return;
	}
	[assetReader addOutput: assetReaderOutput];
	[assetReader startReading];
    
    self.audioPlayer = [[[FBAudioQueuePlayer alloc] init] autorelease];
    audioPlayer.delegate = self;
    audioPlayer.addSampleCallback = ^(FBAudioQueuePlayer *player, AudioQueueBufferRef inBuffer)
    {
        OSStatus err;
        AVAssetReaderStatus status = [assetReader status];
        DLog(@"addSampleCallback: status is %d", status );
        AVAssetReaderOutput *readerOutput = [[assetReader outputs] objectAtIndex:0];
        if (readerOutput) 
        {
            CMSampleBufferRef nextBuffer = NULL;
            if ( status == AVAssetReaderStatusReading )
            {
                nextBuffer = [readerOutput copyNextSampleBuffer];
                DLog( @"nextBuffer = 0x%x", (unsigned) nextBuffer );
                if ( nextBuffer == NULL )
                {
                    return;
                }
            }
            if ( nextBuffer != NULL )
            {
                size_t totalSampleSize = CMSampleBufferGetTotalSampleSize(nextBuffer);
                UInt32 bufferCapacity = inBuffer->mAudioDataBytesCapacity;
                DLog( @"totalSampleSize = %lu, bufferCapacity = %lu", totalSampleSize, bufferCapacity );
                inBuffer->mAudioDataByteSize = totalSampleSize;
                if ( totalSampleSize > bufferCapacity )
                {
                    inBuffer->mAudioDataByteSize = bufferCapacity;
                }
                CMBlockBufferRef buffer = CMSampleBufferGetDataBuffer( nextBuffer );
                if ( filteringCallback == nil )
                {
                    err = CMBlockBufferCopyDataBytes( buffer, 0, inBuffer->mAudioDataByteSize, inBuffer->mAudioData );
                    if ( err != noErr )
                    {
                        NSLog( @"got error %ld from CMBlockBufferCopyDataBytes", err );
                    }
                }
                else
                {
                    char *srcBytes;
                    status = CMBlockBufferAccessDataBytes( buffer, 0, inBuffer->mAudioDataByteSize, tempBuffer, &srcBytes );
                    filteringCallback( self, srcBytes, inBuffer->mAudioDataByteSize, inBuffer->mAudioData, inBuffer->mAudioDataBytesCapacity, &inBuffer->mAudioDataByteSize );
                }
                CFRelease( nextBuffer );
            }
            else
            {
                if ( status != AVAssetReaderStatusReading )
                {
                    NSLog( @"done. (%d)\n", status );
                    [player stop];
                }
            }
        }
        else
        {
            NSLog( @"no readerOutput");
        }
    };
    [audioPlayer start];
    
}


-(void)stop
{
    LOGFUNC_ENTRY;
    [audioPlayer stop];
}

#pragma mark FBAudioQueuePlayerDelegate

-(void) audioQueuePlayerDidStartPlayback:(FBAudioQueuePlayer*)player
{
    LOGFUNC_ENTRY;
    if ( delegate && [delegate respondsToSelector:@selector(audioAssetPlayerDidStartPlayback:)] )
    {
        [delegate audioAssetPlayerDidStartPlayback:self];
    }
}

-(void) audioQueuePlayerDidStopPlayback:(FBAudioQueuePlayer*)player
{
    LOGFUNC_ENTRY;
    if ( delegate && [delegate respondsToSelector:@selector(audioAssetPlayerDidStopPlayback:)] )
    {
        [delegate audioAssetPlayerDidStopPlayback:self];
    }
}

@end
