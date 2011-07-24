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

#import <UIKit/UIKit.h>
#import "FBAudioLib.h"

@interface FBAudioLibTesterViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    MPMediaItem *song;
	UILabel *songLabel;
	UILabel *artistLabel;
	UILabel *sizeLabel;
	UIImageView *coverArtView;
    UISlider *songRateSlider;
    UILabel *speedLabel;
    UIButton *stopPlayingButton;
}
@property (nonatomic, retain) MPMediaItem *song;
@property (nonatomic, assign) IBOutlet UILabel *songLabel;
@property (nonatomic, assign) IBOutlet UILabel *artistLabel;
@property (nonatomic, assign) IBOutlet UILabel *sizeLabel;
@property (nonatomic, assign) IBOutlet UIImageView *coverArtView;
@property (nonatomic, assign) IBOutlet UISlider *songRateSlider;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UIButton *stopPlayingButton;

- (IBAction)chooseSongButtonPressed:(id)sender;
- (IBAction)speedSliderValueChanged:(id)sender;
- (IBAction)stopPlaybackButtonPressed:(id)sender;
@end
