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
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIView *albumCoverContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthEqualityConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightEqualityConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightEqualityConstraintMultiplied;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthEqualityConstraintMultiplied;

@property (strong, nonatomic) RRAudioPlayer *player;
@property (strong, nonatomic) RRAudioTrackInfo *trackInfo;

@end

@implementation RRFirstViewController

- (RRAudioPlayer*) player {
    if (!_player) {
        _player = [RRAudioPlayer sharedInstance];
    }
    return _player;
}

- (RRAudioTrackInfo*) trackInfo {
    if (!_trackInfo) {
        _trackInfo = [RRAudioTrackInfo sharedInstance:self];
    }
    return _trackInfo;
}

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
    [self.trackInfo onPlayButtonTapUp:isPlaying];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self.stackView) {
        if (size.width > size.height) {
            self.stackView.axis = UILayoutConstraintAxisHorizontal;
            [self setUpEqualitConstraintMultiplier:NO];
        } else {
            self.stackView.axis = UILayoutConstraintAxisVertical;
            [self setUpEqualitConstraintMultiplier:YES];
        }
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        }];
    } else {
        NSLog(@"stackView is nil");
    }
}

- (void) setUpEqualitConstraintMultiplier:(BOOL)isPortrait {
    if (self.albumCoverContainerView && self.widthEqualityConstraint && self.heightEqualityConstraint) {
        if (isPortrait) {
            self.widthEqualityConstraintMultiplied.active = NO;
            self.heightEqualityConstraint.active = NO;
            self.widthEqualityConstraint.active = YES;
            self.heightEqualityConstraintMultiplied.active = YES;
        } else {
            self.widthEqualityConstraint.active = NO;
            self.heightEqualityConstraintMultiplied.active = NO;
            self.widthEqualityConstraintMultiplied.active = YES;
            self.heightEqualityConstraint.active = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayPauseBtnTouchUp:(id)sender {
    BOOL isPlaying = [self.player onPlayButtonTapUp];
    [self.trackInfo onPlayButtonTapUp:isPlaying];
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
