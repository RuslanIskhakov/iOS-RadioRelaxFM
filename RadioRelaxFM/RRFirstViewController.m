//
//  RRFirstViewController.m
//  Radio Relax FM
//
//  Created by Deltasoft on 17.03.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import "RRFirstViewController.h"
#import "RRAppDelegate.h"
#import "RRAudioPlayer.h"
#import "RRAudioTrackInfo.h"


@interface RRFirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *audioTrackTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audioAlbumCoverImageView;
@property (weak, nonatomic) IBOutlet UIButton *audioControlBtn;


@end

@implementation RRFirstViewController

//+FIXME: check covers are legal
//+FIXME: check classes
//+FIXME: check player's state on view appearence
//FIXME: check strong/weak, atomic/nonatomic
//FIXME: move constants to dedicated class
//FIXME: add calls to NSLog from exception catchers
//FIXME: update icons drwables, create UI for iPad,
//FIXME: build from console

- (void)viewDidLoad
{
    NSLog(@"View Did Load");
    [super viewDidLoad];
	self.audioTrackTitleLabel.text = @"";
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"View Did Appear");
    [super viewDidAppear:animated];
    BOOL isPlaying = [RRAudioPlayer sharedInstance].isPlaying;
    [self updatePlayPauseButton:isPlaying];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayPauseBtnTouchUp:(id)sender {
    BOOL isPlaying = [[RRAudioPlayer sharedInstance] onPlayButtonTapUp];
    [[RRAudioTrackInfo sharedInstance:self] onPlayButtonTapUp:isPlaying];
    [self updatePlayPauseButton:isPlaying];
}

- (void) updatePlayPauseButton:(BOOL)isPlaying {
    if (isPlaying){
        [self.audioControlBtn setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
    } else {
        [self.audioControlBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    }
}

- (void)onAudioTrackTitleUpdate:(NSString*)title
{
    NSLog(@"Receiving Audio Track Title: %@",title);
    [self performSelectorOnMainThread:@selector(setAudioTrackTitle:) withObject:title waitUntilDone:NO];
}

- (void) setAudioTrackTitle: (NSString *)title
{
    NSLog(@"Displaying Audio Track Title: %@",title);
    [self.audioTrackTitleLabel setText:title];
}

- (void)onAudioAlbumCoverUpdated:(UIImage*) cover
{
    NSLog(@"Receiving Audio Album Cover Image");
    [self performSelectorOnMainThread:@selector(setAudioAlbumCoverImage:) withObject:cover waitUntilDone:NO];
}

- (void)setAudioAlbumCoverImage:(UIImage*) cover
{
    NSLog(@"Displaying Audio Album Cover Image");
    [self.audioAlbumCoverImageView setImage:cover];
}

@end
