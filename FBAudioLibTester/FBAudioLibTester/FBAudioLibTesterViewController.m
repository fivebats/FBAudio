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
#import <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR
#error This code cannot be tested on the simulator
#endif

#import "FBAudioLibTesterViewController.h"
#import "FBAudioLib.h"
//#define FB_DEBUG
#import "FBDebugSupport.h"

@interface FBAudioLibTesterViewController()
@property(nonatomic, retain) FBSoundTouchAVAssetPlayer *audioPlayer;
@end

@implementation FBAudioLibTesterViewController
@synthesize audioPlayer;
@synthesize song;
@synthesize songLabel;
@synthesize artistLabel;
@synthesize coverArtView;
@synthesize songRateSlider;
@synthesize speedLabel;
@synthesize stopPlayingButton;

- (void)didReceiveMemoryWarning
{
    LOGFUNC_ENTRY;
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    LOGFUNC_ENTRY;
    self.audioPlayer = [[[FBSoundTouchAVAssetPlayer alloc] init] autorelease];
    audioPlayer.delegate = self;
    stopPlayingButton.enabled = NO;
    self.songLabel.text = @"";
    self.artistLabel.text = @"";
    self.coverArtView.hidden = YES;
    [super viewDidLoad];
}


-(void) viewDidAppear:(BOOL)animated
{
    LOGFUNC_ENTRY;
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    LOGFUNC_ENTRY;
    self.songLabel = nil;
    self.artistLabel = nil;
    self.coverArtView = nil;
    self.songRateSlider = nil;
    self.speedLabel = nil;
    
    [self setStopPlayingButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    LOGFUNC_ENTRY;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    LOGFUNC_ENTRY;
    [song release], song = nil;
    [songLabel release], songLabel = nil;
    [artistLabel release], artistLabel = nil;
    [coverArtView release], coverArtView = nil;
    [songRateSlider release], songRateSlider = nil;
    [speedLabel release], speedLabel = nil;
    
    [stopPlayingButton release];
    [super dealloc];
}

#pragma mark actions

-(void) playSong
{
    LOGFUNC_ENTRY;
    [audioPlayer playFromAssetURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
}

- (IBAction)chooseSongButtonPressed:(id)sender 
{
    LOGFUNC_ENTRY;
    [audioPlayer stop];
    songRateSlider.value = 0.0f;
    [self speedSliderValueChanged:songRateSlider];
	MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
												 initWithMediaTypes: MPMediaTypeMusic];
	pickerController.prompt = @"Choose song";
	pickerController.allowsPickingMultipleItems = NO;
	pickerController.delegate = self;
	[self presentModalViewController:pickerController animated:YES];
	[pickerController release];
}

- (IBAction)speedSliderValueChanged:(id)sender 
{
    LOGFUNC_ENTRY;
    speedLabel.text = [NSString stringWithFormat:@"%2.1f x", (songRateSlider.value)/100.0 + 1.0];
    audioPlayer.tempo = songRateSlider.value;
}

- (IBAction)stopPlaybackButtonPressed:(id)sender 
{
    LOGFUNC_ENTRY;
    [audioPlayer stop];
    stopPlayingButton.enabled = NO;
}


#pragma mark MPMediaPickerControllerDelegate

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection 
{
    LOGFUNC_ENTRY;
	[self dismissModalViewControllerAnimated:YES];
	if ( [mediaItemCollection count] < 1 ) 
    {
		return;
	}
	self.song = [[mediaItemCollection items] objectAtIndex:0];
	songLabel.hidden = NO;
	artistLabel.hidden = NO;
	coverArtView.hidden = NO;
	songLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
	artistLabel.text = [song valueForProperty:MPMediaItemPropertyArtist];
	coverArtView.image = [[song valueForProperty:MPMediaItemPropertyArtwork]
						  imageWithSize: coverArtView.bounds.size];
    coverArtView.hidden = NO;
    stopPlayingButton.enabled = YES;
    [self playSong];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker 
{
    LOGFUNC_ENTRY;
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark FBAVAssetPlayerDelegate

-(void) audioAssetPlayerDidStartPlayback:(FBAVAssetPlayer*)player
{
    LOGFUNC_ENTRY;
}

-(void) audioAssetPlayerDidStopPlayback:(FBAVAssetPlayer*)player
{
    LOGFUNC_ENTRY;
    dispatch_async( dispatch_get_main_queue(), ^{
        self.songLabel.text = @"";
        self.artistLabel.text = @"";
        self.coverArtView.hidden = YES;
    });
}

@end
