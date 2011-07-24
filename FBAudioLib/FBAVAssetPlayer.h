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

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "FBAudioQueuePlayer.h"
@class FBAVAssetPlayer;

typedef void (^FBAudioFilteringCallback)( FBAVAssetPlayer *player, char *srcBuffer, UInt32 srcBytesAvailable, char *dstBuffer, UInt32 dstBufferCapacity, UInt32 *dstBytesWritten );

@protocol FBAVAssetPlayerDelegate <NSObject>
@optional
-(void) audioAssetPlayerDidStartPlayback:(FBAVAssetPlayer*)player;
-(void) audioAssetPlayerDidStopPlayback:(FBAVAssetPlayer*)player;
@end

@interface FBAVAssetPlayer : NSObject <AVAudioSessionDelegate, FBAudioQueuePlayerDelegate>
{
    FBAudioFilteringCallback filteringCallback;
}
@property(nonatomic, copy) FBAudioFilteringCallback filteringCallback;
@property(nonatomic, retain) FBAudioQueuePlayer *audioPlayer;
@property(nonatomic, assign) id<FBAVAssetPlayerDelegate> delegate;

-(void)playFromAssetURL:(NSURL*)assetURL;
-(void)stop;

@end
